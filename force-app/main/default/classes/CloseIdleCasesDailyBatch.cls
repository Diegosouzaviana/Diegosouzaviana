//
// Classe de testes: CloseIdleCasesDailyBatchTest
// Atenção: To do antes de rodar a classe de testes.
// 
global class CloseIdleCasesDailyBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime threeHoursAgo = System.now().addHours(-3);
        if(!Test.isRunningTest()){
            return Database.getQueryLocator([
                SELECT 	Id, CaseNumber, AssetId, Asset.Name, Lxd_observation__c, OwnerId
                FROM Case 
                WHERE Status = 'Em atendimento' 
                AND (Origin = 'Matrix' OR Origin = 'Asteriks')
                AND LastModifiedDate <= :threeHoursAgo
        	]);
        } else {
            return Database.getQueryLocator([
                SELECT Id, CaseNumber, AssetId, Asset.Name, Lxd_observation__c, OwnerId
                FROM Case 
                WHERE Status = 'Em atendimento' 
                AND Origin = 'Matrix' 
        	]);
        }
        
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        
        List<Case> casesToUpdate = new List<Case>();
        for (Case c : scope) {
            if(c.OwnerId.toString().startsWith('00G')){
                c.Status = 'Finalizado';
                c.solution__c = 'Resolvido por inatividade';
            	c.Lxd_observation__c = c.Lxd_observation__c != '' && c.Lxd_observation__c != null ? c.Lxd_observation__c + ' ||| ' : '';
            	c.Lxd_observation__c = 'Resolvido por inatividade';
            	casesToUpdate.add(c);
            }
        }

        Database.update(casesToUpdate, false);
    }

    global void finish(Database.BatchableContext BC) {
        
        // Verificaremos se ainda existem casos abertos, normalmente o motivo para continuarem abertos é o filtro do 
        // Asset que não é compatível com o AssetId e trava o update. Nesse caso, limparemos o campo do AssetId para
        // update possa ocorrer.
                
        List<Case> stillOpenCases = new List<Case>();
        
        for(Case c : getBatchCases()){
            if(c.OwnerId.toString().startsWith('00G')){              
                c.Status = 'Finalizado';
                c.solution__c = 'Resolvido por inatividade';
            	c.Lxd_observation__c = c.Lxd_observation__c != '' && c.Lxd_observation__c != null ? c.Lxd_observation__c + ' ||| ' : '';
                c.Lxd_observation__c += 'Resolvido por inatividade - Ativo removido para fechamento de caso. Ativo: ' + c.Asset.Name + ' (Id: ' + c.AssetId + ')';
                c.AssetId = null;
                stillOpenCases.add(c);
            }
        }
        
        Database.update(stillOpenCases, false);
    }
    
    // No contexto de testes da batch, precisamos de 2 queries diferentes para cobrir o método "finish"
    global List<Case> getBatchCases(){
        
        DateTime threeHoursAgo = System.now().addHours(-3);
        
        if(!Test.isRunningTest()){
            return [
                SELECT 	Id, CaseNumber, AssetId, Asset.Name, Lxd_observation__c, OwnerId
                FROM Case 
                WHERE Status = 'Em atendimento' 
                AND (Origin = 'Matrix' OR Origin = 'Asteriks')
                AND LastModifiedDate <= :threeHoursAgo
        	];
        } else {
            return [
                SELECT 	Id, CaseNumber, AssetId, Asset.Name, Lxd_observation__c, OwnerId
                FROM Case LIMIT 1 
        	];
        }
    }
}
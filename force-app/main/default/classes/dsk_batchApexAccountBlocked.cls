global class dsk_batchApexAccountBlocked implements Database.Batchable<List<SObject>>{
    global List<Contract> ContractBlockedLst = new List<Contract>();
    List<Contract> contractActiveList = new List<Contract>();
    
    global static final Map<String,Object> mock = new Map<String, Object>();

    global List<List<SObject>> start(Database.BatchableContext bc) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        Object result;
        if(Test.isRunningTest()){
        	Contract ctrTest = [Select Name, ContractNumber From Contract Where Name = 'Contract-Prueba1' LIMIT 1];
        	List<Map<String,Object>> blocked = new List<Map<String,Object>>();
        	blocked.add(new Map<String,Object>{'contract' => ctrTest.ContractNumber});
        	mock.put('blocked',blocked);
            result = mock;
        }else{
            result = vlocity_cmt.IntegrationProcedureService.runIntegrationService('LXD_IP_ContractAccountBlocking', ipInput, ipOptions);
        }
        /*Object result= Test.isRunningTest() ? mock : vlocity_cmt.IntegrationProcedureService.runIntegrationService('LXD_IP_ContractAccountBlocking', ipInput, ipOptions);*/
        Map<String, Object> resultados= (Map<String, Object>)result;
        List<Object> crtblocked= (List<Object>)resultados.get('blocked');
        List<String> Numerosdecrt= new List<String>();
        for(Object bloqueado: crtblocked){
            Map<String, Object> contractbloqueds= (Map<String, Object>)bloqueado;
            Numerosdecrt.add(String.valueOf(contractbloqueds.get('contract')));
        }
        ContractBlockedLst=[SELECT Id, ContractNumber, Status,AccountId FROM Contract WHERE ContractNumber IN:Numerosdecrt];
        List<String> Ids=new List<String>();
        for(Contract ctr: ContractBlockedLst){
            Ids.add(ctr.AccountId);
        }
        List <Account> accountIdSet = [Select Id,LXD_Status__c From Account Where Id IN:Ids];
        List<List<SObject>> Listasa= new List<List<SObject>>();
        Listasa.add(accountIdSet);
        Listasa.add(ContractBlockedLst);
        return Listasa;
        //[SELECT Id, (SELECT Id, AccountId, Status FROM Contracts WHERE Id NOT IN :ContractBlockedLst And Status='Ativo') FROM Account WHERE Id IN :accountIdSet];
    }
    
    global void execute(Database.BatchableContext bc, List<List<SObject>> scope) {
        ContractBlockedLst=scope[1];
        List<Account> AccLST= scope[0];
        contractActiveList=[SELECT Id, ContractNumber, AccountId, Status FROM Contract WHERE Id NOT IN :ContractBlockedLst AND Status='ATIVO'];
        Map<Id, Account> updateAcc= new Map<Id, Account>();
        for(Account accblocked: AccLST){
            for(Contract ctrActive: contractActiveList){
                if(accblocked.Id != ctrActive.AccountId || ctrActive==null){
                    accblocked.LXD_Status__c= 'Bloqueado';
                    if(!updateAcc.containsKey(accblocked.Id)){
                        updateAcc.put(accblocked.Id, accblocked);
                    }
                }else if(accblocked.Id== ctrActive.AccountId){ 
                    if(accblocked.LXD_Status__c== 'Bloqueado'){
                        accblocked.LXD_Status__c= 'Ativo';
                        updateAcc.put(accblocked.Id, accblocked);
                        break;
                    }
                }
            }
        }
        List<Account> accountToUpdate = updateAcc.values();
        //accountToUpdate.add((Account) updateAcc.get('Account'));
        update accountToUpdate;
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}
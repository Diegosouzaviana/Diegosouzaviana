//
// Classe coberta: CloseIdleCasesDailyBatch
// 
// TO DO: 
// Massa de Casos está em um Static Resource. Subir o recurso "CasesTest" (conteúdo arquivo.csv) junto com a classe de testes no deploy.
// Na ausência dele, o conteúdo do CSV está comentado no final dessa classe
//
@isTest
private class CloseIdleCasesDailyBatchTest {
    @isTest
    static void testBatchExecution() {

        List <sObject> ls = Test.loadData(Case.sObjectType, 'CasesTest'); 

        Test.startTest();
        
        CloseIdleCasesDailyBatch batchInstance = new CloseIdleCasesDailyBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, Status, Lxd_observation__c, AssetId FROM Case];
        for (Case updatedCase : updatedCases) {
            System.assertEquals('Finalizado', updatedCase.Status);
            System.assertNotEquals(null, updatedCase.Lxd_observation__c);
            System.assertEquals(null, updatedCase.AssetId);
        }
    }
}

/*
 * ------------------- CSV FILE -------------------
 * 
 * Salvar o conteúdo abaixo em um arquivo cases.csv > Armazenar em Static Resources nomeado como "CasesTest"
 *
 * ------------------------------------------------
 
"Id","CaseNumber","Lxd_observation__c","Origin","Status","LastModifiedDate","CreatedDate","OwnerId"
"500Ha000008o8abIAA","00095563","Descrição 1","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aYIAQ","00095560","Descrição 2","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aaIAA","00095562","Descrição 3","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aUIAQ","00095556","Descrição 4","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aWIAQ","00095558","Descrição 5","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aXIAQ","00095559","Descrição 6","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aVIAQ","00095557","Descrição 7","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aZIAQ","00095561","Descrição 8","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8aTIAQ","00095555","Descrição 9","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
"500Ha000008o8acIAA","00095564","Descrição 10","Matrix","Em atendimento","2024-04-18T00:24:23.000+0000","2024-04-18T00:24:23.000+0000","00G8b000006MVqfEAG"
 
 * ------------------------------------------------
 *
 */
@isTest
private class CaseSelectorTest{

	@testSetup static void setup(){

		List<String> cpfs = new List<String>{'454.337.700-10', '470.782.940-68', '748.181.530-52','973.544.010-56','576.947.560-98'};
		List<Account> customerAccs = new List<Account>();
        for(Integer i = 0; i < 1; i++) {
            customerAccs.add( new Account(
                Name = 'Customer Account ' + i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LXD_Customer').getRecordTypeId(),
                LXD_CPF__c = cpfs[i]
            ));
        }
        insert customerAccs;

		List<Contract> contracts = new List<Contract>();
        Date dt = Date.today();
        for(Account a : customerAccs){
            contracts.add(new Contract(
                AccountId = a.Id,
                StartDate = dt
            ));
        }
		insert contracts;

		List<Case> cases = new List<Case>();
		Integer counter = 0;
        for (Integer i = 0; i < contracts.size(); i++) {
			counter++;
            Contract c = contracts[i];
			cases.add(new Case(
				Area_de_atendimento__c ='SAC', 
				motive__c ='Ativo NPS', 
				solution__c ='Sem Retorno', 
				submotive__c ='Faturamento', 
				Tema__c ='Ativo', 
				Tipo__c ='Informação',
				Contrato__c = c.Id
				));
		}
		insert cases;
		 
	}

	@isTest static void testGetCasesLastYear() {  
		List<Case> casos = CaseSelector.getCasesLastYear();  
		System.assert(casos.size() == 1);  
		System.assertEquals(casos[0].Id, [SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id);  
	 }  
	
	 @isTest static void testGetCasesBetweenTwoDates() {
		Date startDate = Date.today().addMonths(-1);  
		Date endDate = Date.today();  
		List<Case> casos = CaseSelector.getCasesBetweenTwoDates(startDate, endDate);  
		System.assert(casos.size() > 0);
	    System.assertEquals(casos[0].Id, [SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id); 
	} 
	
	 @isTest static void testGetCasesBetweenTwoDatesWithIds() {  
		List<String> caseIds = new List<String> {[SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id};  
		List<Case> casos = CaseSelector.getCasesBetweenTwoDates(caseIds);  
		System.assert(casos.size() == 1);  
		System.assertEquals(casos[0].Id, [SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id);  
	 }  
}
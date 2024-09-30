@isTest
private class TestCaseSelector{

	@testSetup static void setup(){

		Case caseObj = new Case (
			Area_de_atendimento__c ='SAC', 
			Contrato__c = 'Here is reference id', 
			motive__c ='Alteracao da Data de Vencimento', 
			solution__c ='2ª via de boleto - sem juros', 
			submotive__c ='2 via de boleto', 
			Endereco_de_Atendimento__Street__s = 'Test Value', 
			Endereco_de_Atendimento__City__s = 'test value', 
			Tema__c ='Acesso', 
			Tipo__c ='Informação', 
			BusinessHoursId = 'Here is reference id'
		);
		insert caseObj;
		 
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
		System.assert(casos.size() == 1);  
		System.assertEquals(casos[0].Id, [SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id);  
	 }  
	
	 @isTest static void testGetCasesBetweenTwoDatesWithIds() {  
		List<String> caseIds = new List<String> {[SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id};  
		List<Case> casos = CaseSelector.getCasesBetweenTwoDates(caseIds);  
		System.assert(casos.size() == 1);  
		System.assertEquals(casos[0].Id, [SELECT Id FROM Case WHERE Area_de_atendimento__c = 'SAC'].get(0).Id);  
	 }  
}
@RestResource(urlMapping='/CustomerWithoutService')
global with sharing class AccountWebService {
    static RestRequest req = RestContext.request;
	static RestResponse res = RestContext.response;

    @HttpGet
    global static void totalCustomerWithoutService(){
        System.debug('Valor do req é:  '+req);
        //integer totalSize;
        List<Account> customerAccounts = [SELECT Id, Name FROM Account WHERE  RecordType.Name = 'Customer' and CreatedDate = TODAY ];
		Set<Id> serviceParentIds = new Set<Id>();          
           
        
		for(Account serviceAccount : [SELECT ParentId FROM Account WHERE  RecordType.Name = 'Service' AND Parent.RecordType.Name = 'Customer' and CreatedDate = TODAY]) {
    		System.debug('Exibição eh: '+serviceAccount.parentId);
            serviceParentIds.add(serviceAccount.ParentId);
        }                                                                                                                                                                 
        List<Account> result = new List<Account>();
		for(Account customerAccount : customerAccounts) {
    		if(!serviceParentIds.contains(customerAccount.Id)){
        	result.add(customerAccount);
    		}
		}
        
System.debug('Result: ' + result.size());
        res.statusCode=200;
        res.addHeader('Content-Type','application/json');
        res.responseBody= blob.valueof('Total de contas Customer sem service eh: '+result.size());
        System.debug('Valor do res'+res);

		//for(Account acc : result){
    	//	System.debug('Name: ' + acc.Name + ' Id: ' + acc.Id);        	     
        
    	//}
         
        //return result.size();
    }
}
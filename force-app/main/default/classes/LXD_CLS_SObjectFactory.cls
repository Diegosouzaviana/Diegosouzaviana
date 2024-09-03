/*
*   @author: Misael Ribas
*   @since: 2022/11/16
*   @className: LXD_CLS_SObjectFactory
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/11/16          Misael Ribas            Class creation
*   2023/01/23          Wesley Prado            Refactor: create helper methods ♻️
*   2023/01/20          Wesley Prado            Refactor: create methods & enum to create accounts ♻️
*   2023/02/08          Guilherme Gauy          Method added - createAutomationUser
*   ====================================================
*/
@isTest
public class LXD_CLS_SObjectFactory{
    //Roles
    private static final Id ADMINISTRADOR_USER_ROLE = [SELECT Id FROM UserRole WHERE DeveloperName = 'Administrador' LIMIT 1].Id;
    
    //Profiles
    private static final Id PORTAL_PROFILE = [SELECT Id, Name FROM Profile WHERE NAME = 'Cliente Portal' LIMIT 1].Id;
    private static final Id MINIMUM_ACCESS_PROFILE = [SELECT Id, Name FROM Profile WHERE NAME = 'Minimum Access - Salesforce' LIMIT 1].Id;
    private static final Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1].Id;
    
    //RecordTypes
    public enum AccountRTEnum {CUSTOMER, CONSUMER, BILLING, SERVICE}
    public static final Map<AccountRTEnum, Id> ACCOUNT_RT_MAP = new Map<AccountRTEnum, Id>{
        AccountRTEnum.CUSTOMER => Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
        AccountRTEnum.CONSUMER => Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId(),
        AccountRTEnum.BILLING => Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
        AccountRTEnum.SERVICE => Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId()
    };
    private static final Id CASE_SOLICITACAO = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Solicitação').getRecordTypeId();

    //_____User/Usuário_____
    public static User CreateUserADM(){
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
            ProfileId = ADMIN_PROFILE_ID,
            LastName = 'Admin',
            Email = 'Admin.validation@desktop.com',
            Username = 'Admin'+randomNumber+'@desktop.com',
            CompanyName = 'Desktop',
            Title = 'Desktop',
            Alias = 'Desk',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = ADMINISTRADOR_USER_ROLE
        );
        return lUser;
    }

    public static User createAutomationUser(){
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
            ProfileId = ADMIN_PROFILE_ID,
            LastName = 'Automated Process',
            Email = 'AutomatedProcess.validation@desktop.com',
            Username = 'AutomatedProcess'+randomNumber+'@desktop.com',
            CompanyName = 'Desktop',
            Title = 'Desktop',
            Alias = 'Desk',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = ADMINISTRADOR_USER_ROLE
        );
        return lUser;
    }
    
	public static User CreateUserMinimum(){
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = MINIMUM_ACCESS_PROFILE,
     		LastName = 'Minimum',
     		Email = 'Minimum.validationMinimum@desktop.com',
     		Username = 'Minimum'+randomNumber+'Minimum@desktop.com',
			CompanyName = 'Desktop',
     		Title = 'Desktop',
     		Alias = 'Desk',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US',
            UserRoleId = ADMINISTRADOR_USER_ROLE
		);
        return lUser;
    }  

	public static User CreateUserMinimum(String lastname){
        String email = generateAccountEmail(removeSpacesFromText(lastname), System.now().getTime());
        User lUser = new User(
     		ProfileId = MINIMUM_ACCESS_PROFILE,
     		LastName = lastname,
     		Email = email,
     		Username = email,
			CompanyName = 'Desktop',
     		Title = 'Agente',
     		Alias = 'dskmin',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US',
            UserRoleId = ADMINISTRADOR_USER_ROLE
		);
        return lUser;
    }  
    
    public static User CreateUserCommunity(String lContactId){
        User lUser = new User();
        List<User> lUserLst = [SELECT Id, ProfileId, alias, email, emailencodingkey, lastname, languagelocalekey, 
                               localesidkey, country, IsActive, ContactId, timezonesidkey, username FROM User WHERE email = 'UserCommunit@test.com'];
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        if(lUserLst.isEmpty()){
            lUser.ProfileId = PORTAL_PROFILE;
            lUser.alias = 'UserComm';
            lUser.email='UserCommunit@test.com';
            lUser.emailencodingkey='UTF-8';
            lUser.lastname='UserCommunit';
            lUser.languagelocalekey='en_US';
            lUser.localesidkey='en_US';
            lUser.country='United States';
            lUser.IsActive =true;
            lUser.ContactId = lContactId;
            lUser.timezonesidkey='America/Los_Angeles';
            lUser.username='UserCommunit'+randomNumber+'@test.com';
        }
        else lUser = lUserLst[0];
        return lUser;
    }

    //_____PermissionSet/Conjunto de permissões_____
    public static PermissionSetAssignment CreatePermissionSAC(User lUser){
        PermissionSet lPS = [SELECT Id FROM PermissionSet WHERE Name = 'LXD_SAC' LIMIT 1];
        PermissionSetAssignment lPSA = new PermissionSetAssignment(
        AssigneeId = lUser.Id,
        PermissionSetId = lPS.Id
        );
        return lPSA;
    }
    
    public static LiveChatVisitor CreateLiveChatVisitor(){
        LiveChatVisitor lLiveChatVisitor = new LiveChatVisitor();
        return lLiveChatVisitor;
    }
    
    //_____LiveChatTranscript/Transcrição do Chat_____
    public static LiveChatTranscript CreateLiveChatTranscript(String aCaseId, String aLiveChatVisitorId){
        LiveChatTranscript lLiveChatTranscript = new LiveChatTranscript(
        	CaseId = aCaseId,
            LiveChatVisitorId = aLiveChatVisitorId
        );
        return lLiveChatTranscript;
    }
    
    //_____MessagingChannel/Canal do Messaging_____
    public static MessagingChannel CreateMessagingChannel(String Name, String Label){
        MessagingChannel lMessagingChannel = new MessagingChannel(
            DeveloperName = Name+'MessagingChannel',
            MasterLabel = Label+'MasterLabel',
            MessageType = 'WhatsApp',
            MessagingPlatformKey = Name+'1'
        );
        return lMessagingChannel;
    }
    
    //_____MessagingEndUser/Usuário do Messaging_____
    public static MessagingEndUser CreateMessagingEndUser(String Name, String MessagingChannelId){
        MessagingEndUser lMessagingEndUser = new MessagingEndUser(
            Name = Name,
            MessagingChannelId = MessagingChannelId,
        	MessageType = 'WhatsApp',
        	MessagingPlatformKey = Name+'1'
        );
        return lMessagingEndUser;
    }
    
    //_____MessagingSession/Sessões do Messaging_____
    public static MessagingSession CreateMessagingSession(String aCaseId, String MessagingChannelId, String MessagingEndUserId){
        MessagingSession lMessagingSession = new MessagingSession(
        	CaseId = aCaseId,
            Status = 'New',
            MessagingChannelId = MessagingChannelId,
            MessagingEndUserId = MessagingEndUserId
        );
        return lMessagingSession;
    }
    
    //_____Case/Caso_____
    public static Case CreateCaseSolicitacao(String lOwner, String SuppliedName){
        Case lCase = new Case(
        	RecordTypeId = CASE_SOLICITACAO,
            SuppliedName = SuppliedName,
            Status = 'Em Atendimento',
        	//Motive__c = 'Reativação',
            //submotive__c = 'Reativacao',
            OwnerId = lOwner
        );
        return lCase;
    }
    
    public static Case CreateCaseSolicitacao(Id lOwner){
        Case lCase = new Case(
        	RecordTypeId = CASE_SOLICITACAO,
        	//Motive__c = 'Reativação',
            //submotive__c = 'Reativacao',
            OwnerId = lOwner
        );
        return lCase;
    }
    
    //_____Account/Conta_____
    public static Account CreateAccount(){
        Account lAcc = new Account(
            Name = 'Desktop',
            RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.CUSTOMER)
        );
        return lAcc;
    }
    
    public static Account CreateAccountCommunity(){
        
        Account lAcc = new Account();
        List<Account> lAccLst = [SELECT Id,LXD_Email__c FROM Account WHERE Name = 'Desktop Account Community'];
        if(lAccLst.isEmpty()){
            Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        	lAcc.Name = 'Desktop Account Community';
            lAcc.LXD_Email__c = 'Test'+randomNumber+'@test.com';
            lAcc.RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.CUSTOMER);
        }
        else{
            lAcc = lAccLst[0];
        }
        
        return lAcc;
    }

    public static Account createAccount(String name, String cpf, AccountRTEnum accountEnum){
        if(accountEnum == AccountRTEnum.CUSTOMER) return createCustomerAccount(name, cpf);
        else if(accountEnum == AccountRTEnum.CONSUMER) return createConsumerAccount(name, cpf);
        else if(accountEnum == AccountRTEnum.BILLING) return createBillingAccount(name, cpf);
        else if(accountEnum == AccountRTEnum.SERVICE) return createServiceAccount(name, cpf);

        return null;
    }

    public static Account createCustomerAccount(String name, String cpf){
        Long timestamp = System.now().getTime();
        Account costumerAccount = new Account(
            Name = name + ' ' + timestamp,
            LXD_Email__c = generateAccountEmail(name, timestamp),
            LXD_CPF__c = cpf,
            RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.CUSTOMER),
            BillingCity = 'Uberlândia',
            BillingCountry = 'Any Country',
            BillingPostalCode = '38411626',
            BillingState = 'MG',
            BillingStreet = 'Rua Vicente Paula Vaz',
            LXD_AddressNeighborhood__c = 'Loteamento Vale dos Vinhedos',
            LXD_AddressNumber__c = '44'
        );
        return costumerAccount;
    }
    public static Account createConsumerAccount(String name, String cpf){
        Long timestamp = System.now().getTime();
        Account consumerAccount = new Account(
            Name = name + ' ' + timestamp,
            LXD_Email__c = generateAccountEmail(name, timestamp),
            LXD_CPF__c = cpf,
            RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.CONSUMER),
            BillingCity = 'Uberlândia',
            BillingCountry = 'Any Country',
            BillingPostalCode = '38411626',
            BillingState = 'MG',
            BillingStreet = 'Rua Vicente Paula Vaz',
            LXD_AddressNeighborhood__c = 'Loteamento Vale dos Vinhedos',
            LXD_AddressNumber__c = '44'
        );
        return consumerAccount;
    }
    public static Account createBillingAccount(String name, String cpf){
        Long timestamp = System.now().getTime();
        Account billingAccount = new Account(
            Name = name + ' ' + timestamp,
            LXD_Email__c = generateAccountEmail(name, timestamp),
            LXD_CPF__c = cpf,
            RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.BILLING),
            BillingCity = 'Uberlândia',
            BillingCountry = 'Any Country',
            BillingPostalCode = '38411626',
            BillingState = 'MG',
            BillingStreet = 'Rua Vicente Paula Vaz',
            LXD_AddressNeighborhood__c = 'Loteamento Vale dos Vinhedos',
            LXD_AddressNumber__c = '44'
        );
        return billingAccount;
    }
    public static Account createServiceAccount(String name, String cpf){
        Long timestamp = System.now().getTime();
        Account serviceAccount = new Account(
            Name = name + ' ' + timestamp,
            LXD_Email__c = generateAccountEmail(name, timestamp),
            LXD_CPF__c = cpf,
            RecordTypeId = ACCOUNT_RT_MAP.get(AccountRTEnum.SERVICE),
            ShippingCity = 'Ji-Paraná',
            ShippingCountry = 'Any Country',
            ShippingPostalCode = '76908161',
            ShippingState = 'RO',
            ShippingStreet = 'Rua Tiradentes',
            LXD_AddressNeighborhood__c = 'São Francisco',
            LXD_AddressNumber__c = '27'
        );
        return serviceAccount;
    }
    
    //_____Contract/Contrato_____
	public static Contract CreateContract(String aAccountId){
        Contract lContract = new Contract(
        	AccountId = aAccountId,
            vlocity_cmt__ContractReferenceNumber__c = '123'
        );
        return lContract;
    }
    
    //_____Contact/Contato_____
    public static Contact CreateContact(String lAccountId){
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        Contact lCont = new Contact(
            LastName = 'ContactTest',
            AccountId = lAccountId
        );
        return lCont;
    }
    
    //_____Entitlement/Direito_____
    public static Entitlement CreateEntitlement(String aAccountId){
        Entitlement lEnt = new Entitlement(
            Name = 'Pós Venda - SAC',
        	AccountId = aAccountId
        );
        return lEnt;
    }
    

    /* HELPERS */
    private static String generateAccountEmail(String name, Long randomNumber){
        return removeSpacesFromText(name).replaceAll( '\\s+', '') + randomNumber + '@mail.com';
    }

    private static String removeSpacesFromText(String text){
        return text.replaceAll( '\\s+', '');
    }
}
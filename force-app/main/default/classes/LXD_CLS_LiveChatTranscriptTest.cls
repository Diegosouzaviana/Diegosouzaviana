@isTest
public class LXD_CLS_LiveChatTranscriptTest {
	@TestSetup
    static void makeData(){
        User lUser = LXD_CLS_SObjectFactory.CreateUserMinimum();
        insert lUser;
        system.debug('Usuário teste: '+lUser);
        
        PermissionSetAssignment lPSA = LXD_CLS_SObjectFactory.CreatePermissionSAC(lUser);
        insert lPSA;
        system.debug('Permissão teste: '+lPSA);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
            Account lAcc = LXD_CLS_SObjectFactory.CreateAccount();
            insert lAcc;
            system.debug('Conta teste: '+lAcc);
            
            Entitlement lEnt = LXD_CLS_SObjectFactory.CreateEntitlement(lAcc.Id);
            insert lEnt;
            system.debug('Direito teste: '+lEnt);
            
            Case lCase = LXD_CLS_SObjectFactory.CreateCaseSolicitacao(lUser.Id, 'CaseTranscript');
            insert lCase;
            system.debug('Caso teste1: '+lCase);
            
            Case lCase2 = LXD_CLS_SObjectFactory.CreateCaseSolicitacao(lUser.Id, 'CaseMessaging');
            insert lCase2;
            system.debug('Caso teste2: '+lCase);
            
            LiveChatVisitor lLiveChatVisitor = LXD_CLS_SObjectFactory.CreateLiveChatVisitor();
            insert lLiveChatVisitor;
            system.debug('Visitante do chat teste: '+lLiveChatVisitor);
            
            LiveChatTranscript lLiveChatTranscript = LXD_CLS_SObjectFactory.CreateLiveChatTranscript(lCase.Id, lLiveChatVisitor.Id);
            insert lLiveChatTranscript;
            system.debug('Transcrição do chat teste: '+lLiveChatTranscript);
            
            MessagingChannel lMessagingChannel = LXD_CLS_SObjectFactory.CreateMessagingChannel('NameChannel', 'NameLabel');
            insert lMessagingChannel;
            
            MessagingEndUser lMessagingEndUser = LXD_CLS_SObjectFactory.CreateMessagingEndUser('NameMsgEndUser', lMessagingChannel.id);
            insert lMessagingEndUser;
            
            MessagingSession lMessagingSession = LXD_CLS_SObjectFactory.CreateMessagingSession(lCase2.Id, lMessagingChannel.Id, lMessagingEndUser.Id);
            insert lMessagingSession;
            system.debug('Seção da mensagem teste: '+ lMessagingSession);
        }
    }
    
    @isTest
    public static void LiveChatTranscriptTest(){
        User lUser = [SELECT Id FROM User WHERE LastName = 'Minimum' LIMIT 1];
        LiveChatTranscript lLiveChatTranscript = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        lLiveChatTranscript.OwnerId = lUser.Id;
        update lLiveChatTranscript;
        
        Case lCase = [SELECT Id, Status, EntitlementId FROM Case WHERE SuppliedName = 'CaseTranscript' LIMIT 1];
        system.assertEquals('Em Atendimento', lCase.Status, 'O status do caso não foi alterado');
        system.debug('Fim teste 1 _______________________________________________________');
    }
    
    @isTest
    public static void MessagingSessionTest(){
        User lUser = [SELECT Id FROM User WHERE LastName = 'Minimum' LIMIT 1];
        
        MessagingSession lMessagingSession = [SELECT Id FROM MessagingSession LIMIT 1];
        lMessagingSession.OwnerId = lUser.Id;
        update lMessagingSession;
        
        Case lCase = [SELECT Id, Status, EntitlementId FROM Case WHERE SuppliedName = 'CaseMessaging' LIMIT 1];
        system.assertEquals('Em Atendimento', lCase.Status, 'O status do caso não foi alterado');
        system.debug('Fim teste 2 _______________________________________________________');
    }
}
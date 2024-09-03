@isTest
public class LXD_CLS_GetSnapInsPreChatDataTest {
	@TestSetup
    static void makeData(){
        User lUser = LXD_CLS_SObjectFactory.CreateUserMinimum();
        insert lUser;
        system.debug('Usuário teste: '+lUser);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        	Case lCase = LXD_CLS_SObjectFactory.CreateCaseSolicitacao(lUser.Id);
            lCase.UserId__c = lUser.Id;
        	insert lCase;
        	system.debug('Caso teste: '+lCase);
        
        	LiveChatVisitor lLiveChatVisitor = LXD_CLS_SObjectFactory.CreateLiveChatVisitor();
        	insert lLiveChatVisitor;
        	system.debug('Visitante do chat teste: '+lLiveChatVisitor);
            
        	LiveChatTranscript lLiveChatTranscript = LXD_CLS_SObjectFactory.CreateLiveChatTranscript(lCase.Id, lLiveChatVisitor.Id);
            lLiveChatTranscript.ChatKey = 'teste';
        	insert lLiveChatTranscript;
        	system.debug('Transcrição do chat teste: '+lLiveChatTranscript);
        }
    }
    @isTest
    public static void getSnapInsPrechatDataTest(){
        
        User lUser = [SELECT Id FROM User WHERE LastName = 'Minimum' LIMIT 1];
        Case lCase = [SELECT Id FROM Case LIMIT 1];
        LiveChatTranscript lLiveChatTranscript = [SELECT Id, ChatKey FROM LiveChatTranscript LIMIT 1];
        
        List<LXD_CLS_GetSnapInsPreChatData.PrechatInput> lInputLst = new List<LXD_CLS_GetSnapInsPreChatData.PrechatInput>();
        LXD_CLS_GetSnapInsPreChatData.PrechatInput lInput = new LXD_CLS_GetSnapInsPreChatData.PrechatInput();
        lInput.aChatKey = lLiveChatTranscript.ChatKey;
        lInputLst.add(lInput);
        
        List<LXD_CLS_GetSnapInsPreChatData.PrechatOutput> lPrechatOutputLst = LXD_CLS_GetSnapInsPreChatData.getSnapInsPrechatData(lInputLst);
        System.debug('lPrechatOutputLst: '+lPrechatOutputLst);
        
        System.assertEquals(lUser.Id, lPrechatOutputLst[0].aUserId, 'Não retornou o usuário.');
        System.assertEquals(lCase.Id, lPrechatOutputLst[0].aCaseId, 'Não retornou o caso.');
    }
}
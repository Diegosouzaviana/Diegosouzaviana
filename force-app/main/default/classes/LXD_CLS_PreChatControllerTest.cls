@isTest
public class LXD_CLS_PreChatControllerTest {
	@TestSetup
    static void makeData(){
        User lUser = LXD_CLS_SObjectFactory.CreateUserMinimum();
        insert lUser;
        system.debug('Usuário teste: '+lUser);
    }
    @isTest
    public static void getCurrentUserTest(){
        User lUser = [SELECT Id FROM User WHERE Lastname = 'Minimum' LIMIT 1];
        system.debug('lUser.Id: '+lUser.Id);
        String lUserJson = '';
        system.runAs(lUser){
            lUserJson = LXD_CLS_PreChatController.getCurrentUser();
        }
        system.debug('json deserialize: '+JSON.deserializeUntyped(lUserJson));
        
        Map<String,Object> lUserMap = (Map<String,Object>) JSON.deserializeUntyped(lUserJson);
        system.debug('lUserMap.Id: '+lUserMap.get('userId'));
        system.assertEquals(lUser.Id, lUserMap.get('userId'), 'Não encontrou o usuário correto.');
    }
}
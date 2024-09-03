/*
*   @author: Misael Ribas
*   @since: 2023/01/18
*   @className: LXD_CLS_GetLinkToBotTest
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2023/01/20            Wesley Prado      Fix: Make returnLinkBillNoCommunityTest run as minimum access user 🐛
*   2023/01/20            Wesley Prado      Refactor: use createAccount to generate accounts ♻️
*   2023/01/18            Misael Ribas      Class restructuring
*   ====================================================
*/
@isTest
public class LXD_CLS_GetLinkToBotTest {
    @TestSetup
    static void makeData(){
        User adminUser = LXD_CLS_SObjectFactory.CreateUserADM();
        User minimumUser = LXD_CLS_SObjectFactory.CreateUserMinimum('Minimum GLTBT');
        insert new List<User>{adminUser, minimumUser};
        
        System.runAs(adminUser){
            Account lAcc = LXD_CLS_SObjectFactory.createAccount('Test Account', '01493075004', LXD_CLS_SObjectFactory.AccountRTEnum.CUSTOMER);
            insert lAcc;
        }
    }
    
    @isTest
    public static void returnLinkBillNoCommunityTest(){
        Account lAcc = [SELECT Id FROM Account LIMIT 1];
        system.assertEquals(false,lAcc == null,'A Conta não foi encontrada');
        
        User minimumUser = [SELECT Id FROM User WHERE LastName = 'Minimum GLTBT' LIMIT 1];

        LXD_CLS_GetLinkToBot.ClientInput lInput = new LXD_CLS_GetLinkToBot.ClientInput();
        lInput.lAccountId = lAcc.Id;
        lInput.lbillCode = '123456';
        List<LXD_CLS_GetLinkToBot.ClientOutput> lOutputLst = null;
        
        Test.startTest();
        System.runAs(minimumUser){
            lOutputLst  = LXD_CLS_GetLinkToBot.getLink(new List<LXD_CLS_GetLinkToBot.ClientInput>{lInput});
        }
        Test.stopTest();
        
        system.assertEquals(true, lOutputLst != null, 'A lista não deve ser null.');
        system.assertEquals(false, lOutputLst.isEmpty(), 'A classe não retornou nenhum valor.');
        system.assertEquals(true, lOutputLst[0].lLink != null, 'A classe não retornou um link.');
        system.assertEquals(200, lOutputLst[0].lStatusCode, 'Houve algum problema, a classe retornou um código diferente de 200.');
    }
}
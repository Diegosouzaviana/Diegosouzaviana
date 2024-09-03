@isTest
public class LXD_CLS_SendEmail_TST {
    
    @isTest
    static void TestSendEmail(){
        List<LXD_CLS_SendEmail.ClientOutput> lClientOutputLst = new List<LXD_CLS_SendEmail.ClientOutput>();
        
        LXD_CLS_SendEmail.ClientInput testeCli2 = new LXD_CLS_SendEmail.ClientInput();
        testeCli2.lEmail = 'mribas@labsxd.com';
        testeCli2.lCpf = '42088082093';
        List<LXD_CLS_SendEmail.ClientInput> ltesteList2 = new List<LXD_CLS_SendEmail.ClientInput>();
        ltesteList2.Add(testeCli2);
        test.startTest();
        lClientOutputLst = LXD_CLS_SendEmail.SendEmail(ltesteList2);
        test.stopTest();
        
		system.assertEquals(true, lClientOutputLst[0].lEmailEnviado,'Algo deu errado!');
    }
}
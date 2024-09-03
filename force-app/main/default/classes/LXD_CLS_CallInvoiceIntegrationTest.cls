@isTest
public class LXD_CLS_CallInvoiceIntegrationTest {
	@isTest
    static void TestSendInvoices(){
        List<LXD_CLS_CallInvoiceIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_CallInvoiceIntegration.ClientOutput>();
        
        LXD_CLS_CallInvoiceIntegration.ClientInput testeCli = new LXD_CLS_CallInvoiceIntegration.ClientInput();
        testeCli.lCPF = '12345678910';
        List<LXD_CLS_CallInvoiceIntegration.ClientInput> ltesteList = new List<LXD_CLS_CallInvoiceIntegration.ClientInput>();
        ltesteList.Add(testeCli);
        test.startTest();
        lClientOutputLst = LXD_CLS_CallInvoiceIntegration.SendInvoices(ltesteList);
        test.stopTest();
        
        system.debug('lClientOutputLst: '+lClientOutputLst);
		system.assertEquals(false,lClientOutputLst[0].IntegrationError,'A integração teve algum erro!');
        system.debug('Fim teste 1');
    }
    
    @isTest
    static void TestSendInvoicesClientNull(){
        List<LXD_CLS_CallInvoiceIntegration.ClientInput> ltesteList = new List<LXD_CLS_CallInvoiceIntegration.ClientInput>();
        List<LXD_CLS_CallInvoiceIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_CallInvoiceIntegration.ClientOutput>();
        test.startTest();
        lClientOutputLst = LXD_CLS_CallInvoiceIntegration.SendInvoices(ltesteList);
        test.stopTest();
        
        system.debug('lClientOutputLst: '+lClientOutputLst);
		system.assertEquals(true,lClientOutputLst[0].IntegrationError,'A integração deveria ter retornado com erro!');
        system.debug('Fim teste 2');
    }
}
/*
*   @author: Misael Ribas
*   @since:  2022/12/20
*   @className: LXD_CLS_GetBillIntegration
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/11/16      Misael Ribas        Class creation.
*   2023/05/30      Misael Ribas        fix: change in test scenarios after the implementation of the integration.
*   ====================================================
*/
@isTest
public class LXD_CLS_GetBillIntegrationTest {
    
    @TestSetup
    static void makeData(){
        Account lAcc = LXD_CLS_SObjectFactory.CreateAccount();
		insert lAcc;
        Contract lContract = LXD_CLS_SObjectFactory.CreateContract(lAcc.Id);
        insert lContract;
        lContract.Status = 'BLOQUEADO';
        update lContract;
    }
    
    @isTest
    static void GetBillIntegration(){
		List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
		LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('13534759800');
        input.lAccountId = [SELECT Id FROM Account WHERE Name = 'Desktop' LIMIT 1].Id;
        input.lCPF = '13534759800';
        Date date5 = system.today() - 6; 
        Date date50 = system.today() - 50; 
        input.ResponseTest = '{  "Boleto": [    {      "message": "null",      "id": 26065218,      "bank": "ITAU",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BKZUUxRVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2210004202",      "dueDate": "17/10/2022",      "status": "Em Atraso",      "amount": 29.8    },    {      "message": "null",      "id": 26473407,      "bank": "13",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BKZUUxVVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2211004202",      "dueDate": "16/11/2022",      "status": "Em Atraso",      "amount": 14.9    },    {      "message": "null",      "id": 27320645,      "bank": "13",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BOZDAxVVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2301004202",      "dueDate": "16/01/2023",      "status": "Em Atraso",      "amount": 14.9    },    {      "message": "null",      "id": 27758589,      "bank": "13",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BOZDAxcVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2302004202",      "dueDate": "15/02/2023",      "status": "Em Atraso",      "amount": 14.9    },    {      "message": "null",      "id": 28673123,      "bank": "13",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BOZDA1RVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2304004202",      "dueDate": "17/04/2023",      "status": "Em Atraso",      "amount": 14.9    },    {      "message": "null",      "id": 29142513,      "bank": "13",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BOZDA1VVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2305004202",      "dueDate": "15/05/2023",      "status": "Em Atraso",      "amount": 14.9    },    {      "message": "null",      "id": 29671311,      "bank": "32",      "pdfLink": "https://api-dev.desktop.com.br/custumerService/api/v3/customer/service/charge/billet/Umlrb1JrcEFLU3BLWkRBNE1qTXBLRUFqVlVVb0tVUkZVMHRVVDFBeE9UazVUV3BOZDA1cVFYZE9SRWwzVFdjOVBRPT0=.pdf",      "codigoCobranca": "2306004202",      "dueDate": "15/06/2023",      "status": "Em Aberto",      "amount": 14.9    },    {      "message": "Os documentos passados não estão vinculados"    }  ],  "statusCode": ""}';
            /*'{"Boleto": ['+
        						'{"id": 26065218,"bank": "ITAU","pdfLink": "link","codigoCobranca": "2210004202","dueDate": "'+date50.format()+'","status": "Em Atraso","message": "null","amount": 29.8},'+
        						'{"id": 26473407,"bank": "13","pdfLink": "link","codigoCobranca": "2211004202","dueDate": "'+date5.format()+'","status": "Em Atraso","message": "null","amount": 14.9}'+
            					'],"statusCode": 200}';*/
		List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};
        
		lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        system.assertEquals(true, lClientOutputLst[0].aClientStatus, 'Cliente bloqueado não funcionou');
        system.assertEquals(false, lClientOutputLst[0].IntegrationError, 'IntegrationError não funcionou');
        system.assertEquals(true, lClientOutputLst[0].aCustomerTwoInvoiceDelays, '2 contas com atraso não funcionou');
    }
    
    @isTest
    static void TestError400(){
		List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
		LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('13534759800');
        input.lAccountId = [SELECT Id FROM Account WHERE Name = 'Desktop' LIMIT 1].Id;
        input.lCPF = '13534759800';
        input.ResponseTest = '{"Boleto": [],"statusCode": 400}';
		List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};
        
		lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        system.assertEquals('Os documentos passados não estão vinculados.', lClientOutputLst[0].ErrorMessage, 'O cenário 400 não funcionou, a mensagem enviada esta incorreta');
    }
    
    @isTest
    static void TestError404(){
		List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
		LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('13534759800');
        input.lAccountId = [SELECT Id FROM Account WHERE Name = 'Desktop' LIMIT 1].Id;
        input.lCPF = '13534759800';
        input.ResponseTest = '{"Boleto": [],"statusCode": 404}';
		List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};
        
		lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        system.assertEquals('Os documentos passados para este cliente não foram encontrados.', lClientOutputLst[0].ErrorMessage, 'O cenário 404 não funcionou, a mensagem enviada esta incorreta');
    }
    
	/*@isTest
    static void getBillTest(){
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('12345678910');
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};

        Date todayDate = Date.today();
        string date5Days = string.valueOf(todayDate.addDays(-5).Day()+'/'+todayDate.addDays(-5).month()+'/'+todayDate.addDays(-5).Year());
        string date50Days = string.valueOf(todayDate.addDays(-50).Day()+'/'+todayDate.addDays(-50).month()+'/'+todayDate.addDays(-50).Year());
        string lJsonResponse = '[{"codigoCobranca": "17262581","amount": 101.5,"status": "Em aberto","dueDate": "'+date5Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00028504826 0"}'+',{"codigoCobranca": "17262847","amount": 111.5,"status": "Em aberto","dueDate": "'+date50Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00075508655 0"}]';
        List<Object> lBoletoLst = (List<Object>) json.deserializeUntyped(lJsonResponse);

        Test.startTest();
            LXD_CLS_GetBillIntegration.mockResponse = new Map<String,Object>{'Boleto' => lBoletoLst};
            lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        Test.stopTest();
        
        Assert.areEqual(false,lClientOutputLst[0].IntegrationError,'Sucesso! Retornou multiplos boletos');
    }

    @isTest
    static void multipleBillsTest(){
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('12345678910');
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};

        Date todayDate = Date.today();
        string date5Days = string.valueOf(todayDate.addDays(-5).Day()+'/'+todayDate.addDays(-5).month()+'/'+todayDate.addDays(-5).Year());
        string date50Days = string.valueOf(todayDate.addDays(-50).Day()+'/'+todayDate.addDays(-50).month()+'/'+todayDate.addDays(-50).Year());
        string lJsonResponse = '[{"codigoCobranca": "17262581","amount": 101.5,"status": "Em aberto","dueDate": "'+date5Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00028504826 0"}'+',{"codigoCobranca": "17262847","amount": 111.5,"status": "Em aberto","dueDate": "'+date50Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00075508655 0"}'+',{"codigoCobranca": "17262581","amount": 101.5,"status": "Em aberto","dueDate": "'+date5Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00028504826 0"}]';
        List<Object> lBoletoLst = (List<Object>) json.deserializeUntyped(lJsonResponse);

        Test.startTest();
            LXD_CLS_GetBillIntegration.mockResponse = new Map<String,Object>{'Boleto' => lBoletoLst};
            lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        Test.stopTest();
        
        Assert.areEqual(false,lClientOutputLst[0].IntegrationError,'Sucesso! Retornou multiplos boletos');
    }
    
    @isTest
    static void getBillWithoutCpfTest(){
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput();
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>();
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();

        Test.startTest();
            lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        Test.stopTest();
        
		Assert.areEqual(true,lClientOutputLst[0].IntegrationError,'Não possui os parametros necessarios');
    }

    @isTest
    static void singleBillTest(){
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('12345678910');
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};

        Date todayDate = Date.today();
        string date50Days = string.valueOf(todayDate.addDays(-50).Day()+'/'+todayDate.addDays(-50).month()+'/'+todayDate.addDays(-50).Year());
        string lJsonResponse = '[{"codigoCobranca": "17262847","amount": 111.5,"status": "Em aberto","dueDate": "'+date50Days+'",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00075508655 0"}]';
        List<Object> lBoletoLst = (List<Object>) json.deserializeUntyped(lJsonResponse);

        Test.startTest();
            LXD_CLS_GetBillIntegration.mockResponse = new Map<String,Object>{'Boleto' => lBoletoLst};
            lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        Test.stopTest();
        
        Assert.areEqual(false,lClientOutputLst[0].IntegrationError,'Sucesso! Retornou apenas um boleto');
    }

    @isTest
    static void billNotAvailableTest(){
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('12345678910');
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};

        Test.startTest();
            LXD_CLS_GetBillIntegration.mockResponse = new Map<String,Object>();
            lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
        Test.stopTest();
        
        Assert.areEqual(true,lClientOutputLst[0].IntegrationError,'Não possui boletos disponiveis');
    }

    @isTest
    static void billErrorTest(){
        List<LXD_CLS_GetBillIntegration.ClientOutput> lClientOutputLst = new List<LXD_CLS_GetBillIntegration.ClientOutput>();
        LXD_CLS_GetBillIntegration.ClientInput input = new LXD_CLS_GetBillIntegration.ClientInput('12345678910');
        List<LXD_CLS_GetBillIntegration.ClientInput> inputList = new List<LXD_CLS_GetBillIntegration.ClientInput>{input};

        string lJsonResponse = '[{"codigoCobranca": "17262847","amount": 111.5,"status": "Em aberto","dueDate": "",'+'"payload": "84680000001 6 57360106000 3 00000000000 0 00075508655 0"}]';
        List<Object> lBoletoLst = (List<Object>) json.deserializeUntyped(lJsonResponse);

        Test.startTest();
            try {
                LXD_CLS_GetBillIntegration.mockResponse = new Map<String,Object>{'Boleto' => lBoletoLst};
                lClientOutputLst = LXD_CLS_GetBillIntegration.GetBill(inputList);
            } catch (Exception e) {
                Assert.areEqual(true,lClientOutputLst[0].IntegrationError,'Error');
            }
        Test.stopTest();
    }*/    
}
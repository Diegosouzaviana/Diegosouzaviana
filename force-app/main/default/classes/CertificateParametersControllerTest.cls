@isTest
public with sharing class CertificateParametersControllerTest {
    
    @isTest
    static void testMethod_getParameters(){
        Test.startTest();
        IntegrationData__mdt response = CertificateParametersController.getParameters();
        System.Assert.areNotEqual(null, response);
        Test.stopTest();
    }

    @isTest
    static void testMethod_saveParameters(){
        IntegrationData__mdt param = new IntegrationData__mdt();
        param.ReferenceMaxSignal__c = 1;
        param.CtoClientThreshold__c = 1;
        param.ReferenceSignalTolerance__c = 1;
        Test.startTest();
        CertificateParametersController.SaveResponse response = CertificateParametersController.saveParameters(param);
        System.Assert.areEqual(true, response.success);
        Test.stopTest();
        IntegrationData__mdt mdt = CertificateParametersController.getParameters();
    }

}
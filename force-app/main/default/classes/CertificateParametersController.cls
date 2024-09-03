public with sharing class CertificateParametersController implements Metadata.DeployCallback {
    
    @AuraEnabled
    public static IntegrationData__mdt getParameters(){
        return IntegrationData__mdt.getInstance('Desktop_Service');
    }

    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        DeployMetadataEvent__e event = new DeployMetadataEvent__e();
        if (result.status == Metadata.DeployStatus.Succeeded) {
            event.Success__c = true;
        } else {
            event.Success__c = false;
            event.Message__c = result.errorMessage;
        }
        EventBus.publish(event); 
    }

    @AuraEnabled
    public static SaveResponse saveParameters(IntegrationData__mdt param){
        SaveResponse response = new SaveResponse();

        IntegrationData__mdt tcm = IntegrationData__mdt.getInstance('Desktop_Service');
        Id customMetadataId = tcm.Id;

        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = 'IntegrationData__mdt.Desktop_Service'; //custom metadata name
        customMetadata.label = 'Desktop Service';

        Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue(); 
        customField1.field = 'ReferenceMaxSignal__c'; 
        customField1.value = param.ReferenceMaxSignal__c;
        customMetadata.values.add(customField1);

        Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue(); 
        customField2.field = 'CtoClientThreshold__c'; 
        customField2.value = param.CtoClientThreshold__c;
        customMetadata.values.add(customField2);

        Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue(); 
        customField3.field = 'ReferenceSignalTolerance__c'; 
        customField3.value = param.ReferenceSignalTolerance__c;
        customMetadata.values.add(customField3);

        Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue(); 
        customField4.field = 'SecondValidationKeyActivated__c'; 
        customField4.value = param.SecondValidationKeyActivated__c;
        customMetadata.values.add(customField4);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        CertificateParametersController callback = new CertificateParametersController();

        String jobId = Test.isRunningTest() ? '' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        response.success = true;
        response.jobId = jobId;

        return response;
    }

    public class SaveResponse {
        @AuraEnabled public Boolean success {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String jobId {get;set;}
    }

}
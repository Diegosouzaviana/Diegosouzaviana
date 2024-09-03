/*
*   @author: Wesley Prado
*   @since: 2022/12/28
*   @className: LXD_ContractCaseDataSource
*   @description: class that serves as data source to FLX_ContractCaseComboChildV3 
*
*   =================== FIX LOG ========================
*   aaaa/mm/dd      Dev Name        Description.
*   ====================================================
*/
global with sharing class LXD_ContractCaseDataSource implements vlocity_cmt.VlocityOpenInterface {
    global enum AVAILABLE_NODES { caseId }

    global static Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String, Object> options){
        if(methodName == 'getData') getData(inputMap, outMap);
        else return false;

        return true;
    }

    global static void getData(Map<String,Object> inputMap, Map<String,Object> outMap){
        if(!inputMap.containsKey(AVAILABLE_NODES.caseId.name()) || String.isBlank((String) inputMap.get(AVAILABLE_NODES.caseId.name()))){
            LXD_VlocityUtils.badRequest(outMap, AVAILABLE_NODES.caseId.name() + ' is required.');
            return;
        }

        try {
           Map<String, Boolean> permsetNames = getAgentsPermissionSetNames();
            Case caseDetail = getCaseDetail((String) inputMap.get(AVAILABLE_NODES.caseId.name()));

            if(caseDetail == null){
                LXD_VlocityUtils.badRequest(outMap, 'Case not found.');
                return;
            }
            
            LXD_CallIntegrationProcedureFromSFAPI.InputDTO inputDTO = new LXD_CallIntegrationProcedureFromSFAPI.InputDTO();
            inputDTO.CaseId = (String) inputMap.get(AVAILABLE_NODES.caseId.name());
            inputDTO.procedureName = 'LXD_ApiMassive_ProblemCase';
            List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO> inputList = new List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO>{inputDTO};
            List<LXD_CallIntegrationProcedureFromSFAPI.outputDTO> outputProblemMassive = LXD_CallIntegrationProcedureFromSFAPI.invokeIP(inputList);
            
            permsetNames.put('ApiMassive',outputProblemMassive[0].result.boleano);
    
            for(String userPemSet : getUserPermissionSetNames()){
                if(permsetNames.containsKey(userPemSet)) permsetNames.put(userPemSet, true);
            }
    
            Map<String, Object> response = new Map<String, Object>{
                'Case' => caseDetail,
                'PermissionSets' => permsetNames
            };
                System.debug('response '+ response);

            LXD_VlocityUtils.success(outMap, response);
        } catch (Exception e) {
            LXD_VlocityUtils.debugErrorMessage(e);
            LXD_VlocityUtils.internalServer(outMap, e.getMessage());
        }
    }

    /* HELPERS */
    private static Map<String, Boolean> getAgentsPermissionSetNames(){
        Map<String, Boolean> permissionSetNames = new Map<String, Boolean>();

        for(ContractCaseConfig__mdt metadata : [SELECT QualifiedApiName FROM ContractCaseConfig__mdt]){
            permissionSetNames.put(metadata.QualifiedApiName, false);
        }

        return permissionSetNames;
    }
    private static Set<String> getUserPermissionSetNames(){
        Set<String> userPemSet = new Set<String>();

        for(PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]){
            userPemSet.add(psa.PermissionSet.Name);
        }

        return userPemSet;
    }
    private static Case getCaseDetail(String caseId){
        Case caseDetail = null;
        List<Case> caseList = [SELECT Id, AccountId, FiltroBotaoWO__c, Area_de_atendimento__c, WOCriada__c, Status, AssetId, Case.Asset.Name, Case.Asset.vlocity_cmt__RecurringCalculatedPrice__c, Case.Asset.vlocity_cmt__BillingAccountId__r.LegacyId__c, Case.Asset.PlanLogin__c, Contrato__r.ContractNumber, Contrato__r.status, Contrato__r.LXD_TrustUnlock__c, Contrato__r.LXD_TrustUnlockDate__c, Contrato__r.RecordType.Name, Contrato__r.Id, motive__c, submotive__c FROM Case WHERE Id = :caseId];

        if(!caseList.isEmpty()) caseDetail = caseList[0];

        return caseDetail;
    }
 

     
    public class LXD_ContractCaseDataSourceException extends Exception{}
}
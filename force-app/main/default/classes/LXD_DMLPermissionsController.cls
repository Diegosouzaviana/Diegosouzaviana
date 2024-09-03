/*
*   @author: Wesley Prado
*   @since: 2022/10/22
*   @className: LXD_DMLPermissionsController
*   @description: class that controls DML permissions to execute LXD_BypassDMLPermissions methods.
*
*   =================== FIX LOG ========================
*   2022/10/31            Wesley prado      Add enum AVAILABLE_NODES to document and organize the available nodes of this Remote Action.
*   ====================================================
*/
global with sharing class LXD_DMLPermissionsController implements vlocity_cmt.VlocityOpenInterface{
    private static final String REGEX_SPACE_COMMA = ',\\s+?';
    public enum AVAILABLE_NODES { featureAPIName }

    global static Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String, Object> options){
        if(methodName == 'manipulateData') manipulateDataPermissionController(methodName, inputMap, outMap, options);
        return true;
    }

    private static void manipulateDataPermissionController(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String, Object> options){
        try {
            if(validatePermissions(inputMap)) LXD_BypassDMLPermissions.invokeMethod(methodName, inputMap, outMap, options);
            else throw new UpsertDataPermissionControllerException('Você não tem permissão para executar este método ou a permissão personalizada foi digitada incorretamente. Fale com seu administrador.');

        } catch (Exception ex) {
            String errorMessage = ex.getMessage();
            System.debug('[ERROR]: '+ errorMessage + '\n[STACKTRACE]: ' + ex.getStackTraceString());
            
            LXD_BypassDMLPermissions.setDMLResponse(outMap, errorMessage, false);
        }
    }

    private static Boolean validatePermissions(Map<String,Object> inputMap){
        Boolean hasCustomPermission = true;
        String operationType = (String) inputMap.get(LXD_BypassDMLPermissions.AVAILABLE_NODES.operationType.name());
        if(String.isBlank(operationType)) throw new UpsertDataPermissionControllerException('operationType é obrigatório. Valores válidos: insert, update, delete e upsert');
        
        String developerName = (String) inputMap.get(AVAILABLE_NODES.featureAPIName.name());
        if(developerName == null) throw new UpsertDataPermissionControllerException('featureAPIName é obrigatório.');
        
        LXD_APIPermissionSettings__mdt apiPermissions = LXD_APIPermissionSettings__mdt.getInstance(developerName);
        if(apiPermissions == null) throw new UpsertDataPermissionControllerException('Não foi encontrada instância para o metadado "Configuração de permissões API" para o nome de API: ' + developerName);

        Map<String, Set<String>> customPermissionMapSet = new Map<String, Set<String>>{
            'insert'=> new Set<String>(),
            'update'=> new Set<String>(),
            'delete'=> new Set<String>()
        };

        if(apiPermissions.LXD_CreatePermissions__c != null){
            customPermissionMapSet.get('insert').addAll(apiPermissions.LXD_CreatePermissions__c.split(REGEX_SPACE_COMMA));
        }
        if(apiPermissions.LXD_EditPermissions__c != null){
            customPermissionMapSet.get('update').addAll(apiPermissions.LXD_EditPermissions__c.split(REGEX_SPACE_COMMA));
        }
        if(apiPermissions.LXD_DeletePermissions__c != null){
            customPermissionMapSet.get('delete').addAll(apiPermissions.LXD_EditPermissions__c.split(REGEX_SPACE_COMMA));
        }

        String operationTypeLowerCased = operationType.toLowerCase();
        
        if(operationTypeLowerCased == 'insert'){
            hasCustomPermission = checkPermissionHelper(customPermissionMapSet.get('insert'));
        }
        else if(operationTypeLowerCased == 'update') {
            hasCustomPermission = checkPermissionHelper(customPermissionMapSet.get('update'));
        }
        else if(operationTypeLowerCased == 'delete') {
            hasCustomPermission = checkPermissionHelper(customPermissionMapSet.get('delete'));
        }
        else if(operationTypeLowerCased == 'upsert') {
            hasCustomPermission = checkPermissionHelper(customPermissionMapSet.get('insert')) && checkPermissionHelper(customPermissionMapSet.get('update'));
        }
        else throw new UpsertDataPermissionControllerException('operationType inválido: ' + operationType + '. Valores válidos: insert, update, delete e upsert.');

        return hasCustomPermission;
    }

    private static Boolean checkPermissionHelper(Set<String> permissionApiNameList){
        Boolean hasCustomPermission = true;
        for(String permissionApiName : permissionApiNameList){
            hasCustomPermission = hasCustomPermission && FeatureManagement.checkPermission(permissionApiName);
        }

        return hasCustomPermission;
    }

    public class UpsertDataPermissionControllerException extends Exception {}
}
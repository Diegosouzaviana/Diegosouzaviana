/*
*   @author: Wesley Prado
*   @since: 2022/10/21
*   @className: LXD_BypassDMLPermissions
*   @description: class that executes DML operations as System Mode.
*
*   =================== FIX LOG ========================
*   2022/10/31            Wesley Prado      Add advanced config options like field datatype.
*   2022/10/31            Wesley prado      Add enum AVAILABLE_NODES to document and organize the available nodes of this Remote Action.
*   2022/12/08            Wesley prado      Refactor: call LXD_VlocityUtils method to log the error.
*   ====================================================
*/
global without sharing class LXD_BypassDMLPermissions implements vlocity_cmt.VlocityOpenInterface{
    private static final Set<String> DATA_TYPES = new Set<String>{'integer', 'double', 'long', 'date', 'datetime', 'string', 'id', 'boolean'};
    public enum AVAILABLE_NODES { operationType, objectName, sObjectNode, value, datatype }

    global static Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String, Object> options){
        if(methodName == 'manipulateData') manipulateData(inputMap, outMap);

        return true;
    }

    public static void manipulateData(Map<String,Object> inputMap, Map<String,Object> outMap){
        try {
            String operationType = (String) inputMap.get(AVAILABLE_NODES.operationType.name());
            if(String.isBlank(operationType)) throwExceptionHelper('operationType é obrigatório. Valores válidos: insert, update, delete e upsert.');

            List<sObject> sObjectList = inputToSObject(inputMap);

            if(!sObjectList.isEmpty()) executeDML(operationType, sObjectList);
            setDMLResponse(outMap, sObjectList, true);
            
        } catch (Exception ex) {
            LXD_VlocityUtils.debugErrorMessage(ex);
            String errorMessage = ex.getMessage();
            setDMLResponse(outMap, errorMessage, false);
        }
    }

    private static List<sObject> inputToSObject(Map<String,Object> inputMap){
        String objectName = (String) inputMap.get(AVAILABLE_NODES.objectName.name());
        if(String.isBlank(objectName)) throwExceptionHelper('objectName é obrigatório.');
        
        Map<String, Object> objectMap = null;
        List<Map<String, Object>> objectList = null;

        if(inputMap.get(AVAILABLE_NODES.sObjectNode.name()) instanceof String){
            String node = (String) inputMap.get(AVAILABLE_NODES.sObjectNode.name());
            if(String.isBlank(node)) throwExceptionHelper('sObjectNode é obrigatório.');

            objectMap = (Map<String, Object>) JSON.deserializeUntyped(node);
        }
        else if(inputMap.get(AVAILABLE_NODES.sObjectNode.name()) instanceof Map<String, Object>){
            objectMap = (Map<String, Object>) inputMap.get(AVAILABLE_NODES.sObjectNode.name());
        }
        else if(inputMap.get(AVAILABLE_NODES.sObjectNode.name()) instanceof List<Map<String, Object>>){
            objectList = (List<Map<String, Object>>) inputMap.get(AVAILABLE_NODES.sObjectNode.name());
        }
        else throwExceptionHelper('sObjectNode inválido.');

        List<sObject> sObjectList = new List<sObject>();
        if(objectMap != null) sObjectList.add(sObjectFactory(objectName, objectMap));
        if(objectList != null) sObjectList.addAll(generateMultipleSObjects(objectName, objectList));

        return sObjectList;
    }

    private static sObject sObjectFactory(String objectName, Map<String, Object> objectMap){
        Schema.SObjectType sObjSchemaMap = Schema.getGlobalDescribe().get(objectName);
        if(sObjSchemaMap == null) throwExceptionHelper('sObject não encontrado: ' + objectName);

        sObject sObj = sObjSchemaMap.newSObject();

        for(String fieldName : objectMap.keySet()){
            if(objectMap.get(fieldName) instanceof String) sObj.put(fieldName, objectMap.get(fieldName));
            else if(objectMap.get(fieldName) instanceof Map<String, Object>){
                // In case the field dont have directly the value, but a config map with the value and the datatype
                Map<String, Object> fieldConfig = (Map<String, Object>) objectMap.get(fieldName);
                if(!fieldConfig.containsKey(AVAILABLE_NODES.value.name())) throwExceptionHelper('value é obrigatório para o campo: ' + fieldName);

                String value = fieldConfig.get(AVAILABLE_NODES.value.name()) instanceof String ? (String) fieldConfig.get(AVAILABLE_NODES.value.name()) : String.valueOf(fieldConfig.get(AVAILABLE_NODES.value.name()));

                if(fieldConfig.containsKey(AVAILABLE_NODES.datatype.name()) && !String.isBlank((String) fieldConfig.get(AVAILABLE_NODES.datatype.name()))){
                    sObj.put(fieldName, convertValue(value, ((String) fieldConfig.get(AVAILABLE_NODES.datatype.name())).toLowerCase()));
                }
                else sObj.put(fieldName, value);
            }
            else throwExceptionHelper('Tipo de campo inválido: ' + fieldName);
        }

        return sObj;
    }

    public static void throwExceptionHelper(String message){
        throw new LXD_BypassDMLPermissionsException(message);
    }

    private static Object convertValue(String value, String datatype){
        Object convertedValue = null;

        if(dataType == 'integer') convertedValue =  Integer.valueOf(value);
        else if(dataType == 'double') convertedValue =  Double.valueOf(value);
        else if(dataType == 'long') convertedValue =  Long.valueOf(value);
        else if(dataType == 'date') convertedValue =  Date.parse(value);
        else if(dataType == 'datetime') convertedValue =  Datetime.parse(value);
        else if(dataType == 'string') convertedValue = value; // Already a string
        else if(dataType == 'id') convertedValue =  Id.valueOf(value);
        else if(dataType == 'boolean') convertedValue =  Boolean.valueOf(value);
        else throwExceptionHelper('Tipo de dado inválido: ' + datatype);

        return convertedValue;
    }

    private static List<sObject> generateMultipleSObjects(String objectName, List<Map<String, Object>> objectList){
        List<sObject> sObjectList = new List<sObject>();
        for(Map<String, Object> obj : objectList){
            sObjectList.add(sObjectFactory(objectName, obj));
        }

        return sObjectList;
    }

    private static void executeDML(String operationType, List<sObject> sObjectList){
        String operationTypeLowerCased = operationType.toLowerCase();
        
        if(operationTypeLowerCased == 'insert') insert sObjectList;
        else if(operationTypeLowerCased == 'update') update sObjectList;
        else if(operationTypeLowerCased == 'delete') delete sObjectList;
        else if(operationTypeLowerCased == 'upsert') upsert sObjectList;
        else throwExceptionHelper('operationType inválido: ' + operationType + '. Valores válidos: insert, update, delete e upsert.');
    }

    public static void setDMLResponse(Map<String,Object> outMap, Object response, Boolean success){
        outMap.put('Response', response);
        outMap.put('Success', success);
    }

    private class LXD_BypassDMLPermissionsException extends Exception{}
}
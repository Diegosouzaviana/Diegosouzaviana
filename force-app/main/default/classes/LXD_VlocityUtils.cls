/*
*   @company: LabsXD
*   @author: Wesley Prado
*   @since: 2022/12/02
*   @className: LXD_VlocityUtils
*   @description: Remote Action Utils class for Vlocity.
*
*   =================== UPDATE LOG ========================
*   2023/01/25      Wesley Prado        Feat: create compareDates method ✨.
*   2023/01/25      Wesley Prado        Feat: create addDaysToDate method ✨.
*   2022/12/12      Wesley Prado        Feat: create stringLength method ✨.
*   2022/12/12      Wesley Prado        Feat: create validateRegex method ✨.
*   2022/12/03      Wesley Prado        Refactor: move questionnaire methods to LXD_QuestionnaireController ♻️.
*   =======================================================
*/

global with sharing class LXD_VlocityUtils implements vlocity_cmt.VlocityOpenInterface{
    public enum DEFAULT_INPUT_NODES { value }
    public enum VALIDATEREGEX_NODES { regex }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputs,
Map<String, Object> output, Map<String, Object> options){
        if (methodName.equalsIgnoreCase('stringToBlob')) stringToBlob(inputs, output);
        else if (methodName.equalsIgnoreCase('stringLength')) stringLength(inputs, output);
        else if (methodName.equalsIgnoreCase('validateRegex')) validateRegex(inputs, output);
        else if (methodName.equalsIgnoreCase('compareDates')) compareDates(inputs, output);
        else if (methodName.equalsIgnoreCase('addDaysToDate')) addDaysToDate(inputs, output);
        else return false;

        return true;
    }

    global static void validateRegex(Map<String, Object> inputs,
    Map<String, Object> output){
        
        if(!inputs.containsKey(DEFAULT_INPUT_NODES.value.name())){
            badRequest(output, 'field "value" is required');
            return;
        }

        if(!inputs.containsKey(VALIDATEREGEX_NODES.regex.name())){
            badRequest(output, 'field "regex" is required');
            return;
        }

        try {
            String value = (String) inputs.get(DEFAULT_INPUT_NODES.value.name());
            String regex = (String) inputs.get(VALIDATEREGEX_NODES.regex.name());
            Matcher matcher = Pattern.compile(regex).matcher(value);
            
            success(output, matcher.matches());
        } catch (Exception ex) {
            debugErrorMessage(ex);
            badRequest(output, ex.getMessage());
        }
    }

    global static void stringLength(Map<String, Object> inputs,
    Map<String, Object> output){
        String valueNodeName = DEFAULT_INPUT_NODES.value.name();
        
        if(!inputs.containsKey(valueNodeName)){
            badRequest(output, 'field "value" is required');
            return;
        }

        if(!(inputs.get(valueNodeName) instanceof String)){
            badRequest(output, 'value must be a String');
            return;
        }

        success(output, ((String) inputs.get(valueNodeName)).length());
    }

    global static void stringToBlob(Map<String, Object> inputs,
    Map<String, Object> output){
        String valueNodeName = DEFAULT_INPUT_NODES.value.name();
        
        if(!inputs.containsKey(valueNodeName)){
            badRequest(output, 'field "value" is required');
            return;
        }

        if(!(inputs.get(valueNodeName) instanceof String)){
            badRequest(output, 'value must be a String');
            return;
        }

        success(output, Blob.valueOf((String) inputs.get(valueNodeName)));
    }

    //REMOVE Integration Procedure have the method DATEDIFF
    global static void compareDates(Map<String, Object> inputs,
    Map<String, Object> output){
        try{
            Date firstDate = convertDate((String) inputs.get('firstDate'));
            Date secondDate = convertDate((String) inputs.get('secondDate'));

            success(output, firstDate > secondDate);
        }
        catch(Exception e){
            badRequest(output, e.getMessage());
        }
    }

    private static Date convertDate(String stringDate){
        Pattern DatePattern = Pattern.compile('(\\d{2}\\/){2}\\d{4}');
        Matcher DateMatcher = DatePattern.matcher(stringDate);

        if(DateMatcher.matches()) return Date.parse(stringDate);
        return Date.valueOf(stringDate);
    }

    global static void addDaysToDate(Map<String, Object> inputs,
    Map<String, Object> output){
        try{
            Date newDate = ((Date) inputs.get('date')).addDays((Integer) inputs.get('days'));
            String formattedDate = String.format('{0}/{1}/{2}', new List<Object>{String.valueOf(newDate.day()).leftPad(2, '0') , String.valueOf(newDate.month()).leftPad(2, '0'), String.valueOf(newDate.year())});

            success(output, formattedDate);
        }
        catch(Exception e){
            badRequest(output, e.getMessage());
        }
    }

    /* HELPERS */
    private static void setResponse(Map<String, Object> output, Object value){
        output.put('result', value);
    }
    public static void badRequest(Map<String, Object> output, String errorMessage){
        output.put('error', 'Bad Request: ' + errorMessage);
        output.put('statusCode', 400);
        setResponse(output, null);
    }
    public static void internalServer(Map<String, Object> output, String errorMessage){
        output.put('error', 'Bad Request: ' + errorMessage);
        output.put('statusCode', 500);
        setResponse(output, null);
    }
    public static void notFound(Map<String, Object> output, String errorMessage){
        output.put('error', 'Bad Request: ' + errorMessage);
        output.put('statusCode', 404);
        setResponse(output, null);
    }
    public static void success(Map<String, Object> output, Object value){
        output.put('statusCode', 200);
        setResponse(output, value);
    }
    public static void debugErrorMessage(Exception e){
        System.debug(LoggingLevel.ERROR, e.getMessage() + ' - ' + e.getStackTraceString());
    }
}
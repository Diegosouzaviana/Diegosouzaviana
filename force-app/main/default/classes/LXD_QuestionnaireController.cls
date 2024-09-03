/*
*   @company: LabsXD
*   @author: Wesley Prado
*   @since: 2022/12/02
*   @className: LXD_QuestionnaireController
*   @description: Remote Action Controller to manipulate Case Questionnaire.
*
*   =================== UPDATE LOG ========================
*   2022/12/03      Wesley Prado        Refactor: move questionnaire methods from LXD_VlocityUtils.
*   =======================================================
*/
global with sharing class LXD_QuestionnaireController implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs,
    Map<String, Object> output, Map<String, Object> options){
        if(methodName == 'saveQuestionnaire') saveQuestionnaire(inputs, output);
        else return false;
        return true;
    }

    global static void saveQuestionnaire( Map<String, Object> inputs,
    Map<String, Object> output){
        if(!inputs.containsKey('caseId')){
            LXD_VlocityUtils.badRequest(output, 'caseId is required');
            return;
        }
        
        String caseId = (String) inputs.get('caseId');
        Map<String, Object> outputClone = output.clone();
        flatQuestionnaireMap(inputs, outputClone);

        if(!outputClone.containsKey('result') || outputClone.get('result') == null){
            output.put('error', outputClone.get('error'));
            output.put('statusCode', outputClone.get('statusCode'));
            return;
        }

        String body = (String) outputClone.get('result');
        String title = inputs.containsKey('title') ? (String) inputs.get('title') : 'Questionario: ' + caseId;

        saveQuestionnaireHelper(new Map<String, String>{
            'caseId' => caseId,
            'body' => body,
            'title' => title
        }, output);
    }

    private static void flatQuestionnaireMap(Map<String, Object> inputs,
    Map<String, Object> output){

        if(!inputs.containsKey('value')){
            LXD_VlocityUtils.badRequest(output, 'field "value" is required');
            return;
        }

        if(!(inputs.get('value') instanceof Map<String, Object>)){
            LXD_VlocityUtils.badRequest(output, 'value must be a Map<String, Object>');
            return;
        }

        Map<String, Object> questionnaireMap = (Map<String, Object>)inputs.get('value');

        String flatteredQuestionare = flatMapHelper(questionnaireMap, new Map<String, String>(), new Map<String, String>());
        LXD_VlocityUtils.success(output, flatteredQuestionare);
    }

    /* HELPERS */
    private static String flatMapHelper(Map<String, Object> questionnaireMap, Map<String, String> questionsMap, Map<String, String> answersMap){
        String response = '';
        for(String key : questionnaireMap.keySet()){
            // key = Q_someQuestion or A_someQuestion. Q for question, A for answer.
            Object value = questionnaireMap.get(key);

            if(value == null) continue;
            else if(value instanceof Map<String, Object>) flatMapHelper((Map<String, Object>)value, questionsMap, answersMap);
            else{
                String stringifiedValue = (value instanceof String ? (String) value : String.valueOf(value)).escapeHtml4();

                if(key.startsWith('Q_')) questionsMap.put(key, stringifiedValue);
                else if(key.startsWith('A_')) answersMap.put(key, stringifiedValue);
            }
        }
        List<String> questionList = new List<String>(questionsMap.keySet());

        // Reverse the list to get the questions in the correct order.
        for(Integer i = questionList.size() - 1; i >= 0; i--){
            String questionKey = questionList[i];
            String removedPrefixKey = questionKey.substring(2);
            String answerKey = 'A_' + removedPrefixKey;

            if(answersMap.containsKey(answerKey)){
                response += writeQuestion(questionsMap.get(questionKey), answersMap.get(answerKey));
            }
        }

        return response;
    }
    private static String writeQuestion(String question, String answer){
        return '<b>' + question + '</b><br/>' + answer + '<br/><br/>';
    }
    private static void saveQuestionnaireHelper(Map<String, String> questionnaireInput, Map<String, Object> output){

        try{
            ContentNote cn = new ContentNote(
                Title = questionnaireInput.get('title'),
                Content = Blob.valueOf(questionnaireInput.get('body'))
            );
            insert cn;
    
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = cn.Id,
                LinkedEntityId = questionnaireInput.get('caseId'),
                ShareType = 'V'
            );
            insert cdl;

            LXD_VlocityUtils.success(output, new Map<String, Object>{
                'ContentNote' => cn,
                'ContentDocumentLink' => cdl
            });
        }
        catch(Exception e){
            LXD_VlocityUtils.debugErrorMessage(e);
            LXD_VlocityUtils.badRequest(output, e.getMessage());
        }
    }
}
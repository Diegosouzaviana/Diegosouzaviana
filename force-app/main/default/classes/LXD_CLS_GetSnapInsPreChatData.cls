public class LXD_CLS_GetSnapInsPreChatData {
    public class PrechatInput{
        @InvocableVariable
        public String aChatKey;
    }
	public class PrechatOutput{
        @InvocableVariable
        public String aUserId;
        @InvocableVariable
        public String aCaseId;
        @InvocableVariable
        public String aChatKeyFound;
        @InvocableVariable
        public String aErrorMsg;
    }
    @InvocableMethod(label='Buscar dados do Prechat')
    public static List<PrechatOutput> getSnapInsPrechatData(List<PrechatInput> lInputLst){
        System.debug('lInputLst: '+lInputLst);
          
        String lChatKey = lInputLst[0].aChatKey;
        system.debug('lChatKey: '+lChatKey);
        List<prechatoutput> lOutputLst = new List<prechatoutput>();
        PrechatOutput lOutput = new PrechatOutput();
        try{
            if (lChatKey != null && lChatKey != ''){
                LiveChatTranscript lTranscript = [SELECT Id, CaseId, Case.UserId__c, UserId__c, ChatKey FROM LiveChatTranscript WHERE ChatKey =: lChatKey LIMIT 1];
                system.debug('lTranscript: '+lTranscript);
                Case lCase = [SELECT Id, UserId__c FROM Case WHERE Id =: lTranscript.CaseId];
                system.debug('lCase: '+lCase);
                if (lTranscript != null){
                    lOutput.aCaseId = lTranscript.CaseId;
                    lOutput.aUserId = lCase.UserId__c;
                    lOutput.aChatKeyFound = lTranscript.ChatKey;
                }
            }
        }
        catch(Exception e){
            lOutput.aErrorMsg = e.getMessage();
        }
       
        lOutputLst.add(lOutput);
        return lOutputLst;
    }
}
public class WorkOrderMotivoService {
    
    @InvocableMethod
    public static List<List<String>> getPicklistValues(List<String> picklistString){
        List<String> lista = new List<String>();
        if(picklistString[0].contains(';')){
            lista = picklistString[0].split(';');
        } else {
            lista = picklistString;
        }
          
        return new List<List<String>> { lista };
    }

}
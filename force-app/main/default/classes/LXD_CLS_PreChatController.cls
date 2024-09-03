public class LXD_CLS_PreChatController{
	@auraenabled
    public static String getCurrentUser(){
        String lOutputStr = '';
        Map<String,String> lOutputMap = new Map<String,String>();
        try{
            lOutputMap.put('userId',UserInfo.getUserId());
        	lOutputStr = JSON.serialize(lOutputMap);
        }
        catch(Exception e){
            system.debug('Erro: '+e.getMessage());
            lOutputMap.put('userId','');
        }
        return lOutputStr;
    }
}
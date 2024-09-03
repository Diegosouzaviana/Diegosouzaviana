public class LXD_CLS_LiveChatTranscript {
    public static void AssignEntitlement(List<Object> aObjectLst, String aType){

        Map<string,string> lCaseOwnerMap = new Map<string,string>();
        
        if(aType == 'LiveChatTranscript'){
            List<LiveChatTranscript> lLiveList = (List<LiveChatTranscript>) aObjectLst;
            for(LiveChatTranscript lTranscript :lLiveList){
                String lOwnerId = lTranscript.OwnerId;
                if(lOwnerId.substring(0,3) == '005'){
                    lCaseOwnerMap.put(lTranscript.CaseId,lTranscript.OwnerId);
                }
            }
        }
        else if(aType == 'MessagingSession'){
            List<MessagingSession> lMessagingList = (List<MessagingSession>) aObjectLst;
            for(MessagingSession lMSession :lMessagingList){
                String lOwnerId = lMSession.OwnerId;
                if(lOwnerId.substring(0,3) == '005'){
                    lCaseOwnerMap.put(lMSession.CaseId,lMSession.OwnerId);
                }
            }
        }
        for(Case lCase : [SELECT Id, Status FROM Case WHERE Id =: lCaseOwnerMap.keySet()]){
            if(lCase.Status != 'Em Aberto' && lCase.Status != 'New') lCaseOwnerMap.remove(lCase.Id);
        }
        if(lCaseOwnerMap.isEmpty()) return;
        
        try{
            //Busca direitos
        	Map<String,String> lEntitlementMap = new Map<String,String>();
        	for(Entitlement lEnt: [SELECT id, Name FROM Entitlement]){
            	lEntitlementMap.put(lEnt.Name, lEnt.Id);
        	}
        
        	//Lista de conjunto de permissões
        	Set<String> lPermissionSet = new Set<String>();
        	lPermissionSet.add('LXD_Retencao');
        	lPermissionSet.add('LXD_SAC');
        	lPermissionSet.add('LXD_Suporte');
            
            //Busca permissões dos proprietários
            Map<String,String> lUserProfileMap = new Map<String,String>();
            for(PermissionSetAssignment lPSA : [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE 
                                               AssigneeId =: lCaseOwnerMap.values() AND 
                                               PermissionSet.Name =: lPermissionSet]){
                system.debug('for do direito: '+lPSA);
                String lDireito = '';
                if(lPSA.PermissionSet.Name == 'LXD_Retencao') lDireito = 'Pós Venda - Retenção';
                if(lPSA.PermissionSet.Name == 'LXD_SAC') lDireito = 'Pós Venda - SAC';
                if(lPSA.PermissionSet.Name == 'LXD_Suporte') lDireito = 'Pós Venda - Suporte';
                if(lDireito != ''){
                    lUserProfileMap.put(lPSA.AssigneeId, lDireito);
                }
            }
            if(lUserProfileMap.isEmpty()) return;
            
            //Atualiza os casos
            List<Case> lCaseUpdateLst = new List<Case>();
            for(String lCaseId: lCaseOwnerMap.keySet()){
                
                Case lCase = new Case();
                lCase.id = lCaseId;
                lCase.status = 'Em Atendimento';
                lCase.OwnerId = lCaseOwnerMap.get(lCase.Id);
                lCase.entitlementId = lEntitlementMap.get(lUserProfileMap.get(lCaseOwnerMap.get(lCase.Id)));
                lCaseUpdateLst.add(lCase);
            }
            if(lCaseUpdateLst.isEmpty()) return;
            Update lCaseUpdateLst;
        }
        catch(Exception e){
            throw new UpsertCaseException(e.getMessage());
        }
    }
    
    public class UpsertCaseException extends Exception {}
}
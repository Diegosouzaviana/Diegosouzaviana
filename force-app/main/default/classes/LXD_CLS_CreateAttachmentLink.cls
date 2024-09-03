/*
*   @author: Misael Ribas
*   @since: yyyy/mm/dd
*   @className: LXD_CLS_CreateAttachmentLinkTest
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/12/30            Misael Ribas      Class restructuring
*   2023/01/19            Misael Ribas      Class change to use ContentVersion instead of Attachment 
*   ====================================================
*/
global without sharing class LXD_CLS_CreateAttachmentLink implements vlocity_cmt.VlocityOpenInterface{
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        
        if (methodName.equalsIgnoreCase('returnLinkBill')) returnLinkBill(inputs, output);
        else return false;

        return true;
    }
    
    global static void returnLinkBill(Map<String, Object> inputs, Map<String, Object> output){
        
        try {
            String AccId = '';
            String lLink = '';
            if(inputs.containsKey('accountId')){
                AccId = (String) inputs.get('accountId');
            }
            else{
                AccId = [SELECT Id, Name, CommunityNickname, Profile.Name, AccountId FROM User WHERE id =: UserInfo.getUserId() LIMIT 1].AccountId;
            }
        
            String lBoletoCode = (String) inputs.get('billCode');
            String lBillName = 'Boleto_'+lBoletoCode+'.pdf';
            
            ContentDistribution lContentDist = new ContentDistribution();
            List<ContentDistribution> lContentDistLst = new List<ContentDistribution>();
            for(ContentDistribution lContentDistItem :[SELECT id, Name, ContentDownloadUrl, DistributionPublicUrl, 
                                                       PdfDownloadUrl FROM ContentDistribution WHERE Name =:lBillName]){
                lContentDistLst.add(lContentDistItem);
            }
            if(lContentDistLst.isEmpty()){
            
            	LXD_CLS_CallInvoiceIntegration.ClientInput lInput = new LXD_CLS_CallInvoiceIntegration.ClientInput();
            	lInput.lCPF = lBoletoCode; 
            	List<LXD_CLS_CallInvoiceIntegration.ClientInput> lInputList = new List<LXD_CLS_CallInvoiceIntegration.ClientInput>{lInput};
            	List<LXD_CLS_CallInvoiceIntegration.ClientOutput> lOutput = LXD_CLS_CallInvoiceIntegration.SendInvoices(lInputList);
            
            	Blob lPdfMock = EncodingUtil.base64Decode(lOutput[0].Boletos);
            
            	ContentVersion lContentVersion = new ContentVersion();
            
            	List<ContentVersion> lCvLst = new List<ContentVersion>();
            	for(ContentVersion lCv :[SELECT id, Title FROM ContentVersion WHERE Title =:lBillName]){
            	    lCvLst.add(lCv);
            	}
            	if(lCvLst.isEmpty()){
                    for(NetworkMember lMember :[SELECT Id, MemberId, Member.Name, NetworkId, Network.Name  FROM NetworkMember WHERE MemberId =: UserInfo.getUserId()]){
                        lContentVersion.NetworkId = lMember.NetworkId;
                    }
                    lContentVersion.VersionData = lPdfMock;
        			lContentVersion.Title = lBillName;
        			lContentVersion.PathOnClient = lBillName;
                    
        			insert lContentVersion;
            	}
            	else{
                	lContentVersion = lCvLst[0];
            	}
            
            
                lContentDist.Name = lBillName;
        		lContentDist.ContentVersionId = lContentVersion.Id;
        		lContentDist.PreferencesAllowViewInBrowser= true;
        		insert lContentDist;
                
                lLink = [SELECT id, Name, PdfDownloadUrl FROM ContentDistribution WHERE Id =:lContentDist.Id].PdfDownloadUrl;
            }
            else{
                lContentDist = lContentDistLst[0];
                lLink = lContentDist.DistributionPublicUrl;
            }
    
            LXD_VlocityUtils.success(output, lLink);

        } catch (Exception e) {
            LXD_VlocityUtils.badRequest(output, e.getMessage());
            LXD_VlocityUtils.debugErrorMessage(e);
        }
    }
}
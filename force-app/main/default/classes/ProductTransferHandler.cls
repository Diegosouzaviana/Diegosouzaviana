public with sharing class ProductTransferHandler {
    static Id LocationId = null;
    static Id IntegrationOwnerID = null;
    static List<ProductTransfer> productTransferList = null;
    static List<SerializedProduct> SerializedProductList = null;
    public static String AcceptURL;
    public static String DeclineURL;

    public static void ProductTransferGet(List<ProductTransfer> productTransferListNew) {
        try {
            System.debug('ProductTransferGet Class');
            Boolean IsReceived, NotReceived, IsSerialized=false;
            Boolean updatedTrigger, isIntegration = false;
            String integrationName = '',ProductTransferNumber;
            Id ProductTransferId;
            Integer Decline = null;
            
            for (ProductTransfer pf : productTransferListNew) {
                IsReceived = pf.IsReceived;
                NotReceived = pf.NotReceived__c;
                updatedTrigger = pf.UpdatedTrigger__c;
                ProductTransferNumber = pf.ProductTransferNumber;
                AcceptURL = pf.AcceptURL__c;
                System.debug('Declined__c '+pf.DeclineURL__c);
                DeclineURL = String.valueOf(pf.DeclineURL__c);
                System.debug('2 DeclineURL '+DeclineURL);
                ProductTransferId = pf.Id;
                Decline = Integer.valueOf(pf.Declined__c);
                System.debug('id '+pf.Id);
                System.debug('owner Id '+pf.OwnerId);
                try {
                    List<User> userList = [SELECT Username, Name, LastName, Id FROM User WHERE  Id = :pf.OwnerId AND (Username LIKE 'integracao@desktop.net.br%' OR Username LIKE 'syncdedados@desktop.net.br')];
                    System.debug('u size '+userList.size());
                    if (userList.size() > 0) {
                        isIntegration = true;
                    }
                } catch (Exception e) {
                    isIntegration = false;
                    System.debug('erro ao selecionar usuário integração '+e.getMessage() + ' '+e.getStackTraceString());
                }

                IntegrationOwnerID = pf.OwnerId;
                IsSerialized = pf.IsProduct2Serialized;
            }

            if (isIntegration) {    //validação para executar somente quando o proprietário é de integração
                if(!IsSerialized) {
                    if (updatedTrigger == false) {
                        if(Test.isRunningTest()) {
                            User tech = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'tsttech1'];
                            LocationId = [SELECT RelatedRecordId, LocationId FROM ServiceResource WHERE RelatedRecordId = :tech.Id LIMIT 1].LocationId;
                        } else {
                            LocationId = [SELECT RelatedRecordId, LocationId FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() LIMIT 1].LocationId;
                        }
                        System.debug('IntegrationOwnerID '+IntegrationOwnerID);
                        System.debug('LocationId '+LocationId);
                        ProductTransfer ptr = [SELECT AcceptURL__c, QuantitySent, QuantityReceived, ReceivedById, ProductTransferNumber, IsReceived, UpdatedTrigger__c, Id, OwnerId FROM ProductTransfer WHERE Id = :ProductTransferId];
                        productTransferList = [SELECT AcceptURL__c, QuantitySent, QuantityReceived, ReceivedById, ProductTransferNumber, IsReceived, UpdatedTrigger__c, Id, OwnerId 
                                                FROM ProductTransfer 
                                                WHERE IsReceived = false 
                                                AND OwnerId = :IntegrationOwnerID
                                                AND DestinationLocationId =:LocationId 
                                                AND AcceptURL__c = :AcceptURL
                                                AND Product2.RecordType.DeveloperName = 'Miscellaneous' 
                                                AND IsProduct2Serialized = false];
                        productTransferList.add(ptr);
                        if (IsReceived==true && NotReceived==false)
                            RecordsAcceptMethod(IsSerialized);
                        else if (IsReceived==false && NotReceived==true)
                            RecordsDeclineMethod(IsSerialized, null);
                        else
                            System.debug('IsReceived->'+IsReceived+' NotReceived->'+NotReceived);
                    } else
                        System.debug('updateTrigger true - '+ProductTransferNumber + ' - '+ ProductTransferId);
                } else {
                    if (IsReceived==true && NotReceived==false && Decline == 0)
                        RecordsAcceptMethod(IsSerialized);
                    else if ((IsReceived==false && NotReceived==true) || (IsReceived==true && NotReceived==false && Decline > 0))
                        RecordsDeclineMethod(IsSerialized, ProductTransferId);
                    
                    System.debug('Produto '+ProductTransferNumber + ' é SERIALIZADO')    ;
                }
            } else {
                System.debug('Proprietário do Número da transferência de produto '+ProductTransferNumber +' não é de integração');
            }
            
        } catch (Exception e) {
            System.debug('Erro ao obter produtos de transferencias: '+e.getMessage()+'-'+e.getStackTraceString());
        }
    }

    public static void RecordsAcceptMethod(Boolean IsSerialized) {
        try {
            System.debug('AcceptURL--- '+AcceptURL);
            Integer qtdSerialized = 0;
            if (!IsSerialized) {
                System.debug('!IsSerialized - '+productTransferList.size());
                if (productTransferList.size() > 0) {
                    for (ProductTransfer pt : productTransferList) {
                        pt.IsReceived           = true;
                        pt.QuantityReceived     = pt.QuantitySent;
                        pt.status               = 'Concluída';
                        pt.UpdatedTrigger__c    = true;
                        pt.ReceivedById         = UserInfo.getUserId();
                        System.debug('ProductTransferNumber->> '+pt.ProductTransferNumber);
                    }
                    if(!Test.isRunningTest()) {
                        update productTransferList;
                        System.debug('chamando callback..');
                        MakeCallback(AcceptURL);   
                    }
                } else
                    System.debug('productTransferList.size() '+productTransferList.size());                
            } else {
                
                if(!Test.isRunningTest()) {
                    System.debug('chamando callback..');
                    MakeCallback(AcceptURL);
                }
            }
        } catch (Exception e) {
            System.debug('Erro ao atualizar aceite de registros '+e.getMessage()+'-'+e.getStackTraceString());
        }
    }

    public static void RecordsDeclineMethod(Boolean IsSerialized, Id ProductTransferId) {
        try {
            List<ProductTransfer> productTransferList = new List<ProductTransfer>();

            System.debug('Declined__c '+DeclineURL);
            if (IsSerialized) {
                Set<Id> SerializedProductIdSet = new Set<Id>();
                List<ProductTransferState> ptsList = [SELECT ProductTransfer.ProductTransferNumber,  ProductTransferId, SerializedProductId,  ID FROM ProductTransferState WHERE ProductTransferId = :ProductTransferId];
                for (ProductTransferState pts : ptsList) {
                    SerializedProductIdSet.add(pts.SerializedProductId);
                    System.debug('SerializedProductId '+pts.SerializedProductId);
                }

                //Select ProductItemTransactionNumber, ProductItemId, Quantity, TransactionType,   id from ProductItemTransaction where TransactionType = 'Adjusted' order by ProductItemTransactionNumber desc
                SerializedProductList = [SELECT ProductItemId, IsDeleted, Id FROM SerializedProduct WHERE Id IN :SerializedProductIdSet];
                System.debug('SerializedProductList size '+SerializedProductList.size());

                productTransferList = [SELECT DeclineURL__c, ProductTransferNumber, IsDeleted, Id 
                                        FROM ProductTransfer 
                                        WHERE Id = :ProductTransferId];
                System.debug('productTransferList size '+productTransferList.size());

                /*if(productTransferList.size()>0){
                    Database.delete(productTransferList,false);
                }*/
                if(!Test.isRunningTest()) {
                    MakeCallback(DeclineURL);
                }
                /*System.debug('SerializedProductList 2 -> '+ SerializedProductList);
                if(ptsList.size()>0){
                    Database.delete(ptsList, true);

                }
                if(SerializedProductList.size()>0){
                    System.debug('delete serialized');
                    System.debug('SerializedProductIdSet -> ' + SerializedProductIdSet);
                    
                    Database.delete(SerializedProductList,true); 

                }     */   
            } else {
                productTransferList = [SELECT AcceptURL__c, QuantitySent, QuantityReceived, ReceivedById, ProductTransferNumber, IsReceived, UpdatedTrigger__c, Id, DeclineURL__c, OwnerId 
                                        FROM ProductTransfer 
                                        WHERE IsReceived = false 
                                        AND OwnerId = :IntegrationOwnerID
                                        AND DestinationLocationId =:LocationId 
                                        AND Product2.RecordType.DeveloperName = 'Miscellaneous' 
                                        AND DeclineURL__c = :DeclineURL  // URL DE RECUSA TEM QUE SER A MESMA QUE DEU O GATILHO
                                        AND IsProduct2Serialized = false];

                if (productTransferList.size() > 0) {
                    System.debug('DeclineURL NEW'+DeclineURL);
                    delete productTransferList;
                    if(!Test.isRunningTest()) {
                        MakeCallback(DeclineURL);
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Erro ao excluir a recusa de registros '+e.getMessage()+'-'+e.getStackTraceString());
        }
    }

    @future (callout=true)
    public static void MakeCallback(String endpoint) {
        if(!String.isBlank(endpoint)){
            HttpResponse response;
            HttpRequest request;
            String method = 'POST';
            Integer timeout = 120000;
            String body = '';
            try {
                request = new HttpRequest();
                request.setEndpoint(endPoint);
                request.setMethod(method);
                request.setTimeout(timeout);
                request.setBody(body);
                request.setHeader('Content-Type','application/json');
                response = new Http().send(request);
                System.debug('response body '+response.getStatusCode()+ response.getBody());
                //return response;
            } catch (Exception e) {
                System.debug('Erro ao efetuar callback '+e.getMessage()+' - '+e.getStackTraceString());
                throw e;
            }
        }
    }
}
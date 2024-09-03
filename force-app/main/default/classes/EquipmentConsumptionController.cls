public without sharing class EquipmentConsumptionController {
    @AuraEnabled(cacheable=false)
    public static List<ProductItemVO> getProductsItems(Id recordId) {
        try {
            //Id WorkOrderId = [SELECT Id FROM WorkStep WHERE ID = :recordId].Id;
            String emailUser = UserInfo.getUserEmail();
            Map<String, String> UnitOfMeasureMap = new Map<String, String>();
            List<ProductItemVO> productItemVOList = new List<ProductItemVO>();
            List<Id> productItemIdSerializedList = new List<Id>();
            ServiceResource sr = [SELECT email__c, LocationId, Location.Name, Id FROM ServiceResource WHERE email__c = :emailUser LIMIT 1];

            List<ProductItem> productItemList = [SELECT ProductItemNumber, ProductName, QuantityOnHand, QuantityUnitOfMeasure, LocationId, Location.Name,  Product2.IsSerialized, Product2.ProductCode, Id 
                                                FROM ProductItem
                                                WHERE Product2.IsActive = true AND LocationId = :sr.LocationId AND QuantityOnHand > 0 AND Product2.IsSerialized = false
                                                ORDER BY ProductName, ProductItemNumber];
            UnitOfMeasureMap = getPickListValues('QuantityUnitOfMeasure');
            for (ProductItem pi : productItemList) {
                ProductItemVO pIVO = new ProductItemVO();
                pIVO.Id                     = pi.Id;
                pivo.ItemNumber             = pi.ProductItemNumber;
                pIVO.ProductName            = pi.ProductName;
                pIVO.QuantityOnHand         = pi.QuantityOnHand;
                pIVO.QuantityUnitMeasure    = UnitOfMeasureMap.get(pi.QuantityUnitOfMeasure);
                pIVO.IsSerialized           = pi.Product2.IsSerialized;
                pIVO.QuantityOnHandMax      = pi.QuantityOnHand;
                pIVO.ProductCode            = pi.Product2.ProductCode;               
                productItemVOList.add(pIVO);
            }

            return productItemVOList;
        } catch (Exception e) {
            String message = 'Erro ao obteer productItem '+e.getMessage()+' '+e.getStackTraceString();
            System.debug(message);
            try {
                Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
                throw new AuraHandledException(e.getMessage());
            } catch (Exception ex) {
                System.debug('Erro ao inserir log: '+ex.getMessage() + ' ' +ex.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    @AuraEnabled(cacheable=false)
    public static String CreateProductConsumed(Id recordId, String productC) {
        try {
            String resp = '';
            WorkStep WStep = [SELECT WorkOrderId, Status, Id FROM WorkStep WHERE ID = :recordId];
            Id WorkOrderId = WStep.WorkOrderId;
            List<ProductConsumed> ProductConsumedList = new List<ProductConsumed>();
            Double QuantityConsumed;
            List<ProductItemVO> spList = EquipmentConsumptionController.parseProductItem(productC);
            for (ProductItemVO pi : spList) {
                ProductConsumed pc      = new ProductConsumed();
                pc.ProductItemId        = pi.Id;
                pc.QuantityConsumed     = pi.QuantityConsumed;
                pc.WorkOrderId          = WorkOrderId;
                ProductConsumedList.add(pc);
                resp = ''+pi.QuantityConsumed;
            }
            /*WStep.Status = 'Completed';
            update WStep;*/
            insert ProductConsumedList;
            return resp;
        } catch (Exception e) {
            String message = 'Erro ao criar Produto Consumido: '+e.getMessage()+' '+e.getStackTraceString();
            System.debug(message);
            Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
            return e.getMessage()+' '+e.getStackTraceString();
        }
    }

    @AuraEnabled(cacheable=false)
    public static void updateStatusField(Id recordId) {
        try{
            System.debug('antes de realizar consulta');
            WorkStep WStep = [SELECT WorkOrderId, Status, Id FROM WorkStep WHERE ID = :recordId];
            System.debug('depois de realizar consulta' + WStep);
            WStep.Status = 'Not Applicable';
            System.debug('status');
            update WStep;
            System.debug('atualizou status');
        } catch(Exception ex){
            System.debug('teste: ' + ex.getStackTraceString());
        }       
    }

    private static Map<String, String> getPickListValues(String apiName) {
        try {
            Map<String, String> pickListValuesMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = ProductItem.QuantityUnitOfMeasure.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
                System.debug('-> '+pickListVal.getValue() +' - '+pickListVal.getLabel());
            }
            return pickListValuesMap;
        } catch (Exception e) {
            String message = 'Erro ao obter picklist de unidade de medida '+e.getMessage()+' - '+e.getStackTraceString();
            System.debug(message);
            Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProductItemVO {
        @AuraEnabled
        public Id Id {get;set;}
        
        @AuraEnabled
        public String ItemNumber {get;set;}

        
        @AuraEnabled
        public Integer Size {get;set;}

        @AuraEnabled
        public String ProductName {get;set;}

        @AuraEnabled
        public Double QuantityOnHand {get;set;}

        @AuraEnabled
        public Double QuantityOnHandMax {get;set;}

        @AuraEnabled
        public Double QuantityConsumed {get;set;}

        @AuraEnabled
        public String QuantityUnitMeasure {get;set;}

        @AuraEnabled
        public Boolean IsSerialized {get;set;}

        @AuraEnabled
        public String ProductCode {get;set;}

        @AuraEnabled
        public List<Serialized> SerializedProductVOList {get;set;}
    }

    public class Serialized{
        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String SerialNumber;

        @AuraEnabled
        public Id Id {get;set;}

        @AuraEnabled
        public String pItemNumber {get;set;}
        
        @AuraEnabled
        public String pItemId {get;set;}

        @AuraEnabled
        public String p2Id {get;set;}
        
        @AuraEnabled
        public String p2Name {get;set;}
        
        @AuraEnabled
        public String codigoAtivo {get;set;}
        
        @AuraEnabled
        public String mac {get;set;}
        
        @AuraEnabled
        public String tecnologia {get;set;}

        @AuraEnabled
        public String tipoAtivo {get;set;}
    }

    public static List<ProductItemVO> parseProductItem(String json) {
        return (List<ProductItemVO>) System.JSON.deserialize(json, List<ProductItemVO>.class);
    }

    @AuraEnabled(cacheable=false)
    public static List<ProductItemVO> getEquipment(Id recordId) {
        try {
            //Id WorkOrderId = [SELECT Id FROM WorkStep WHERE ID = :recordId].Id;
            String emailUser = UserInfo.getUserEmail();
            Map<String, String> UnitOfMeasureMap = new Map<String, String>();
            List<ProductItemVO> productItemVOList = new List<ProductItemVO>();
            List<Id> productItemIdSerializedList = new List<Id>();
            ServiceResource sr = [SELECT email__c, LocationId, Location.Name, Id FROM ServiceResource WHERE email__c = :emailUser LIMIT 1];

            List<ProductItem> productItemList = [SELECT ProductItemNumber, (SELECT id, Name, SerialNumber, Product2Id, Product2.Name,ProductItemId,ProductItem.ProductItemNumber, MAC__c, CodigoAtivoSP__c FROM SerializedProducts),ProductName, QuantityOnHand, QuantityUnitOfMeasure, LocationId, Location.Name,  Product2.IsSerialized, Product2.ProductCode, Id 
                                                FROM ProductItem
                                                WHERE Product2.IsActive = true AND LocationId = :sr.LocationId AND QuantityOnHand > 0 AND Product2.IsSerialized = true
                                                ORDER BY ProductName, ProductItemNumber];
            UnitOfMeasureMap = getPickListValues('QuantityUnitOfMeasure');
            System.debug('productItemList -> ' + productItemList);
            for (ProductItem pi : productItemList) {
                List<Serialized> lSerial = new List<Serialized>();
                ProductItemVO pIVO = new ProductItemVO();
                pIVO.Id                     = pi.Id;
                pIvo.ItemNumber             = pi.ProductItemNumber;
                pIVO.ProductName            = pi.ProductName;
                pIVO.QuantityOnHand         = pi.QuantityOnHand;
                pIVO.QuantityUnitMeasure    = UnitOfMeasureMap.get(pi.QuantityUnitOfMeasure);
                pIVO.IsSerialized           = pi.Product2.IsSerialized;
                pIVO.QuantityOnHandMax      = pi.Product2.IsSerialized == true ? 1 : pi.QuantityOnHand;
                pIVO.QuantityConsumed       = 0;
                pIVO.ProductCode            = pi.Product2.ProductCode;
                pIvo.Size                   = pi.SerializedProducts.size();
                for(SerializedProduct sp : pi.SerializedProducts){
                    Serialized s = new Serialized();
                    s.Name = sp.Name;
                    s.SerialNumber = sp.SerialNumber;
                    s.id = sp.Id;
                    s.pItemNumber = sp.ProductItem.ProductItemNumber;
                    s.pItemId = sp.ProductItemId;
                    s.p2Id = sp.Product2Id;
                    s.p2Name = sp.Product2.Name;
                    s.codigoAtivo = sp.CodigoAtivoSP__c;
                    s.mac = sp.MAC__c;
                    lSerial.add(s);
                }    
                pIVO.SerializedProductVOList = lSerial;           
                productItemVOList.add(pIVO);
            }
            System.debug('productItemVOList -> ' + productItemVOList);

            return productItemVOList;
        } catch (Exception e) {
            String message = 'Erro ao obteer productItem '+e.getMessage()+' '+e.getStackTraceString();
            System.debug(message);
            try {
                Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
                throw new AuraHandledException(e.getMessage());
            } catch (Exception ex) {
                System.debug('Erro ao inserir log: '+ex.getMessage() + ' ' +ex.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    
    @AuraEnabled(cacheable=false)
    public static Serialized getSerialized(String serial, String pItemNumber) {
        try {
            Serialized serializedList = new Serialized();

            List<SerializedProduct> serialList= new List<SerializedProduct>();
            serialList = [SELECT id, SerialNumber, Product2Id, Product2.Name,ProductItemId,ProductItem.ProductItemNumber, MAC__c, CodigoAtivoSP__c,Product2.TecnologiaProduct__c,Product2.TipoAtivoProduct__c FROM SerializedProduct WHERE SerialNumber =: serial AND ProductItem.ProductItemNumber =: pItemNumber LIMIT 1];

            if(serialList.size()>0){
                for(SerializedProduct sp : serialList){
                    serializedList.id = sp.Id;
                    serializedList.SerialNumber = sp.SerialNumber;
                    serializedList.pItemNumber = sp.ProductItem.ProductItemNumber;
                    serializedList.pItemId = sp.ProductItemId;
                    serializedList.p2Id = sp.Product2Id;
                    serializedList.p2Name = sp.Product2.Name;
                    serializedList.codigoAtivo = sp.CodigoAtivoSP__c;
                    serializedList.mac = sp.MAC__c;
                    serializedList.tecnologia = sp.Product2.TecnologiaProduct__c;
                    serializedList.tipoAtivo = sp.Product2.TipoAtivoProduct__c;
                }

            }
            if(serializedList.id != null){
                System.debug('serializedList -> ' + serializedList);
                return serializedList;

            }else{
                throw new AuraHandledException('Erro ao obter produto serializado.');
            }
        } catch (Exception e) {
            String message = 'Erro ao obter produto serializado '+e.getMessage()+' '+e.getStackTraceString();
            System.debug(message);
            try {
                Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
                throw new AuraHandledException(e.getMessage());
            } catch (Exception ex) {
                System.debug('Erro ao inserir log: '+ex.getMessage() + ' ' +ex.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    @AuraEnabled
    public static assetInfo getAssetInfo(String workOrderId){
        System.debug('workOrderId -> '+ workOrderId);
        try {
            assetInfo aInfo = new assetInfo();
            Asset a = new Asset();
            a = [SELECT id, AccountId, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ContractId__c, ContactId, vlocity_cmt__ServiceAccountId__c FROM Asset WHERE id IN (SELECT AssetId FROM WorkOrder WHERE id =: workOrderId) LIMIT 1];

            aInfo.assetId =a.Id;
            aInfo.accountId =a.AccountId;
            aInfo.billingId =a.vlocity_cmt__BillingAccountId__c;
            aInfo.contractId =a.vlocity_cmt__ContractId__c;
            aInfo.contactId =a.ContactId;
            aInfo.serviceId = a.vlocity_cmt__ServiceAccountId__c;

            System.debug('aInfo -> ' + aInfo);

            return aInfo;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class assetInfo{

        @AuraEnabled
        public String assetId;

        @AuraEnabled
        public String accountId;
        
        @AuraEnabled
        public String serviceId;

        @AuraEnabled
        public String billingId;

        @AuraEnabled
        public String contractId;

        @AuraEnabled
        public String contactId;
    }

}
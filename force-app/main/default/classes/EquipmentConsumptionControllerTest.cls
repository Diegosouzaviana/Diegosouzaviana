/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             EquipmentConsumptionControllerTest
* @description      Test class of  EquipmentConsumptionController
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-08-30   Guilherme                     Initial version. 
******
**/

@isTest
public class EquipmentConsumptionControllerTest {

    @TestSetup
    static void setup(){
        DataFactoryTest.makeData();
        Id workTypeId = [Select Id From WorkType Where Name = 'Maintenance'].Id;
        Id accId = [Select Id From Account Limit 1].Id;

        
        vlocity_cmt__ObjectClass__c obj = new vlocity_cmt__ObjectClass__c();
        obj.Name = 'Plano Desktop';
        obj.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert obj;

        System.debug('obj ->' + obj);
        if(obj.id == null || String.valueOf(obj.id) == '' ){
            obj = [SELECT id FROM vlocity_cmt__ObjectClass__c WHERE Name = 'Plano Desktop' LIMIT 1];
        }

        RecordType rtEq = [SELECT Id FROM RecordType WHERE DeveloperName = 'Equipamento'];
    
        List<Product2> product2List = new List<Product2>();
        Product2 p1 = new Product2(
            CanUseQuantitySchedule  = true,
            CanUseRevenueSchedule   = true,
            Description             = 'T-F-23.200M.4000G',
            IsActive                = true,
            IsSerialized            = false,
            Name                    = 'Fibra Home 200M 2023',
            ProductCode             = 'T-F-23.200M.4000G',
            vlocity_cmt__ObjectTypeId__c = obj.Id
        );
        
        Account acc = new Account(
            Name = 'New Account Name',
            CNPJ__c = '49401667000195',
            LXD_CPF__c = '40094880000',
            LXD_Email__c='teste@gmail.com',
            BillingStreet = 'R. Dr. Marcos Antonio Samartine, 99',
            LXD_NewAddressComplement__c = null,
            BillingPostalCode = '13.067-450',
            LXD_AddressNeighborhood__c = 'Nucleo Habitacional Boa Vista',
            BillingCity = 'Campinas',
            BillingState = 'SP',
            ShippingStreet = 'Rua Carioba',
            LXD_AddressNumber__c = '99', 
            ShippingPostalCode = '13472560',
            ShippingCity = 'Americana',
            ShippingState = 'SP'
        );
        insert acc;

        Contract contract = new Contract();
        contract.vlocity_cmt__ContractReferenceNumber__c = '236598856';
        contract.IdPromocao__c = 1230;
        contract.AccountId = acc.Id;
        insert contract;

        //criar product2 antes de asset
        Asset ass =  new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'L',
            AccountId = acc.Id,
            Product2Id = p1.Id,
            IdPlanoAdicional__c = 683351,
            IdPlanoUsuario__c = 3658969,
            IdPromocao__c = 65896,
            CTO__c = '25',
            PortaCTO__c = '1',
            TipoAtivo__c = 'ONU',
            CodigoAtivo__c = 'ZY246458',
            vlocity_cmt__ContractId__c = contract.id);

        insert ass;

        WorkOrder wo = new WorkOrder(
            AccountId = accId,
            WorkTypeId = workTypeId,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'AM',
            AssetId = ass.id
        );
        insert wo;

        WorkPlan wp = new WorkPlan(
            Name                    = 'Auto Inspeção',
            WorkOrderId             = wo.Id
        );
        insert wp;

        WorkStep ws = new WorkStep(
            Name                    = 'CTO fechada com o número da CTO',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        insert ws;

        id recordTypeEquipamentId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Equipamento').getRecordTypeId();
        List<Product2> listP = new List<Product2>();
        Product2 product = new Product2();
        product.Name = 'aDSL Bus. Combo 15M 750G';
        product.ProductCode = 'FH.15M.750G.IP';
        product.Description = 'F-H.15M.750G.IP';
        product.Family = 'Combo  Bus';
        product.IsSerialized = false;
        product.RecordTypeId = recordTypeEquipamentId;
        product.isActive = true;
        listP.add(product);

        Product2 product1 = new Product2();
        product1.Name = 'ONT Zyxel-PMG2005';
        product1.ProductCode = '21';
        product1.Description = 'ONT Zyxel-PMG2005';
        product1.Family = 'ONU';
        product1.IsSerialized = true;
        product1.RecordTypeId = recordTypeEquipamentId;
        product1.isActive = true;
        product1.Model__c = 'ONU';
        listP.add(product1);
        insert listP;

        Schema.Location location1 = new Schema.Location();
        location1.Name = 'Estoque de RBI';
        location1.LocationType = 'Warehouse';
        location1.TimeZone = 'America/Sao_Paulo';
        location1.IsInventoryLocation=true;
        location1.IsMobile=true;
        location1.latitude=-23.49093930803577;
        location1.longitude=-47.51609786262823;
        insert location1;

        Schema.Location location2 = new Schema.Location();
        location2.Name = 'Estoque de RBI 2';
        location2.LocationType = 'Warehouse';
        location2.TimeZone = 'America/Sao_Paulo';
        location2.IsInventoryLocation=true;
        location2.IsMobile=true;
        location2.latitude=-23.49093930809843;
        location2.longitude=-47.51609786260812;
        insert location2;

        
        List<ProductItem> listPI = new List<ProductItem>();
        ProductItem productItem = new ProductItem();
        productItem.QuantityOnHand = 10;
        productItem.QuantityUnitOfMeasure = 'Each';
        productItem.Product2Id = product.Id;
        productItem.LocationId = location1.Id;
        productItem.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        listPI.add(productItem);

        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,locationId FROM ServiceResource WHERE CPF__c = '28869941035' LIMIT 1];
        sr.LocationId = location1.Id;
        update sr;

        ProductItem productItem1 = new ProductItem();
        productItem1.QuantityOnHand = 0;
        productItem1.QuantityUnitOfMeasure = 'Each';
        productItem1.Product2Id = product1.Id;
        productItem1.LocationId = location1.Id;
        productItem1.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        listPI.add(productItem1);
        insert listPI;

        
        SerializedProduct serializedProduct = new SerializedProduct();
        serializedProduct.Product2Id = product1.Id;
        serializedProduct.ProductItemId = productItem1.Id;
        serializedProduct.Status = 'Available';
        serializedProduct.SerialNumber = '321321321';

        insert serializedProduct;

    }
    
    @isTest
    static void testMethod_CreateProductConsumed_Error() {
        Id workStepId = [Select Id From WorkStep Limit 1].Id;
        ProductItem prodItem = [Select Id,ProductName,ProductItemNumber From ProductItem Limit 1];
        List<EquipmentConsumptionController.ProductItemVO> productList = new List<EquipmentConsumptionController.ProductItemVO>();
        EquipmentConsumptionController.ProductItemVO product = new EquipmentConsumptionController.ProductItemVO();
        product.Id = prodItem.Id;
        product.ItemNumber = prodItem.ProductItemNumber;
        product.ProductName = prodItem.ProductName;
        product.QuantityOnHand = 10;
        product.QuantityOnHandMax = 1;
        product.QuantityConsumed = 11;
        product.QuantityUnitMeasure = 'Each';
        product.IsSerialized = false;
        productList.add(product);

        Test.startTest();
        String response = EquipmentConsumptionController.CreateProductConsumed(workStepId,JSON.serialize(productList));
        System.assert(response!=null);
        System.assert(response.contains('FIELD_INTEGRITY_EXCEPTION'));
        Test.stopTest();
    }

    @isTest
    static void testMethod_CreateProductConsumed() {
        Id workStepId = [Select Id From WorkStep Limit 1].Id;
        ProductItem prodItem = [Select Id,ProductName,ProductItemNumber,QuantityOnHand From ProductItem Limit 1];
        List<EquipmentConsumptionController.ProductItemVO> productList = new List<EquipmentConsumptionController.ProductItemVO>();
        EquipmentConsumptionController.ProductItemVO product = new EquipmentConsumptionController.ProductItemVO();
        product.Id = prodItem.Id;
        product.ItemNumber = prodItem.ProductItemNumber;
        product.ProductName = prodItem.ProductName;
        product.QuantityOnHand = prodItem.QuantityOnHand;
        product.QuantityOnHandMax = 1;
        product.QuantityConsumed = 1;
        product.QuantityUnitMeasure = 'Each';
        product.IsSerialized = false;
        productList.add(product);

        Test.startTest();
        String response = EquipmentConsumptionController.CreateProductConsumed(workStepId,JSON.serialize(productList));
        System.assert(response!=null);
        System.assertEquals(String.valueOf(1.0),response);
        Test.stopTest();
    }
/*
    @isTest
    static void testMethod_CreateSerializedProductConsumed_Error() {
        Id workStepId = [Select Id From WorkStep Limit 1].Id;
        ProductItem prodItem = [Select Id,ProductName,QuantityUnitOfMeasure,QuantityOnHand,Product2Id From ProductItem Limit 1];
        List<EquipmentConsumptionController.SerializedProductVO> productList = new List<EquipmentConsumptionController.SerializedProductVO>();
        EquipmentConsumptionController.SerializedProductVO product = new EquipmentConsumptionController.SerializedProductVO();
        product.ProductItemId = prodItem.Id;
        product.ProductName = prodItem.ProductName;
        product.Name = prodItem.ProductName;
        product.QuantityUnitOfMeasure = prodItem.QuantityUnitOfMeasure;
        product.ProductId = prodItem.Product2Id;
        product.SerialNumber = '1';
        product.QuantityUnitOfMeasure = 'Each';
        product.IsChecked = false;
        productList.add(product);

        Test.startTest();
        String response = EquipmentConsumptionController.CreateSerializedProductConsumed(workStepId,JSON.serialize(productList));
        System.assert(response!=null);
        System.assert(response.contains('FIELD_INTEGRITY_EXCEPTION'));
        Test.stopTest();
    }
*/
    @isTest
    static void testMethod_getProductsItems(){
        
        Id locationId = [Select Id From Location Where Name = 'Estoque de RBI 2' Limit 1].Id;
        ServiceResource sr = [Select Id,Email__c,LocationId From ServiceResource Limit 1];
        sr.Email__c = UserInfo.getUserEmail();
        sr.LocationId = locationId;
        update sr;
        
        id recordTypeEquipamentId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Equipamento').getRecordTypeId();
        Product2 product = new Product2();
        product.Name = 'TL - WR840N';
        product.ProductCode = 'EST01039';
        product.Description = 'TL - WR840N';
        product.Family = 'ONU/Roteador';
        product.IsSerialized = false;
        product.RecordTypeId = recordTypeEquipamentId;
        product.isActive = true;
        insert product;

        ProductItem productItem = new ProductItem();
        productItem.QuantityOnHand = 1;
        productItem.QuantityUnitOfMeasure = 'Each';
        productItem.Product2Id = product.Id;
        productItem.LocationId = locationId;
        productItem.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        insert productItem;

        // SerializedProduct serializedProduct = new SerializedProduct();
        // serializedProduct.Product2Id = product.Id;
        // serializedProduct.ProductItemId = productItem.Id;
        // serializedProduct.Status = 'Available';
        // serializedProduct.SerialNumber = '321321321';

        // insert serializedProduct;
        
        Id workStepId = [Select Id From WorkStep Limit 1].Id;

        Test.startTest();
        List<EquipmentConsumptionController.ProductItemVO> response = EquipmentConsumptionController.getProductsItems(workStepId);
        System.assert(response!=null);
        Test.stopTest();
    }

    @isTest
    static void testMethod_insertSerializedProduct(){
        
        Id locationId = [Select Id From Location Where Name = 'Estoque de RBI 2' Limit 1].Id;
        ServiceResource sr = [Select Id,Email__c,LocationId From ServiceResource Limit 1];
        sr.Email__c = UserInfo.getUserEmail();
        sr.LocationId = locationId;
        update sr;
        
        id recordTypeEquipamentId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Equipamento').getRecordTypeId();
        Product2 product = new Product2();
        product.Name = 'TL - WR840N';
        product.ProductCode = 'EST01039';
        product.Description = 'TL - WR840N';
        product.Family = 'ONU/Roteador';
        product.IsSerialized = true;
        product.RecordTypeId = recordTypeEquipamentId;
        product.isActive = true;
        product.SerialNumber__c = '123465';
        insert product;

        ProductItem productItem = new ProductItem();
        productItem.QuantityOnHand = 0;
        productItem.QuantityUnitOfMeasure = 'Each';
        productItem.Product2Id = product.Id;
        productItem.LocationId = locationId;
        productItem.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        productItem.SerialNumber__c = product.SerialNumber__c;
        insert productItem;
       
        Id workStepId = [Select Id From WorkStep Limit 1].Id;

        Test.startTest();
        List<EquipmentConsumptionController.ProductItemVO> response = EquipmentConsumptionController.getProductsItems(workStepId);
        System.assert(response!=null);
        Test.stopTest();
    }

    @isTest
    static void validateSerializedProducts(){
        Id workStepId = [SELECT Id FROM WorkStep Limit 1].Id;
        User us = new User();
        us = [SELECT id FROM User WHERE email = 'tsttech1@ftech.demo' LIMIT 1];
        System.runAs(us){
            Test.startTest();
            EquipmentConsumptionController.getEquipment(workStepId);
            Test.stopTest();
        }
    }

    @isTest
    static void validateGetSerialized(){
        //Id workStepId = [SELECT Id FROM WorkStep Limit 1].Id;
        ProductItem pi = [SELECT id,ProductItemNumber FROM ProductItem WHERE Product2.IsSerialized= true AND QuantityOnHand >0 AND Id IN (SELECT ProductItemId FROM SerializedProduct WHERE SerialNumber = '321321321') LIMIT 1];
       
        Test.startTest();
        EquipmentConsumptionController.getSerialized('321321321', pi.ProductItemNumber);
        Test.stopTest();
    }
    
    @isTest
    static void validateGetAssetInfo(){
        Id workorderid = [SELECT Id,workorderid FROM WorkStep Limit 1].workorderid;
        Test.startTest();
        EquipmentConsumptionController.getAssetInfo(String.valueOf(workorderid));
        Test.stopTest();
    }
    
    @isTest
    static void validateupdateStatusField(){
        Id workStepid = [SELECT Id,workorderid FROM WorkStep Limit 1].Id;
        Test.startTest();
        EquipmentConsumptionController.updateStatusField(workStepid);
        Test.stopTest();
    }
    
}
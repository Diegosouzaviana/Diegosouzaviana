@isTest
public with sharing class DeleteSerializedControllerTest {
    @TestSetup
    static void setup(){
        
        vlocity_cmt__ObjectClass__c obj = new vlocity_cmt__ObjectClass__c();
        obj.Name = 'Plano Desktop';
        obj.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert obj;

        RecordType rtEq = [SELECT Id FROM RecordType WHERE DeveloperName = 'Equipamento'];
    
        List<Product2> product2List = new List<Product2>();
        Product2 p2 = new Product2(
            CanUseQuantitySchedule  = true,
            CanUseRevenueSchedule   = true,
            Description             = '36',
            IsActive                = true,
            IsSerialized            = true,
            Name                    = 'STB Kamai 500',
            ProductCode             = '36',
            RecordTypeId            = rtEq.Id,
            vlocity_cmt__ObjectTypeId__c = obj.Id
        );
        product2List.add(p2);
        insert product2List;
        
        List<Schema.Location> listLocation = new List<Schema.Location>();
        Schema.Location location1 = new Schema.Location();
        location1.Name = 'Estoque de TESTE';
        location1.LocationType = 'Warehouse';
        location1.TimeZone = 'America/Sao_Paulo';
        location1.IsInventoryLocation=true;
        location1.IsMobile=true;
        listLocation.add(location1);

        Schema.Location location2 = new Schema.Location();
        location2.Name = 'Estoque de TESTE 2';
        location2.LocationType = 'Warehouse';
        location2.TimeZone = 'America/Sao_Paulo';
        location2.IsInventoryLocation=true;
        location2.IsMobile=true;
        listLocation.add(location2);
        insert listLocation;

        ProductItem pi = new ProductItem();
        pi.QuantityOnHand = 0;
        pi.QuantityUnitOfMeasure = 'Each';
        pi.Product2Id = p2.Id;
        pi.LocationId = location1.Id;
        pi.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        insert pi;

        List<SerializedProduct> listSp = new List<SerializedProduct>();
        SerializedProduct sp = new SerializedProduct();
        sp.ProductItemId = pi.id;
        sp.Product2Id = p2.Id;
        sp.SerialNumber = 'TESTEDELETE01';
        sp.Status = 'Available';
        sp.MAC__c = 'TESTEDELETE01';
        sp.CodigoAtivoSP__c = 'TESTEDELETE01';
        listSp.add(sp);

        SerializedProduct sp1 = new SerializedProduct();
        sp1.ProductItemId = pi.id;
        sp1.Product2Id = p2.Id;
        sp1.SerialNumber = 'TESTEDELETE02';
        sp1.Status = 'Available';
        sp1.MAC__c = 'TESTEDELETE02';
        sp1.CodigoAtivoSP__c = 'TESTEDELETE02';
        listSp.add(sp1);
        insert listSp;

        ProductTransfer pt = new ProductTransfer();
        pt.QuantitySent = 2;
        pt.SourceProductItemId = pi.Id;
        pt.SourceLocationId = location1.Id;
        pt.DestinationLocationId = location2.Id;
        pt.QuantityUnitOfMeasure = 'Each';
        insert pt;

        List<ProductTransferState> listPts = new List<ProductTransferState>();
        ProductTransferState pts = new ProductTransferState();
        pts.productTransferId = pt.id;
        pts.SerializedProductId = sp.Id;
        pts.Action = 'Send';
        pts.TransferState = 'Sent';
        listPts.add(pts);

        ProductTransferState pts1 = new ProductTransferState();
        pts1.productTransferId = pt.id;
        pts1.SerializedProductId = sp1.Id;
        pts1.Action = 'Send';
        pts1.TransferState = 'Sent';
        listPts.add(pts1);
        insert listPts;
    }

    @IsTest
    static void DeleteSerializedControllerTest() {
        List<SerializedProduct> spList = new List<SerializedProduct>();
        spList = [SELECT id, serialNumber FROM SerializedProduct LIMIT 1];
        List<String> listStr = new List<String>();
        for(SerializedProduct sp : spList){
            listStr.add(String.valueOf(sp.SerialNumber));
        }
        Test.startTest();
        if(listStr.size()>0){
            DeleteSerializedController.deleteRecords(listStr);
        }
        Test.stopTest();
    }

    @IsTest
    static void tratarMensagemTest(){

        Test.startTest();
        DeleteSerializedController.tratarMensagem('entity is deleted');
        DeleteSerializedController.tratarMensagem('malformed id');
        DeleteSerializedController.tratarMensagem('only test');
        Test.stopTest();
    }
}
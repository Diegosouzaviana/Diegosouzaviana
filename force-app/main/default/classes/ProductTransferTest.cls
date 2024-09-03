@IsTest
public class ProductTransferTest {
    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
        Schema.Location l = new Schema.Location();
        l.latitude=-23.49093930803577;
        l.longitude=-47.51609786262823;
        l.Name='location name';
        //l.LocationId__c='123456';
        l.IsInventoryLocation=true;
        l.IsMobile=true;
        l.LocationType='Warehouse';
        insert l;
        Schema.Location l2 = new Schema.Location();
        l2.latitude=-23.49093930809843;
        l2.longitude=-47.51609786260812;
        l2.Name='location name 2';
        //l2.LocationId__c='654321';
        l2.IsInventoryLocation=true;
        l2.IsMobile=true;
        l2.LocationType='Warehouse';
        insert l2;
        System.debug('locationId '+l.Id);
        System.debug('locationId 2 '+l2.Id);
        User tech = [SELECT Id, UserName, FirstName,LastName FROM User WHERE Alias = 'tsttech1'];

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

        
        ServiceResource sr = [SELECT Name, RelatedRecordId, LocationId FROM ServiceResource LIMIT 1];
        sr.LocationId=l.Id;
        sr.RelatedRecordId=tech.Id;
        update sr;
        ProductItem productItem = new ProductItem();
        productItem.QuantityOnHand = 0;
        productItem.QuantityUnitOfMeasure = 'Each';
        productItem.Product2Id = product.Id;
        productItem.LocationId = sr.LocationId;
        productItem.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
        insert productItem;
        System.debug('LocationId in test '+sr.LocationId + ' '+sr.RelatedRecordId);
        SerializedProduct serializedProduct = new SerializedProduct();
        serializedProduct.Product2Id = product.Id;
        serializedProduct.ProductItemId = productItem.Id;
        serializedProduct.Status = 'Available';
        serializedProduct.SerialNumber = '123465';
        insert serializedProduct;

        List<ProductTransfer> ptrList = new List<ProductTransfer>();
        ProductTransfer ptr = new ProductTransfer(
            IsReceived=true,
            //Product2Id = product.Id,
            UpdatedTrigger__c=false,
            AcceptURL__c = '/services/apexrest/setAppointmentBookingSlot',
            QuantitySent=2,
            QuantityReceived=2,
            OwnerId=tech.Id
            //DestinationLocationId=sr.LocationId
        );
        ProductTransfer ptr2 = new ProductTransfer(
            //Product2Id = product.Id,
            NotReceived__c=true,
            UpdatedTrigger__c=false,
            AcceptURL__c = '/services/apexrest/setAppointmentBookingSlot',
            QuantitySent=2,
            QuantityReceived=2,
            DestinationLocationId=l.Id,
            OwnerId=tech.Id
        );
        ProductTransfer ptr3 = new ProductTransfer(
            Product2Id = product.Id,
            SerialNumber__c = '123465',
            NotReceived__c=true,
            UpdatedTrigger__c=false,
            AcceptURL__c = '/services/apexrest/setAppointmentBookingSlot',
            DeclineURL__c = '/services/apexrest/setAppointmentBookingSlot',
            QuantitySent=1,
            QuantityReceived=1,
            DestinationLocationId=l.Id,
            OwnerId=tech.Id,
            SourceProductItemId = productItem.Id
        );
        insert ptr;
        insert ptr2;
        insert ptr3;
    }

    @IsTest
    public static void ProductTransferHandler(){
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(200, 'application/json', ''));
        Test.startTest();
        ProductTransfer ptr = [SELECT Id, NotReceived__c FROM ProductTransfer WHERE QuantitySent = 2 Order by CreatedDate asc LIMIT 1];
        ptr.NotReceived__c=false;
        update ptr;
        Test.stopTest();
    }

    @IsTest
    static void DeclineProductTransferHandler(){
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(200, 'application/json', ''));

        Test.startTest();
        ProductTransfer ptr = [SELECT Id, DeclineURL__c FROM ProductTransfer WHERE NotReceived__c = true LIMIT 1];
        //And IsReceived = false
        ptr.DeclineURL__c='/services/apexrest/setAppointmentBookingSlot';
        update ptr;
        Test.stopTest();    
    }

    @IsTest
    static void DeleteProductTransferHandler(){
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(200, 'application/json', ''));

        Test.startTest();
        List<ProductTransfer> ptList = new List<ProductTransfer>();
        Product2 p2 = [SELECT RecordType.DeveloperName, ProductCode, Id FROM Product2 WHERE IsSerialized = TRUE LIMIT 1];
        ProductTransfer ptr = [SELECT Id, DeclineURL__c FROM ProductTransfer WHERE Product2Id = :p2.Id LIMIT 1];
        delete ptr;
        Test.stopTest();    
    }

    @IsTest
    static void testMakeCallback(){
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(200, 'application/json', ''));
        Test.startTest();
        ProductTransferHandler.MakeCallback('/services/apexrest/setAppointmentBookingSlot');
        Test.stopTest(); 
    }
 
    @IsTest
    static void DeclineProductTransferHandler2(){
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(200, 'application/json', ''));
        ProductTransfer ptr = [SELECT Id, DeclineURL__c FROM ProductTransfer WHERE NotReceived__c = true LIMIT 1];
        //And IsReceived = false
        ptr.DeclineURL__c='/services/apexrest/setAppointmentBookingSlot';
        Test.startTest();
        ProductTransferHandler.RecordsDeclineMethod(true, ptr.id);
        Test.stopTest();    
    }
}
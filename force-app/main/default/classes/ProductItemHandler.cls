public class ProductItemHandler {

    public static void InsertSerializedProduct(List<ProductItem> productList) {
        String RecordTypeProduct, SerialNumber = null;
        Boolean IsSerialized = false;
        Id Product2Id, ProductItem, Product2OwnerId;
        List<SerializedProduct> SerializedProductList = new List<SerializedProduct>();
        Map<Id, List<SerializedProduct>> ProductItemSerializedPMap = new Map<Id, List<SerializedProduct>>();
        try {
            for (ProductItem p : productList) {
                ProductItem = p.Id;
                Product2Id = p.Product2Id;
                SerialNumber    = p.SerialNumber__c;
            }
            Product2 p = [SELECT CreatedById, IsSerialized, RecordType.DeveloperName FROM Product2 WHERE Id = :Product2Id AND IsActive = true];
            RecordTypeProduct = p.RecordType.DeveloperName;
            Product2OwnerId = p.CreatedById;
            IsSerialized = p.IsSerialized;
            /*if (IsSerialized && SerialNumber != null && RecordTypeProduct.equals('Equipamento')) {
            
                SerializedProduct sr = new SerializedProduct(
                    Product2Id      = Product2Id,
                    ProductItemId   = ProductItem,
                    OwnerId         = Product2OwnerId,
                    SerialNumber    = SerialNumber
                );
                
                insert sr;           
            } else {
                System.debug('Não criou registro em Prouto Serializado pois...');
                System.debug('RecordType '+RecordTypeProduct);
                System.debug('IsSerialized '+IsSerialized);
                System.debug('SerialNumber '+SerialNumber);
            }*/
        } catch (Exception ex) {
            System.debug('Erro ao inserir produto serializado '+ ex.getStackTraceString() + ' '+ex.getMessage());
        }
    }
}
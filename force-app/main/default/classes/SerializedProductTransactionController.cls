public class SerializedProductTransactionController {
    public static List<Id> SerializedProductIdList;
    public static void GetSerializedProduct(List<ProductTransfer> ptList) {
        String RelatedRecordOld, RelatedRecordNew, SerialNumberString = '';
        Id ProductTransferId;
        List<Id> listId = new List<Id>();
        List<String> SerialNumberList = new List<String>();
        List<String> AllSerialNumberList = new List<String>();
        Boolean IsSerialized = false;
        try {
            for (ProductTransfer sp : ptList) {
                if (String.isNotBlank(sp.SerialNumber__c)) {
                    AllSerialNumberList.add(sp.SerialNumber__c);
                }
                IsSerialized = sp.IsProduct2Serialized;
            }
            if (IsSerialized) {
                String delimiter = ',';
                for (Integer i = 0; i < AllSerialNumberList.size(); i++) {
                    if (i == AllSerialNumberList.size()-1) {
                        SerialNumberString += AllSerialNumberList[i];
                    } else {
                        SerialNumberString += AllSerialNumberList[i] + ',';
                    }
                }
                if (String.isNotBlank(SerialNumberString)) {
                    if (SerialNumberString.contains(',')) {
                        SerialNumberList = SerialNumberString.split(',');
                    } else {
                        SerialNumberList.add(SerialNumberString);
                    }
                    List<SerializedProduct> sProductList = [SELECT Id FROM SerializedProduct WHERE SerialNumber = :SerialNumberList];
    
                    if (sProductList.size() > 0) {
                        for (SerializedProduct sp : [SELECT Id FROM SerializedProduct WHERE SerialNumber = :SerialNumberList]) {
                            listId.add(sp.Id);
                            //SerializedProductIdList.add(sp.Id);
                        }
                        SerializedProductIdList = listId;
                    } else {
                        System.debug('Não encontrado Produto Serializado com serial number: '+JSON.serialize(SerialNumberList));
                    }
                } else {
                    System.debug(SerialNumberString + '=isBlank');
                }
            }
        } catch (Exception e) {
            System.debug('Erro ao atualizar status SerializedProductTransaction '+e.getMessage() + ' - ' +e.getStackTraceString());
        }
    }

    public static void UpdateStatusSerializedProduct() {
        try {
            List<Id> SerializedProductIdToUpdateList = new List<Id>();
            List<SerializedProduct> SerializedProductToUpdate = new List<SerializedProduct>();
            if (SerializedProductIdList != null) {
                if (SerializedProductIdList.size() > 0) {
                    System.debug(JSON.serialize(SerializedProductIdList));

                    for (SerializedProductTransaction spt : [SELECT SerializedProductId, Id FROM SerializedProductTransaction WHERE SerializedProductId IN :SerializedProductIdList AND RelatedRecordId = NULL]) {
                        SerializedProductIdToUpdateList.add(spt.SerializedProductId);
                    }

                    if (SerializedProductIdToUpdateList.size() > 0) {
                        for (SerializedProduct sp : [SELECT Id, Status FROM SerializedProduct WHERE Id IN :SerializedProductIdToUpdateList]) {
                            sp.Status = 'Available';
                            SerializedProductToUpdate.add(sp);
                        }

                        if (SerializedProductToUpdate.size() > 0) {
                            update SerializedProductToUpdate;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Erro ao alterar status '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }
}
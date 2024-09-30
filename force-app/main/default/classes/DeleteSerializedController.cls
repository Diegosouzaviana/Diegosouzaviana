global with sharing class DeleteSerializedController {
    
    @InvocableMethod(label='Deleção de registros serializados - DeleteSerializedController')
    global static void deleteRecords(List<String> ids){

        Savepoint sp = Database.setSavepoint();
        List<String> listIds = new List<String>();
        for(String s : ids){
            
            System.debug('s -> ' + s);
            if(s.contains(',')){
                System.debug('Contém ,');
                listIds.addAll(s.split(','));
            }else{
                System.debug('Não contém ,');
                listIds.add(s);
            }
        }

        System.debug('listIds -> ' + listIds);
        
        //deleteAllRecords(listIds);
        List<Database.DeleteResult> result = new List<Database.DeleteResult>();
        try{
            result = deleteAllRecords(listIds);
        }catch(Exception ex){  
            Database.rollback(sp);
        }

        String sucesso = 'Sucesso';
        
        ResWrapper resp = new ResWrapper();
        resp.erros = new List<Erros>();
        resp.ids = String.valueOf(ids);

        IntegrationLog__c iLog = new IntegrationLog__c();
        iLog.ExecutionDate__c = DateTime.now();
        iLog.Flow__c = 'Inbound';
        iLog.Integration__c = 'Deleção serializado';
        iLog.Name = 'Deleção serializado';
        for (Database.DeleteResult sr : result) {
            if (!sr.isSuccess()) {
                sucesso = 'Erro';
                System.debug('Erro ao deletar o registro X');
                Erros er = new Erros();
                er.serial = sr.getId();
                for(Database.Error e : sr.getErrors()){
                    System.debug('e -> '+ e);
                    er.mensagemSerial = tratarMensagem(e.getmessage());
                    break;
                }
                resp.erros.add(er);
            }
        }
        
        iLog.LogStatus__c = sucesso;
        iLog.LogResult__c = String.valueOf(resp);
        insert iLog;

    }

    public static List<Database.DeleteResult> deleteAllRecords(List<String> listIds){
        List<SObject> delList = new List<SObject>();

        List<ProductTransfer> ptsList = new List<ProductTransfer>();
        List<ProductConsumedState> pcsList = new List<ProductConsumedState>();
        List<SerializedProduct> serList = new List<SerializedProduct>();
        System.debug('listIds 2 -> ' + listIds);

        ptsList = [SELECT id, Status, isSent, AcceptURL__c, DestinationLocationId, DeclineURL__c, Product2Id, QuantityUnitOfMeasure, SourceProductItemId, SourceLocationId, IsReceived, QuantitySent, QuantityReceived, (SELECT id, SerializedProductId, SerializedProduct.SerialNumber, SerializedProduct.Status, Action, TransferState FROM ProductTransferStates) FROM ProductTransfer WHERE Id IN (SELECT ProductTransferId FROM ProductTransferState WHERE SerializedProductId IN : listIds OR SerializedProduct.SerialNumber IN : listIds)];
        System.debug('ptsList -> ' + ptsList);
        //Map<ProductItemId, QuantityToDelete>
        Map<String, Integer> mapQT = new Map<String, Integer>();

        //Map<ProductItemId, QuantityOnHand>
        Map<String, Integer> mapPI = new Map<String, Integer>();
    
        List<Database.DeleteResult> result = new List<Database.DeleteResult>();
        if(ptsList.size()>0){
            //result.addAll(deleteTransfer(listIds,ptsList));
            System.debug('Deleção de productTransfer => '+ptsList);
            deleteTransfer(listIds,ptsList);
        }
        
        pcsList = [SELECT id FROM ProductConsumedState WHERE SerializedProductId IN : listIds OR SerializedProduct.SerialNumber IN : listIds];
        System.debug('pcsList -> ' + pcsList);
        if(pcsList.size()>0){
            result.addAll(Database.delete(pcsList, false));
        }
        
        serList = [SELECT id, ProductItemId, ProductItem.QuantityOnHand FROM SerializedProduct WHERE id IN : listIds OR SerialNumber IN : listIds];
        List<ProductItem> listPi = new List<ProductItem>();
        System.debug('serList -> ' + serList);
        if(serList.size()>0){
            for(SerializedProduct sp : serList){
                if(String.valueOf(sp.ProductItemId) != '' && sp.ProductItemId != null){
                    if(mapQt.containsKey(String.valueof(sp.ProductItemId))){
                        mapQT.put(String.valueOf(sp.ProductItemId), mapQt.get(String.ValueOf(sp.ProductItemId)) + 1);
                    }else{
                        mapQT.put(String.valueOf(sp.ProductItemId), 1);
                    }
                    mapPI.put(String.valueOf(sp.ProductItemId), Integer.valueOf(sp.ProductItem.QuantityOnHand));
                }
            }
            if(mapQT.size()>0){
                for(String st : mapQt.keySet()){
                    ProductItem pi = new ProductItem();
                    pi.Id = st;
                    System.debug('mapPI.get(st) => '+ mapPI.get(st));
                    System.debug('mapQt.get(st) => '+ mapQt.get(st));
                    System.debug('listPi => '+ listPi);
                    if(mapPI.get(st) == mapQt.get(st) && !listPi.contains(pi)){
                        listPi.add(pi);
                    }
                }
            }
            if(listPi.size()>0){
                result.addAll(Database.delete(listPi, false));
            }
            result.addAll(Database.delete(serList, false));
        }

        /*List<Database.DeleteResult> result = new List<Database.DeleteResult>();
        if(delList.size()>0){
            result = Database.delete(delList, false);
        }*/

        return result;
    }

    
    public class ResWrapper{
        public String mensagem {get;set;}
        public List<Erros> erros {get;set;}
        public String ids {get;set;}
    }
    public class Erros{
        public String serial {get; set;}
        public String mensagemSerial {get; set;}
    }
    public static String tratarMensagem(String mensagem){

        switch on mensagem{
            when 'entity is deleted'{
                return 'Registros já deletados';
            }
            when else{
                if(mensagem.contains('malformed id')){
                    return 'Dado inválido';
                }
            }
        }
        return mensagem;
    }

    //public static List<Database.DeleteResult> deleteTransfer(List<String> listIds, List<ProductTransfer> ptsList){
    public static void deleteTransfer(List<String> listIds, List<ProductTransfer> ptsList){

        List<ProductTransfer> transferClone = new List<ProductTransfer>();
        List<ProductTransfer> transferDelete = new List<ProductTransfer>();
        Map<String, List<ProductTransferState>> mapPt = new Map<String, List<ProductTransferState>>();
        List<SerializedProduct> listProduct = new List<SerializedProduct>();
        for(ProductTransfer pt : ptsList){
            
            System.debug('pt => '+pt);
            transferDelete.add(pt);
            if(pt.IsReceived == false && pt.ProductTransferStates.size()>0){
                Integer i = 0;
                for(ProductTransferState pts : pt.ProductTransferStates){
                    System.debug('pts => '+pts);
                    System.debug('i => '+i);
                    if(listIds.contains(pts.SerializedProduct.serialNumber)){
                        i++;
                    }else{
                        //Salva os states que precisarão ser replicados para a outra transferência
                        ProductTransferState clonedPts = pts.clone(false, true, true, false);
                        clonedPts.ProductTransferId = null;
                        clonedPts.Action = 'Send';
                        clonedPts.TransferState = 'Sent';
                        System.debug('clonedPts => '+clonedPts);
                        if(mapPt.containsKey(String.valueOf(pt.Id))){
                            mapPt.get(String.valueOf(pt.Id)).add(clonedPts);
                        }else{
                            mapPt.put(String.valueOf(pt.Id), new List<ProductTransferState>{clonedPts});
                        }
                        SerializedProduct sp = new SerializedProduct();
                        sp.Id = pts.serializedProductId;
                        sp.Status = 'Available';
                        if(!listProduct.contains(sp)){
                            listProduct.add(sp);
                        }
                    }
                }
                if(pt.QuantitySent > i){
                    ProductTransfer clonedPt = new ProductTransfer();
                    clonedPt = pt.clone(false, true, true, false);
                    clonedPt.id = null;
                    clonedPt.QuantitySent -= i;
                    clonedPt.isSent = false;
                    System.debug('clonePt => '+clonedPt);
                    System.debug('getCloneSourceId => '+clonedPt.getCloneSourceId());
                    transferClone.add(clonedPt);
                    //Necessário clonar a product transfer para remover o serializado
                }
            }
        }
        List<ProductTransferState> pts = new List<ProductTransferState>();
        if(transferClone.size()>0){
            System.debug('transferClone => '+transferClone);
            Database.insert(transferClone, true);
            for(ProductTransfer pt : transferClone){
                System.debug('getCloneSourceId2 => '+pt.getCloneSourceId());
                if(mapPt.containsKey(String.valueOf(pt.getCloneSourceId()))){
                    for(ProductTransferState stat: mapPt.get(String.valueOf(pt.getCloneSourceId()))){
                        stat.ProductTransferId = pt.id;
                        pts.add(stat);
                    }
                }
            }
        }
        if(transferDelete.size()>0){
            System.debug('transferDelete => '+transferDelete);
            Database.delete(transferDelete, true);
            System.debug('listProduct => '+listProduct);  
            if(listProduct.size()>0){   
                Database.update(listProduct, true);
            }
        }
        if(pts.size()>0){
            System.debug('pts insert => '+pts);
            Database.insert(pts, true);
            // if(transferClone.size()>0){
            //     List<ProductTransfer> ptList = new List<ProductTransfer>();
            //     for(ProductTransfer pt : transferClone){
            //         pt.isSent = true;
            //         ptList.add(pt);
            //     }
            //     System.debug('ptList => '+ptList);
            //     Database.update(ptList, true);
            // }
        }
    }
}
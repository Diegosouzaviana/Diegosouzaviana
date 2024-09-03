public with sharing class ContratoUpdater {
    
    public static void updateContractStatus(List<Id> contratoIds) {
        System.debug('aqui');
        List<Contract> contratosToUpdate = [SELECT Id, Status, CreatedBy.Name FROM Contract WHERE Id IN :contratoIds];
        System.debug('contratoIds: ' + contratoIds.size());
        for (Contract contrato : contratosToUpdate) {
            if (contrato.Status == 'Pre-Bloqueado' && (contrato.CreatedBy.Name == 'Sync de Dados' || contrato.CreatedBy.Name == 'Easyware Integration')) {
                System.debug('Bloqueado!');
                contrato.Status = 'Bloqueado';
            } else if (contrato.Status == 'Pre-Ativo' && (contrato.CreatedBy.Name == 'Sync de Dados' || contrato.CreatedBy.Name == 'Easyware Integration')) {
                System.debug('ATIVO!');
                contrato.Status = 'ATIVO';
            }   else if (contrato.Status == 'Pre-Cancelado' && (contrato.CreatedBy.Name == 'Sync de Dados' || contrato.CreatedBy.Name == 'Easyware Integration')) {
                System.debug('Cancelado!');
                contrato.Status = 'Cancelado';
            }   
        }
        update contratosToUpdate;
    }

    /*
    public static void beforeUpdateContractStatus(List<Contract> contractListNew, Map<Id, Contract> mapContract) {
        System.debug('Before Update');
        for(Contract contrato : contractListNew) {
            if((contrato.Status == 'Pre-Bloqueado' || contrato.Status == 'Pre-Cancelado' || contrato.Status == 'Pre-Ativo') && mapContract.get(contrato.Id).Status != contrato.Status){  
                System.debug('IF 1');              
                
                if(contrato.Status == 'Pre-Bloqueado'){
                    contrato.Status = 'Bloqueado';
                    System.debug('Block');
                }
                if(contrato.Status == 'Pre-Cancelado'){
                    contrato.Status = 'Cancelado';
                    System.debug('Cancel');
                }
                if(contrato.Status == 'Pre-Ativo'){
                    contrato.Status = 'Ativo';
                    System.debug('Active');
                }
            }
        }
    }
    */
}
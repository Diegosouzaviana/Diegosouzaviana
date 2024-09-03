public with sharing class CancelamentoCompulsorioService {
    public static void automacaoCancelamento(List<Account> lstAccount, Map<Id, Account> oldMapAccount) {
        List<Case> lstCasos = new List<Case>();
        List<WorkOrder> lstWO = new List<WorkOrder>();
        Map<Id, Id> accountIdToCaseId = new Map<Id, Id>(); // Para mapear Account Id para Case Id
    
        Id recordTypeSolicitacao = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Solicitação').getRecordTypeId();
        Id recordTypeRetirada = Schema.sObjectType.WorkOrder.getRecordTypeInfosByName().get('Retirada de equipamento').getRecordTypeId();
    
        Set<Id> idBilling = new Set<Id>();
        for (Account acc : lstAccount) {
            if (acc.CancelamentoCompulsorio__c && oldMapAccount.containsKey(acc.Id) && !oldMapAccount.get(acc.Id).CancelamentoCompulsorio__c) {
                idBilling.add(acc.Id);
            }
        }
    
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c,
            vlocity_cmt__ServiceAccountId__r.ShippingAddressNumber__c,
            vlocity_cmt__ServiceAccountId__r.ShippingCity,
            vlocity_cmt__ServiceAccountId__r.ShippingState,
            vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
            OLTLookup__c,
            OLTLookup__r.ServiceTerritory__c,
            SiglaCTO__c,
            CaixaCTO__c,
            PortaCTO__c,
            vlocity_cmt__ContractId__c,
            ContactId
            FROM Asset
            WHERE vlocity_cmt__BillingAccountId__c IN :idBilling AND Product2.RecordType.Name = 'Product'
        ];

        WorkType wt = [SELECT ID FROM WorkType WHERE Name = 'Retirada de Equipamento - Cancelamento Compulsório' LIMIT 1];
    
        Map<Id, Asset> mapAsset = new Map<Id, Asset>();
        for(Asset ativo : lstAtivos){
            mapAsset.put(ativo.vlocity_cmt__BillingAccountId__c, ativo);
        }
    
        for (Account acc : lstAccount) {
            if (acc.CancelamentoCompulsorio__c && oldMapAccount.containsKey(acc.Id) && !oldMapAccount.get(acc.Id).CancelamentoCompulsorio__c && mapAsset.containsKey(acc.Id)) {
                Asset ativo = mapAsset.get(acc.Id);
                Case caso = new Case (
                    AccountId = acc.ParentId,
                    RecordTypeId = recordTypeSolicitacao,
                    motive__c = 'Cancelamento De Contrato',
                    submotive__c = 'Financeiro Cancelamento Compulsorio',
                    Departamento__c = 'Faturamento',
                    AssetId = ativo.Id,
                    Endereco_de_Atendimento__City__s = acc.BillingCity,
                    Endereco_de_Atendimento__StateCode__s = acc.BillingState,
                    Endereco_de_Atendimento__Street__s = acc.BillingAddressNumber__c,
                    Endereco_de_Atendimento__PostalCode__s = acc.BillingPostalCode,
                    Contrato__c = ativo.vlocity_cmt__ContractId__c

                );
                lstCasos.add(caso);
    
                WorkOrder os = new WorkOrder(
                    RecordTypeId = recordTypeRetirada,
                    Status = 'On Hold',
                    AccountId = acc.ParentId,
                    Work_Subtype_WO__c = 'Cancelamento Compulsório',
                    Street = ativo.vlocity_cmt__ServiceAccountId__r.ShippingAddressNumber__c,
                    City = ativo.vlocity_cmt__ServiceAccountId__r.ShippingCity,
                    State = ativo.vlocity_cmt__ServiceAccountId__r.ShippingState,
                    PostalCode = ativo.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,
                    OLT__c = ativo.OLTLookup__c,
                    CTO__c = ativo.SiglaCTO__c + '-' + ativo.CaixaCTO__c,
                    Porta__c = Double.valueOf(ativo.PortaCTO__c),
                    AssetId = ativo.Id,
                    Country = 'Brasil',
                    CaseReason__c = 'Cancelamento De Contrato',
                    CaseSubreason__c = 'Financeiro Cancelamento Compulsorio',
                    ServiceTerritoryId = ativo.OLTLookup__r.ServiceTerritory__c,
                    WorkTypeId = wt.Id,
                    ContactId = ativo.ContactId
                );
                lstWO.add(os);
    
                // Mapeando o AccountId para o CaseId
                accountIdToCaseId.put(acc.ParentId, caso.Id);
            }
        }
    
        insert lstCasos;
        insert lstWO;
        
        for (Case caso : lstCasos) {
            accountIdToCaseId.put(caso.AccountId, caso.Id);
        }

        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        for (WorkOrder wo : lstWO) {
            if (accountIdToCaseId.containsKey(wo.AccountId)) {
                System.debug('accountIdToCaseId.get(wo.AccountId): ' + accountIdToCaseId.get(wo.AccountId));
                wo.CaseId = accountIdToCaseId.get(wo.AccountId);
                workOrdersToUpdate.add(wo);
            }
        }
        if (!workOrdersToUpdate.isEmpty()) {
            update workOrdersToUpdate;
        }
    }    
}
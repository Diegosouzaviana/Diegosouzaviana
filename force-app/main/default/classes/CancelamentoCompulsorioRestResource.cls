@RestResource(urlMapping = '/CancelamentoCompulsorio/*') global with sharing
    class CancelamentoCompulsorioRestResource {

    @HttpPost 
    global static List<ResponseWrapper> doPost(List<AccountIdWrapper> listLegacyId) {
        List<ResponseWrapper> retorno = new List<ResponseWrapper>();
        List<String> legacyIdList = new List<String>();
        List<Case> lstCasos = new List<Case>();
        List<String> idWO = new List<String>();
        List<WorkOrder> lstWO = new List<WorkOrder>();
        Map<String, Id> accountIdToCaseId = new Map<String, Id>();
        Map<String, String> caseToBilling = new Map<String, String>();
        Map<String, String> woToBilling = new Map<String, String>();
        Map<String, String> mapLegacyId = new Map<String, String>();
        for(AccountIdWrapper req : listLegacyId){
            legacyIdList.add(req.legacyId);
        }

        List<Account> lstAccount = [SELECT Id, LegacyId__c, ParentId, BillingCity, BillingState, 
            BillingAddressNumber__c, BillingPostalCode
            FROM Account WHERE LegacyId__c IN :legacyIdList AND RecordType.Name = 'Billing'
        ];

        if(lstAccount.isEmpty()){
            ResponseWrapper responseError = new ResponseWrapper();
            responseError.error = 'Nenhuma conta encontrada com o LegacyId informado';
            RestContext.response.statusCode = 404;
            retorno.add(responseError);

            return retorno;
        }

    
        Id recordTypeSolicitacao = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Solicitação').getRecordTypeId();
        Id recordTypeRetirada = Schema.sObjectType.WorkOrder.getRecordTypeInfosByName().get('Retirada de equipamento').getRecordTypeId();
    
        Set<Id> idBilling = new Set<Id>();
        for (Account acc : lstAccount) {
            acc.CancelamentoCompulsorio__c = true;
            idBilling.add(acc.Id);
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
            WHERE vlocity_cmt__BillingAccountId__c IN :idBilling AND ProductObjectType__c = 'Plano Desktop'
        ];

        WorkType wt = [SELECT ID FROM WorkType WHERE Name = 'Retirada de Equipamento - Cancelamento Compulsório' LIMIT 1];
    
        Map<Id, Asset> mapAsset = new Map<Id, Asset>();
        for(Asset ativo : lstAtivos){
            mapAsset.put(ativo.vlocity_cmt__BillingAccountId__c, ativo);
        }
    
        for (Account acc : lstAccount) {
            if (mapAsset.containsKey(acc.Id)) {
                Asset ativo = mapAsset.get(acc.Id);
                Case caso = new Case (
                    AccountId = acc.ParentId,
                    RecordTypeId = recordTypeSolicitacao,
                    motive__c = 'Cancelamento Compulsorio',
                    submotive__c = 'Cancelamento Compulsorio',
                    Area_de_atendimento__c = 'Faturamento',
                    AssetId = ativo.Id,
                    vlocity_cmt__BillingAccountId__c = acc.Id,
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
                    BillingAccount__c = acc.Id,
                    ContactId = ativo.ContactId
                );
                lstWO.add(os);
    
                // Mapeando o AccountId para o CaseId
                accountIdToCaseId.put(acc.ParentId, caso.Id);
                mapLegacyId.put(acc.Id, acc.LegacyId__c);
            } else{
                ResponseWrapper response = new ResponseWrapper();
                response.accountLegacyId = acc.LegacyId__c;
                response.error = 'Nenhum asset comercial encontrado para esse conta';
                retorno.add(response);
            }
        }
    
        insert lstCasos;
        
        for (Case caso : lstCasos) {
            caseToBilling.put(caso.Id, caso.vlocity_cmt__BillingAccountId__c);
            accountIdToCaseId.put(caso.vlocity_cmt__BillingAccountId__c, caso.Id);
        }
        
        for (WorkOrder wo : lstWO) {
            if (accountIdToCaseId.containsKey(wo.BillingAccount__c)) {
                wo.CaseId = accountIdToCaseId.get(wo.BillingAccount__c);
            }
        }
        
        insert lstWO;

        for (WorkOrder wo : lstWO) {
            idWO.add(wo.Id);
        }

        List<WorkOrder> lstWOInserted = [SELECT Id, WorkOrderNumber, BillingAccount__c, CaseId FROM WorkOrder WHERE Id IN :idWO];

        for (WorkOrder wo : lstWOInserted) {
            ResponseWrapper response = new ResponseWrapper();
            response.accountLegacyId = mapLegacyId.get(wo.BillingAccount__c);
            response.workOrderId = wo.Id;
            response.workOrderNumber = wo.WorkOrderNumber;
            retorno.add(response);
        }

        return retorno;

    }    

    global class AccountIdWrapper{
        global String legacyId {get; set;}
    }

    global class ResponseWrapper{
        global String accountLegacyId;
        global String workOrderId;
        global String workOrderNumber;
        global String error;
    }
}
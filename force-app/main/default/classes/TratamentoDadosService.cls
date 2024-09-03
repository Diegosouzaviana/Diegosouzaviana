/**
 * Nome da Classe: TratamentoDadosService
 * Descrição: Esta classe representa a execução lógica e relacionamento dos objetos importados ou não via carga de dados massiva. (Account, Contact, Contract, Contract Line Itens, Asset).
 * Autor: Victor Teodoro
 * Data de Criação: 06-Set-23
 * Última Modificação: 27-Set-23
 * Motivo da Modificação: [Explicação sucinta do motivo da modificação, se aplicável]
 * Version: v1.3
 * Notas: [Outras informações relevantes ou notas especiais sobre a classe]
 *
 * Direitos Autorais (c) 2023 - Victor Teodoro
 * Permissão concedida para uso interno da Desktop apenas.
 */
public with sharing class TratamentoDadosService {

    //OK
    public static void tratamentoContas(List<Account> lstFake){
        lstFake.clear();
        Set<String> setIdCPF = new Set<String>();
        List<Account> lstBillingService = [SELECT Id, LXD_CPF__c FROM Account WHERE ParentId = null AND (RecordType.Name = 'Billing' OR RecordType.Name = 'Service') LIMIT 100];
        if(!lstBillingService.isEmpty()){
            for (Account acc : lstBillingService) {
                setIdCPF.add(acc.LXD_CPF__c);
            }
            List<Account> lstAccountCustomer = [SELECT Id, LXD_CPF__c FROM Account WHERE RecordType.Name = 'Customer' AND LXD_CPF__c IN :setIdCPF LIMIT 100];
            
            Map<String, Id> cpfToCustomerIdMap = new Map<String, Id>();
            for (Account customer : lstAccountCustomer) {
                cpfToCustomerIdMap.put(customer.LXD_CPF__c, customer.Id);
            }
            List<Account> lst2Update = new List<Account>();
            for (Account BillingService : lstBillingService) {
                if (cpfToCustomerIdMap.containsKey(BillingService.LXD_CPF__c)) {
                    BillingService.ParentId = cpfToCustomerIdMap.get(BillingService.LXD_CPF__c);
                    BillingService.LXD_CPF__c = '';
                    lst2Update.add(BillingService);
                }
            }
            
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Contas relacionadas a Conta Customer: ' + lst2Update.size());
            } else {
                System.debug('Billing ou Service sem Customer Account associada. Verifique os dados!');
            }
        } else {
            System.debug('Todas as Contas possuem Customer Account associada!');
        }
        
        tratamentoContatos();
    }

    //OK
    public static void tratamentoContatos(){
        List<Contact> lstContact = [SELECT Id, LegacyId__c, Name, PrioridadeContato__c, AccountId, Account.LegacyId__c FROM Contact WHERE LegacyId__c != null AND AccountId = null LIMIT 100];
        List<Contact> contatosComLegacyIdDiferente = new List<Contact>();
        Set<String> setLegacyId = new Set<String>();
        if(lstContact.size() > 0){
            for(Contact contato : lstContact){
                setLegacyId.add(contato.LegacyId__c);
            }
    
            List<Contact> lst2Update = new List<Contact>();
            List<Account> lstBilling = [SELECT Id, LegacyId__c FROM Account WHERE LegacyId__c = :setLegacyId AND RecordType.Name = 'Billing'  LIMIT 100];
            for(Contact contato : lstContact){
                for(Account conta : lstBilling){
                    if(contato.LegacyId__c == conta.LegacyId__c){
                        contato.LXD_CPF__c = '';
                        contato.LegacyId__c = '';
                        contato.AccountId = conta.Id;
                        lst2Update.add(contato);
                    }
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Contatos vinculados a Conta: ' + lst2Update.size());
            } else {
                System.debug('Contato sem Conta vinculada. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Contatos possuem Contas vinculadas!');
        }
        tratamentoItensLinkOLT();
    }

    //Ok
    public static void tratamentoItensLinkOLT(){
        List<vlocity_cmt__ContractLineItem__c> lstItens = [SELECT Id, OLTLookup__c, NomeOLT__c FROM vlocity_cmt__ContractLineItem__c WHERE OLTLookup__c = null AND NomeOLT__c != null ORDER BY CreatedDate DESC LIMIT 1000];
        if(lstItens.size() > 0){
            Set<String> setOLT = new Set<String>();
            for(vlocity_cmt__ContractLineItem__c item : lstItens){
                setOLT.add(item.NomeOLT__c);
            }
            List<OLT__c> lstOLT = [SELECT Id, Name FROM OLT__c WHERE Name = :setOLT];
            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c item : lstItens){
                for(OLT__c olt : lstOLT){
                    if(item.NomeOLT__c == olt.Name){
                        item.OLTLookup__c = olt.Id;
                        lst2Update.add(item);
                    }
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Itens de Contrato vinculados a OLT: ' + lst2Update.size());
            } else {
                System.debug('Itens de Contrato sem OLT vinculada. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Contratos possuem Contas vinculadas!');
        }
        tratamentoAssetLinkOLT();
    }


    //OK
    public static void tratamentoAssetLinkOLT(){
        List<Asset> lstAtivos = [SELECT Id, OLTLookup__c, NomeOLT__c FROM Asset WHERE OLTLookup__c = null AND NomeOLT__c != null ORDER BY CreatedDate DESC LIMIT 1000];
        if(lstAtivos.size() > 0){
            Set<String> setOLT = new Set<String>();
            for(Asset ativo : lstAtivos){
                setOLT.add(ativo.NomeOLT__c);
            }
            List<OLT__c> lstOLT = [SELECT Id, Name FROM OLT__c WHERE Name = :setOLT];
            List<Asset> lst2Update = new List<Asset>();
            for(Asset ativo : lstAtivos){
                for(OLT__c olt : lstOLT){
                    if(ativo.NomeOLT__c == olt.Name){
                        ativo.OLTLookup__c = olt.Id;
                        lst2Update.add(ativo);
                    }
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Assets vinculados a OLT: ' + lst2Update.size());
            } else {
                System.debug('Asset sem OLT vinculada. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Contratos possuem Contas vinculadas!');
        }
        tratamentoContratos();
    }

    //OK
    public static void tratamentoContratos(){
        List<Contract> lstContract = [SELECT Id, Status, vlocity_cmt__ContractReferenceNumber__c, BillingAccountId__c FROM Contract WHERE vlocity_cmt__ContractReferenceNumber__c != null AND BillingAccountId__c = null AND Status != 'ATIVO' AND Status != 'Bloqueado' ORDER BY CreatedDate DESC LIMIT 1000];
        if(lstContract.size() > 0){
            Set<String> setLegacyId = new Set<String>();
            for(Contract cc : lstContract){
                if (cc.vlocity_cmt__ContractReferenceNumber__c != null){
                setLegacyId.add(cc.vlocity_cmt__ContractReferenceNumber__c);
                }
            }
            List<Account> lstAccount = [SELECT Id, LegacyId__c, ParentId FROM Account WHERE LegacyId__c IN: setLegacyId AND RecordType.Name = 'Billing'];
            Map<String, Account> legacyIdToAccountMap = new Map<String, Account>();
            
            for(Account acc : lstAccount){
                legacyIdToAccountMap.put(acc.LegacyId__c, acc);
            }
            
            List<Contract> lst2Update = new List<Contract>();
            for(Contract cc : lstContract){
                Account acc = legacyIdToAccountMap.get(cc.vlocity_cmt__ContractReferenceNumber__c);
                if(acc != null && acc.ParentId != null){
                    cc.AccountId = acc.ParentId;
                    cc.BillingAccountId__c = acc.Id;
                    lst2Update.add(cc);
                }
            }
            
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Contratos vinculados a Conta: ' + lst2Update.size());
            } else {
                System.debug('Nenhum Contrato vinculado a Conta foi encontrado!');
            }
        } else {
            System.debug('Todos os Contratos possuem Contas vinculadas!');
        }

        tratamentoItensLinkProduto();
    }

    //Ok
    public static void tratamentoItensLinkProduto(){
        List<vlocity_cmt__ContractLineItem__c> lstContractItens = [SELECT Id, ProdutoAuxiliar__c, vlocity_cmt__Product2Id__c, Name FROM vlocity_cmt__ContractLineItem__c WHERE ProdutoAuxiliar__C != null ORDER BY CreatedDate DESC LIMIT 100];
        if(lstContractItens.size() > 0){
            Set<String> setSKU = new Set<String>();
            for(vlocity_cmt__ContractLineItem__c item : lstContractItens){
                setSKU.add(item.ProdutoAuxiliar__c);
            }
            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            List<Product2> lstProduto = [SELECT Id, ProductCode, Name FROM Product2 WHERE ProductCode = :setSKU];
            for(vlocity_cmt__ContractLineItem__c item : lstContractItens){
                for(Product2 produto : lstProduto){
                    if(item.ProdutoAuxiliar__C == produto.ProductCode){
                        item.vlocity_cmt__Product2Id__c = produto.Id;
                        item.ProdutoAuxiliar__c = '';
                        lst2Update.add(item);
                    }
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Itens vinculados a Product2: ' + lst2Update.size());
            } else {
                System.debug('Itens de Contrato sem produto vinculado. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Items possuem Products2 vinculado!');
        }
        tratamentoItensLinkAssetComercial();
    }

    //Ok
    public static void tratamentoItensLinkAssetComercial(){
        List<vlocity_cmt__ContractLineItem__c> lstContractItens = [SELECT Id, vlocity_cmt__AssetId__c, IdPlanoUsuario__c FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__AssetId__c = null AND IdPlanoUsuario__c != null ORDER BY CreatedDate DESC LIMIT 1000];
        System.debug('Size: ' + lstContractItens.size());
        if (lstContractItens.size() > 0) {
            Set<Decimal> setIdPU = new Set<Decimal>();
            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                setIdPU.add(item.IdPlanoUsuario__c);
            }
        
            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            List<Asset> lstAtivos = [SELECT Id, IdPlanoUsuario__c, CodigoAtivo__c FROM Asset WHERE CodigoAtivo__c = null AND IdPlanoUsuario__c IN :setIdPU];
            Map<Decimal, vlocity_cmt__ContractLineItem__c> mapIdPlanoUsuarioToContractItem = new Map<Decimal, vlocity_cmt__ContractLineItem__c>();
        
            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                mapIdPlanoUsuarioToContractItem.put(item.IdPlanoUsuario__c, item);
            }
        
            for (Asset ativo : lstAtivos) {
                if (mapIdPlanoUsuarioToContractItem.containsKey(ativo.IdPlanoUsuario__c)) {
                    vlocity_cmt__ContractLineItem__c itemToUpdate = mapIdPlanoUsuarioToContractItem.get(ativo.IdPlanoUsuario__c);
                    if (itemToUpdate.vlocity_cmt__AssetId__c == null) {
                        itemToUpdate.vlocity_cmt__AssetId__c = ativo.Id;
                        lst2Update.add(itemToUpdate);
                    }
                }
            }
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Itens vinculados ao Asset Comercial atualizados: ' + lst2Update.size());
            } else {
                System.debug('Nenhum Item vinculado ao Asset Comercial foi atualizado.');
            }
        } else {
            System.debug('Todos os Itens possuem Asset Comercial vinculado!');
        }
        tratamentoItensLinkBilling();
    }

    //Ok
    public static void tratamentoItensLinkBilling(){
        List<vlocity_cmt__ContractLineItem__c> lstContractItens = [SELECT Id, LegacyId__c, vlocity_cmt__BillingAccountId__c  FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__BillingAccountId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if(lstContractItens.size() > 0){
            Set<String> setLegacyId = new Set<String>();
            for(vlocity_cmt__ContractLineItem__c item : lstContractItens){
                setLegacyId.add(item.LegacyId__c);
            }
            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            List<Account> lstBilling = [SELECT Id, LegacyId__c FROM Account WHERE LegacyId__c = :setLegacyId AND RecordType.Name = 'Billing'];
            for(vlocity_cmt__ContractLineItem__c item : lstContractItens){
                for(Account conta : lstBilling){
                    if(item.LegacyId__c == conta.LegacyId__c){
                        item.vlocity_cmt__BillingAccountId__c = conta.Id;
                        lst2Update.add(item);
                        break;
                    }
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Itens vinculados ao Billing Account: ' + lst2Update.size());
            } else {
                System.debug('Itens de Contrato não vinculado a Billing Account. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Items possuem Billing Account vinculado!');
        }
        tratamentoItensLinkService();
    }

    //Ok
    public static void tratamentoItensLinkService(){
        List<vlocity_cmt__ContractLineItem__c> lstContractItens = [SELECT Id, IdPlanoUsuario__c, vlocity_cmt__ServiceAccountId__c FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ServiceAccountId__c = null AND IdPlanoAdicional__c != null ORDER BY CreatedDate DESC LIMIT 1000];

        if (lstContractItens.size() > 0) {
            Set<String> setIdPU = new Set<String>();
            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                setIdPU.add(String.valueOf(item.IdPlanoUsuario__c));
            }

            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            List<Account> lstService = [SELECT Id, IdPlanoUsuario__c FROM Account WHERE IdPlanoUsuario__c IN :setIdPU AND RecordType.Name = 'Service'];
            Map<String, vlocity_cmt__ContractLineItem__c> mapIdPlanoUsuarioToContractItem = new Map<String, vlocity_cmt__ContractLineItem__c>();

            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                mapIdPlanoUsuarioToContractItem.put(String.valueOf(item.IdPlanoUsuario__c), item);
            }

            for (Account conta : lstService) {
                String idPU = String.valueOf(conta.IdPlanoUsuario__c);
                if (mapIdPlanoUsuarioToContractItem.containsKey(idPU)) {
                    vlocity_cmt__ContractLineItem__c itemToUpdate = mapIdPlanoUsuarioToContractItem.get(idPU);
                    if (itemToUpdate.vlocity_cmt__ServiceAccountId__c == null) {
                        itemToUpdate.vlocity_cmt__ServiceAccountId__c = conta.Id;
                        lst2Update.add(itemToUpdate);
                    }
                }
            }

            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Itens vinculados ao Service Account atualizados: ' + lst2Update.size());
            } else {
                System.debug('Nenhum Item vinculado ao Service Account foi atualizado.');
            }
        } else {
            System.debug('Todos os Items possuem Service Account vinculado!');
        }
        tratamentoAssetComercialLinkProduto();
    }

    //Ok
    public static void tratamentoAssetComercialLinkProduto(){
        List<Asset> lstAtivos = [SELECT Id, Name, Product2Id FROM Asset WHERE Product2Id = null ORDER BY CreatedDate DESC LIMIT 1000];

        if (lstAtivos.size() > 0) {
            Set<String> setNomeAtivo = new Set<String>();
            for (Asset ativo : lstAtivos) {
                setNomeAtivo.add(ativo.Name);
            }
        
            List<Asset> lst2Update = new List<Asset>();
            Set<String> processedNames = new Set<String>();
            List<Product2> lstProduto = [SELECT Id, Name FROM Product2 WHERE Name IN :setNomeAtivo];
        
            Map<String, Id> nameToProductId = new Map<String, Id>();
            for (Product2 produto : lstProduto) {
                nameToProductId.put(produto.Name, produto.Id);
            }
        
            for (Asset ativo : lstAtivos) {
                if (nameToProductId.containsKey(ativo.Name)) {
                    ativo.Product2Id = nameToProductId.get(ativo.Name);
                    lst2Update.add(ativo);
                    processedNames.add(ativo.Name);
                }
            }
        
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Ativos Comerciais vinculados a Produtos: ' + lst2Update.size());
            } else {
                System.debug('Ativos Comerciais não vinculados a Produtos. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Ativos Comerciais possuem Produto vinculado!');
        }
        tratamentoAssetsLinkContrato();
    }

    //OK
    public static void tratamentoAssetsLinkContrato(){
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__ContractId__c, LegacyId__c FROM Asset WHERE vlocity_cmt__ContractId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if (lstAtivos.size() > 0) {
            Set<String> setIdPU = new Set<String>();
            for (Asset ativo : lstAtivos) {
                setIdPU.add(String.valueOf(ativo.LegacyId__c));
            }

            List<Asset> lst2Update = new List<Asset>();
            List<Contract> lstContrato = [SELECT Id, vlocity_cmt__ContractReferenceNumber__c FROM Contract WHERE vlocity_cmt__ContractReferenceNumber__c IN :setIdPU];
            Map<String, Asset> mapAssetIdToAsset = new Map<String, Asset>();

                for (Asset ativo : lstAtivos) {
                    mapAssetIdToAsset.put(String.valueOf(ativo.LegacyId__c), ativo);
                }

                for (Contract contrato : lstContrato) {
                    String idPU = String.valueOf(contrato.vlocity_cmt__ContractReferenceNumber__c);

                    if (mapAssetIdToAsset.containsKey(idPU)) {
                        Asset ativoToUpdate = mapAssetIdToAsset.get(idPU);
                        if (ativoToUpdate.vlocity_cmt__ContractId__c == null) {
                            ativoToUpdate.vlocity_cmt__ContractId__c = contrato.Id;
                            lst2Update.add(ativoToUpdate);
                        }
                    }
                }

                if (!lst2Update.isEmpty()) {
                    update lst2Update;
                    System.debug('Quantidade de Assets vinculados ao Contrato atualizados: ' + lst2Update.size());
                } else {
                    System.debug('Nenhum Asset vinculado ao Contrato foi atualizado.');
                }
            } else {
                System.debug('Todos os Assets possuem Contrato vinculado!');
            }
        tratamentoAssetEquipamentoLinkComercial();
    }

    //Ok
    public static void tratamentoAssetEquipamentoLinkComercial(){
        List<Asset> lstEquipamentos = [SELECT Id, vlocity_cmt__ContractId__c, IdPlanoUsuario__c, IdPlanoAdicional__c, LegacyId__c FROM Asset WHERE CodigoAtivo__c != null AND ParentId = null AND Product2.RecordType.Name = 'Equipamento' ORDER BY CreatedDate DESC LIMIT 1000];
        
        if (lstEquipamentos.size() > 0) {
            Set<Decimal> setIdPU = new Set<Decimal>();
            Set<Decimal> setAdicional = new Set<Decimal>();
            for (Asset ativo : lstEquipamentos) {
                if(ativo.IdPlanoUsuario__c != 0){
                    setIdPU.add(ativo.IdPlanoUsuario__c);
                }
                if(ativo.IdPlanoAdicional__c != 0){
                    setAdicional.add(ativo.IdPlanoAdicional__c);
                }
            }
            List<Asset> lst2Update = new List<Asset>();
            List<Asset> lstComercial = [SELECT Id, IdPlanoUsuario__c, IdPlanoAdicional__c FROM Asset WHERE Product2.RecordType.Name = 'Product' AND (IdPlanoUsuario__c IN :setIdPU OR IdPlanoAdicional__c IN :setAdicional) LIMIT 49000];
            System.debug('Size: ' + lstComercial.size());          
        
            Map<Decimal, Asset> mapIdPlanoUsuarioToAsset = new Map<Decimal, Asset>();
        
            for (Asset comercial : lstComercial) {
                mapIdPlanoUsuarioToAsset.put(comercial.IdPlanoUsuario__c, comercial);
            }
        
            for (Asset equipamento : lstEquipamentos) {
                if (mapIdPlanoUsuarioToAsset.containsKey(equipamento.IdPlanoUsuario__c)) {
                    Asset comercial = mapIdPlanoUsuarioToAsset.get(equipamento.IdPlanoUsuario__c);
                    equipamento.ParentId = comercial.Id;
                    lst2Update.add(equipamento);
                }
            }
            if(!lst2Update.isEmpty()){
                update lst2Update;
                System.debug('Quantidade de Assets Fisicos vinculados ao Asset Comercial: ' + lst2Update.size());
            } else {
                System.debug('Assets Fisicos não vinculados ao Asset Comercial. Verifique os dados!');
            }
        } else {
            System.debug('Todos os Assets Fisicos possuem Asset Comerciais vinculados!');
        }
        tratamentoAssetsLinkBilling();
    }

    //Ok
    public static void tratamentoAssetsLinkBilling() {
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c, AccountId, LegacyId__c, IdPlanoUsuario__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c = NULL ORDER BY CreatedDate DESC LIMIT 1000];

        if (lstAtivos.size() > 0) {
        Set<String> setLegacyId = new Set<String>();
        for (Asset ativo : lstAtivos) {
            setLegacyId.add(ativo.LegacyId__c);
        }

        Map<String, Account> legacyIdToBillingAccountMap = new Map<String, Account>();
        Map<Id, String> assetIdToParentAccountIdMap = new Map<Id, String>();

        for (Account conta : [SELECT Id, LegacyId__c, IdPlanoUsuario__c, ParentId, RecordType.Name FROM Account WHERE LegacyId__c IN :setLegacyId AND RecordType.Name = 'Billing']) {
            legacyIdToBillingAccountMap.put(conta.LegacyId__c, conta);
        }

        List<Asset> lst2Update = new List<Asset>(); 
        for (Asset ativo : lstAtivos) {
            Account billingAccount = legacyIdToBillingAccountMap.get(ativo.LegacyId__c);
           
            if (billingAccount != null) {
                ativo.vlocity_cmt__BillingAccountId__c = billingAccount.Id;
                ativo.AccountId = billingAccount.ParentId;
            }
            lst2Update.add(ativo);
            assetIdToParentAccountIdMap.put(ativo.Id, ativo.AccountId);
        }

        if (!lst2Update.isEmpty()) {
            update lst2Update;
            System.debug('Quantidade de Assets vinculados a Contas: ' + lst2Update.size());
        } else {
            System.debug('Nenhum Asset vinculado a Contas foi atualizado.');
        }
        } else {
            System.debug('Todos os Assets Físicos possuem Assets Comerciais vinculados!');
        }
        tratamentoAssetsLinkService();
    }

    //Ok
    public static void tratamentoAssetsLinkService() {
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c, AccountId, LegacyId__c, IdPlanoUsuario__c FROM Asset WHERE vlocity_cmt__ServiceAccountId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
       
        if (lstAtivos.size() > 0) {
        Set<String> setIdPU = new Set<String>();

        for (Asset ativo : lstAtivos) {
            setIdPU.add(String.valueOf(ativo.IdPlanoUsuario__c));
        }

        Map<String, Account> idPlanoUsuarioToServiceAccountMap = new Map<String, Account>();
        Map<Id, String> assetIdToParentAccountIdMap = new Map<Id, String>();

        for (Account conta : [SELECT Id, IdPlanoUsuario__c, ParentId, RecordType.Name FROM Account WHERE IdPlanoUsuario__c IN :setIdPU AND RecordType.Name = 'Service']) {
            idPlanoUsuarioToServiceAccountMap.put(conta.IdPlanoUsuario__c, conta);
        }

        List<Asset> lst2Update = new List<Asset>();
        for (Asset ativo : lstAtivos) {
            Account serviceAccount = idPlanoUsuarioToServiceAccountMap.get(String.valueOf(ativo.IdPlanoUsuario__c));

            if (serviceAccount != null) {
                ativo.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
            }

            lst2Update.add(ativo);
            assetIdToParentAccountIdMap.put(ativo.Id, ativo.AccountId);
        }

        if (!lst2Update.isEmpty()) {
            update lst2Update;
            System.debug('Quantidade de Assets vinculados a Contas: ' + lst2Update.size());
        } else {
            System.debug('Nenhum Asset vinculado a Contas foi atualizado.');
        }
        } else {
            System.debug('Todos os Assets Físicos possuem Assets Comerciais vinculados!');
        }
        tratamentoItensLinkContrato();
    }



    //OK Só linka itens do contrato de produto
    public static void tratamentoItensLinkContrato(){
        List<vlocity_cmt__ContractLineItem__c> lstContractItens = [SELECT Id, LegacyId__c FROM vlocity_cmt__ContractLineItem__c WHERE LegacyId__c != null ORDER BY CreatedDate DESC LIMIT 1000];
        if (lstContractItens.size() > 0) {
            Set<String> setLegacyId = new Set<String>();
            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                setLegacyId.add(item.LegacyId__c);
            }
            List<vlocity_cmt__ContractLineItem__c> lst2Update = new List<vlocity_cmt__ContractLineItem__c>();
            List<Contract> lstContrato = [SELECT Id, vlocity_cmt__ContractReferenceNumber__c FROM Contract WHERE vlocity_cmt__ContractReferenceNumber__c = :setLegacyId];
            Map<String, Contract> legacyIdToContractMap = new Map<String, Contract>();
        
            for (Contract contrato : lstContrato) {
                legacyIdToContractMap.put(contrato.vlocity_cmt__ContractReferenceNumber__c, contrato);
            }
        
            for (vlocity_cmt__ContractLineItem__c item : lstContractItens) {
                Contract contrato = legacyIdToContractMap.get(item.LegacyId__c);
                if (contrato != null) {
                    // Crie um novo objeto para evitar duplicação de IDs
                    vlocity_cmt__ContractLineItem__c newItem = new vlocity_cmt__ContractLineItem__c(
                        Id = item.Id,
                        vlocity_cmt__ContractId__c = contrato.Id,
                        LegacyId__c = null
                    );
                    lst2Update.add(newItem);
                }
            }
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Itens de Contrato vinculados a Contrato: ' + lst2Update.size());
            } else {
                System.debug('Nenhum Itens de Contrato vinculado a Contrato foi encontrado para atualizar.');
            }
        } else {
            System.debug('Todos os tens de Contrato possuem Contas vinculadas!');
        }
        tratamentoAssetComercialLinkPricebookEntry();
    }

    //Ok
    public static void tratamentoAssetComercialLinkPricebookEntry(){
        List<Asset> lstAtivos = [SELECT Id, Name, Product2Id, vlocity_cmt__PricebookEntryId__c FROM Asset WHERE Product2.RecordType.Name = 'Product' AND vlocity_cmt__PricebookEntryId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if(!lstAtivos.isEmpty()){
            Set<String> assetNames = new Set<String>();
            Map<String, Id> assetNameToPricebookEntryId = new Map<String, Id>();
            
            for (Asset asset : lstAtivos) {
                assetNames.add(asset.Name);
            }
            
            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2.Name FROM PricebookEntry WHERE Product2.Name IN :assetNames];
            
            for (PricebookEntry entry : pricebookEntries) {
                assetNameToPricebookEntryId.put(entry.Product2.Name, entry.Id);
            }
            
            List<Asset> lst2Update = new List<Asset>();
            for (Asset asset : lstAtivos) {
                String assetName = asset.Name;
                if (assetNameToPricebookEntryId.containsKey(assetName)) {
                    asset.vlocity_cmt__PricebookEntryId__c = assetNameToPricebookEntryId.get(assetName);
                    lst2Update.add(asset);
                }
            }
            
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Assets Comerciais vinculados a PricebookEntry: ' + lst2Update.size());
            } else {
                System.debug('Foram encontrados Assets Comerciais para vincular ao PricebookEntry, porém não foram atualizados - Verifique os dados.');
            }
        } else {
            System.debug('Todos Assets Comerciais já foram vinculados ao PricebookEntry');
        }
        tratamentoAssetsLinkPriceList();
    }

    //Ok
    public static void tratamentoAssetsLinkPriceList() {
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__PriceListId__c FROM Asset WHERE vlocity_cmt__PriceListId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if(!lstAtivos.isEmpty()){
            Map<String, Id> assetNameToPriceListId = new Map<String, Id>();
            
            vlocity_cmt__PriceList__c priceLists = [SELECT Id FROM vlocity_cmt__PriceList__c WHERE Name = 'Preços Desktop'];
            List<Asset> lst2Update = new List<Asset>();

            for (Asset asset : lstAtivos) {
                asset.vlocity_cmt__PriceListId__c = priceLists.Id;
                lst2Update.add(asset);
            }
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Assets vinculados ao PriceList: ' + lst2Update.size());
            } else {
                System.debug('Foram encontrados Assets para vincular ao PriceList, porém não foram atualizados - Verifique os dados.');
            }
        } else {
            System.debug('Todos os Assets possuem PriceList vinculada.');
        }
        tratamentoAssetsPreencheRootItem();
    }

     //Ok
     public static void tratamentoAssetsPreencheRootItem() {
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__RootItemId__c, vlocity_cmt__AssetReferenceId__c FROM Asset WHERE vlocity_cmt__RootItemId__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if(!lstAtivos.isEmpty()){
            List<Asset> lst2Update = new List<Asset>();

            for (Asset asset : lstAtivos) {
                asset.vlocity_cmt__RootItemId__c = asset.vlocity_cmt__AssetReferenceId__c;
                lst2Update.add(asset);
            }
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Assets com RootItemId preenchido: ' + lst2Update.size());
            } else {
                System.debug('Foram encontrados Assets sem RootItemId, porém não foram atualizados - Verifique os dados.');
            }
        } else {
            System.debug('Todos os Assets possuem RootItemId preenchido.');
        }
        tratamentoAssetsPreencheLineNumber();
    }

    //Ok
    public static void tratamentoAssetsPreencheLineNumber(){
        List<Asset> lstAtivos = [SELECT Id, vlocity_cmt__LineNumber__c FROM Asset WHERE vlocity_cmt__LineNumber__c = null ORDER BY CreatedDate DESC LIMIT 1000];
        if(!lstAtivos.isEmpty()){
            List<Asset> lst2Update = new List<Asset>();

            for (Asset asset : lstAtivos) {
                asset.vlocity_cmt__LineNumber__c = '1';
                lst2Update.add(asset);
            }
            if (!lst2Update.isEmpty()) {
                update lst2Update;
                System.debug('Quantidade de Assets com LineNumber preenchido: ' + lst2Update.size());
            } else {
                System.debug('Foram encontrados Assets sem LineNumber, porém não foram atualizados - Verifique os dados.');
            }
        } else {
            System.debug('Todos os Assets possuem LineNumber preenchido.');
        }
    }
}
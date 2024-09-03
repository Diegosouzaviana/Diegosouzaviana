@RestResource(urlMapping = '/ConsultaDados/*') global with sharing
    class ConsultaDadosRestResource {
        
    @HttpGet
    global static ResponseWrapper doGet() {
            ResponseWrapper retorno = new ResponseWrapper();
            List<AccountsInfo> accountInfoList = new List<AccountsInfo>();
            List<AssetInfo> assetInfoList = new List<AssetInfo>();

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String tipoConsulta = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

            switch on tipoConsulta {
                when 'CustomerSemService' {

                    List<Account> customerAccounts = [SELECT Id, Name FROM Account WHERE  RecordType.Name = 'Customer'];

                    Set<Id> serviceParentIds = new Set<Id>();
                    for(Account serviceAccount : [SELECT ParentId FROM Account WHERE  RecordType.Name = 'Service' AND Parent.RecordType.Name = 'Customer']) {
                        serviceParentIds.add(serviceAccount.ParentId);
                    }

                    List<Account> result = new List<Account>();
                    for(Account customerAccount : customerAccounts) {
                        if(!serviceParentIds.contains(customerAccount.Id)) {
                            result.add(customerAccount);
                        }
                    }
                    for(Account acc : result){
                        AccountsInfo accountInfo = new AccountsInfo();
                        accountInfo.accountId = acc.Id;
                        accountInfo.accountName = acc.Name;
                        accountInfoList.add(accountInfo);
                    }
                    retorno.total = result.size();
                    retorno.accountInfo = accountInfoList;
                    return retorno;
                }

                when 'CustomerSemBilling' {
                    List<Account> customerAccounts = [SELECT Id, Name FROM Account WHERE  RecordType.Name = 'Customer'];

                    Set<Id> serviceParentIds = new Set<Id>();
                    for(Account serviceAccount : [SELECT ParentId FROM Account WHERE  RecordType.Name = 'Billing' AND Parent.RecordType.Name = 'Customer']) {
                        serviceParentIds.add(serviceAccount.ParentId);
                    }

                    List<Account> result = new List<Account>();
                    for(Account customerAccount : customerAccounts) {
                        if(!serviceParentIds.contains(customerAccount.Id)) {
                            result.add(customerAccount);
                        }
                    }

                    for(Account acc : result){
                        AccountsInfo accountInfo = new AccountsInfo();
                        accountInfo.accountId = acc.Id;
                        accountInfo.accountName = acc.Name;
                        accountInfoList.add(accountInfo);
                    }
                    retorno.total = result.size();
                    retorno.accountInfo = accountInfoList;
                    return retorno;
                }

                when 'AssetComercialSemAssetFisico' {

                    List<Asset> lstAsset = [SELECT Id, Name, (SELECT Id, Name FROM ChildAssets)
                    FROM Asset
                    WHERE ProductObjectType__c = 'Plano Desktop'];
                    System.debug('lstAccAux: ' + lstAsset.size());
                    Integer contagem = 0;
                    for(Asset ativo : lstAsset){
                        if(ativo.ChildAssets.isEmpty()){
                            AssetInfo assetInfo = new AssetInfo();
                            assetInfo.assetId = ativo.Id;
                            assetInfo.assetName = ativo.Name;
                            assetInfoList.add(assetInfo);
                            contagem++;
                        }
                    }
                    retorno.total = contagem;
                    retorno.assetInfo = assetInfoList;
                    return retorno;
                }

                when else {
                    retorno.error = 'Tipo de consulta inválida!';
                    return retorno;
                }
            }
    }

    global class ResponseWrapper{
        global List<AccountsInfo> accountInfo;
        global List<AssetInfo> assetInfo;
        global Integer total;
        global String error;
    }

    global class AccountsInfo{
        global String accountName;
        global String accountId;
        
    }

    global class AssetInfo{
        global String assetName;
        global String assetId;
        
    }

}
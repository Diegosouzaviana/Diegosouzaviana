public with sharing class ChangeAddressWrapper {
    
    public String correlation_id { get; set; }
    public Integer user_plan_id { get; set; }
    public String contracted_plan { get; set; }
    public String client_actual_plan { get; set; }
    public Integer promotion { get; set; }
    public Integer contract_id { get; set; }
    public String employee { get; set; }
    public String ativo_onu	{ get; set; }
    public String ativo_router { get; set; }
    public List<String> ativos_stb { get; set; }
    public List<Integer> aditional { get; set; }
    public String cto { get; set; }
    public String cto_port	{ get; set; }
    public String plan_category {get; set; }
    public Integer customer_id {get;set;} 
    public Integer fixed_discount { get; set; }
    public List<String> message_validation_list {get;set;}
    public String origem	{ get; set; }
    
    //Campos necessários para mudança de endereço
    public String new_installation_street {get;set;}
    public String new_installation_number {get;set;}
    public String new_installation_cep {get;set;}
    public String new_installation_district {get;set;}
    public String new_installation_city {get;set;}
    public String new_installation_uf {get;set;}
    public String new_billing_street {get;set;}
    public String new_billing_number {get;set;}
    public String new_billing_cep {get;set;}
    public String new_billing_district {get;set;}
    public String new_billing_city {get;set;}
    public String new_billing_uf {get;set;}
    public String new_installation_complement {get;set;}
    public String new_billing_complement {get;set;}


    public ChangeAddressWrapper() {

    }
}
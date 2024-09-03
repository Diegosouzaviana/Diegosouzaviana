public with sharing class NewCustomerWrapper {
    public String correlation_id {get;set;} 
	public Integer contract_id {get;set;} 
	public String service_order_id {get;set;} 
	public String contracted_plan {get;set;} 
	public String plan_category {get;set;} 
	public List<Integer> aditional_plans {get;set;} 
	public Integer promotion_id {get;set;} 
	public Integer customer_id {get;set;} 
	public Long protocol_number {get;set;} 
	public String customer_full_name {get;set;} 
	public String customer_main_document {get;set;} 
	public String customer_secondary_document {get;set;} 
	public String customer_email {get;set;} 
	public Long customer_phone {get;set;} 
	public String installation_street {get;set;} 
	public String installation_number {get;set;} 
	public String installation_complement {get;set;} 
	public Integer installation_cep {get;set;} 
	public String installation_district {get;set;} 
	public String installation_city {get;set;} 
	public String installation_uf {get;set;} 
	public String billing_street {get;set;} 
	public String billing_number {get;set;} 
	public String billing_complement {get;set;} 
	public Integer billing_cep {get;set;} 
	public String billing_district {get;set;} 
	public String billing_city {get;set;} 
	public String billing_uf {get;set;} 
	public String cto {get;set;} 
	public String cto_port {get;set;} 
	public String onu {get;set;} 
	public String router {get;set;} 
	public List<String> stb_list {get;set;} 
	public String technician_name {get;set;} 
	public String technician_company {get;set;} 
	public List<String> message_validation_list {get;set;}
    public String origem	{ get; set; }
    
    public NewCustomerWrapper() {

    }
}
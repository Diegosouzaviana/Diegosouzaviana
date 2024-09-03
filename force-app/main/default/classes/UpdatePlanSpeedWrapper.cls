/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             UpdatePlanSpeedWrapper
* @description      Wrapper class of UpdatePlanSpeed Integration
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-08-31   Guilherme                     Initial version. 
******
**/

public class UpdatePlanSpeedWrapper {
    public String correlation_id;
    public Integer user_plan_id;
    public String contracted_plan;
    public String customer_current_plan;
    public Double fixed_discount;
    public Integer promotion;
    public Integer customer_id;
    public List<String> message_validation_list {get;set;}
    public String origem	{ get; set; }
    public UpdatePlanSpeedWrapper() {
        
    }

   /*public UpdatePlanSpeedWrapper(String correlationId, Integer userPlanId, String contractedPlan,Double fixedDiscount, Integer promotion,String customerCurrentPlan,Integer customerId
    ) {
        system.debug('--------------------------');
        this.correlation_id = correlationId;
        this.user_plan_id = userPlanId;
        this.contracted_plan = contractedPlan;
        this.fixed_discount = fixedDiscount;
        this.promotion = promotion;
        this.customer_current_plan = customerCurrentPlan;
        this.customer_id = customerId;

    }*/
}
/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             UpdatePlanSpeedCalloutMock
* @description      Mock Callout of  UpdatePlanSpeed Integration
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

@isTest
global class UpdatePlanSpeedCalloutMock  implements HttpCalloutMock{
    Integer status;
    public UpdatePlanSpeedCalloutMock(Integer status){
        this.status = status;
    }
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        switch on this.status {
            when 200 {
                req.setBody('{"success":true,"message":"Velocidade do plano alterada com sucesso!"}');    
            } when else {
                req.setBody('{"success":false,"message":"Plano de usuário não encontrado"}');  
            } 
        }
        res.setStatusCode(this.status);
        return res;
    }
}
/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             ProvisioningCertificateResponseWrapper
* @description      Wrapper class of ProvisioningCertificate Integration Response
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-07   Guilherme                     Initial version. 
******
**/

public with sharing class ProvisioningCertificateResponseWrapper {
    public String message;
    
    public static ProvisioningCertificateResponseWrapper parse (String json) {
        return (ProvisioningCertificateResponseWrapper) System.JSON.deserialize(json,ProvisioningCertificateResponseWrapper.class);
    }
    
}
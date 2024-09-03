/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             ProvisioningCertificateWrapper
* @description      Wrapper class of ProvisioningCertificate Integration
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

public with sharing class ProvisioningCertificateWrapper {
    public Decimal reference_max_signal;
    public Decimal reference_signal_tolerance;
    public Integer cto_client_threshold;
    public Integer pu_id;
    public Boolean validate_cto_avg_signal;
    public String correlation_id;
    public String origem;

    public ProvisioningCertificateWrapper(
            Decimal reference_max_signal,
            Decimal reference_signal_tolerance,
            Integer cto_client_threshold,
            Integer pu_id,
            Boolean validate_cto_avg_signal,
            String origem
    ) {
        this.reference_max_signal = reference_max_signal;
        this.reference_signal_tolerance = reference_signal_tolerance;
        this.cto_client_threshold = cto_client_threshold;
        this.pu_id = pu_id;
        this.validate_cto_avg_signal = validate_cto_avg_signal;
        this.origem = origem;
    } 
}
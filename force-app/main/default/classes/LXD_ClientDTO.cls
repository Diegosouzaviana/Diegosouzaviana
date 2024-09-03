public with sharing class LXD_ClientDTO {
    public class ErrorDTO{
        @InvocableVariable(required=true) public String errorMessage;
        @InvocableVariable(required=true) public Boolean hasError;

        public ErrorDTO(String errorMessage){
            this.errorMessage = errorMessage;
            this.hasError = true;
        }
    }
    
    public class HasAppointmentsInput{
		@InvocableVariable(required=true) public String cpf;
        @InvocableVariable(required=true) public String procedureName;
    }

    public class HasAppointmentsOutput{
        @InvocableVariable(required=true) public Boolean hasAppointments;
        @InvocableVariable(required=true) public Integer statusCode;
        @InvocableVariable(required=true) public ErrorDTO errorDTO;

        public HasAppointmentsOutput(Boolean hasAppointments){
            this.hasAppointments = hasAppointments;
            this.statusCode = 200;
            this.errorDTO = null;
        }
        public HasAppointmentsOutput(Boolean hasAppointments, Integer statusCode, ErrorDTO errorDTO){
            this.hasAppointments = hasAppointments;
            this.statusCode = statusCode;
            this.errorDTO = errorDTO;
        }
    }
}
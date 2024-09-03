public with sharing class LXD_ConnectSFCoreToVlocity {
	@InvocableMethod(label='Verifica Cliente Agendamentos')
	public static List<LXD_ClientDTO.HasAppointmentsOutput> checkIfClientHasAppointments(List<LXD_ClientDTO.HasAppointmentsInput> inputList){
        List<LXD_ClientDTO.HasAppointmentsOutput> response = new List<LXD_ClientDTO.HasAppointmentsOutput>();

        if(!inputList.isEmpty()){
            LXD_ClientDTO.HasAppointmentsInput input = inputList[0];

            if(String.isBlank(input.procedureName)) {
                response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                    false, 400, new LXD_ClientDTO.ErrorDTO('procedureName é obrigatório')
                ));
    
                return response;
            } 
            else if(String.isBlank(input.cpf)){
                response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                    false, 400, new LXD_ClientDTO.ErrorDTO('CPF é obrigatório')
                ));
                return response;
            }

            try {
                Map<String, Object> ipOutput = Test.isRunningTest() ? 
                    LXD_ConnectSFCoreToVlocityTest.MOCK_OUTPUT
                :
                    (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(input.procedureName, new Map<String, Object>{'CPF' => input.cpf}, new Map<String, Object>());
                
                if(ipOutput.containsKey('response')){
                    Map<String, Object> ipResponse = (Map<String, Object>) ipOutput.get('response');
                    response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                        (Boolean) ipResponse.get('hasAppointment')
                    ));
                }
                else{
                    response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                        false, 500, new LXD_ClientDTO.ErrorDTO('Resposta mal configurada')
                    ));
                }
    
            } catch (Exception e) {
                LXD_VlocityUtils.debugErrorMessage(e);
    
                response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                    false, 500, new LXD_ClientDTO.ErrorDTO(e.getMessage())
                ));
            }

            return response;
        }
        else {
            response.add(new LXD_ClientDTO.HasAppointmentsOutput(
                false, 400, new LXD_ClientDTO.ErrorDTO('Nenhum input encontrado')
            ));
            return response;
        }
    }
}
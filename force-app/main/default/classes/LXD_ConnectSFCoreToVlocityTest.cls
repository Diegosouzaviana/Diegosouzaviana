@isTest
public with sharing class LXD_ConnectSFCoreToVlocityTest {
    public static Map<String, Object> MOCK_OUTPUT = new Map<String, Object>{};
    
    public static final List<LXD_ClientDTO.HasAppointmentsInput> VALID_INPUT_LIST = new List<LXD_ClientDTO.HasAppointmentsInput>{generateInput()};

    private static LXD_ClientDTO.HasAppointmentsInput generateInput(){
        LXD_ClientDTO.HasAppointmentsInput input = new LXD_ClientDTO.HasAppointmentsInput();
        input.cpf = '10690731051';
        input.procedureName = 'Any_procedure';

        return input;
    }

    @isTest
    public static void checkIfClientHasAppointmentsSuccess(){
        setMockResponse();

        List<LXD_ClientDTO.HasAppointmentsOutput> response = LXD_ConnectSFCoreToVlocity.checkIfClientHasAppointments(VALID_INPUT_LIST);

        Boolean isEmpty = response.isEmpty();
        System.assertEquals(false, isEmpty, 'response must not be empty');
        
        if(!isEmpty){
            LXD_ClientDTO.HasAppointmentsOutput output = response[0];
            System.assertEquals(true, output.hasAppointments, 'hasAppointments should be true');
            System.assertEquals(200, output.statusCode, 'statusCode should be 200');
            System.assertEquals(true, output.errorDTO == null, 'errorDTO should be null');
        }
    }

    @isTest
    public static void checkIfClientHasAppointmentsNoCPFFail(){
        setMockResponse();

        String errorMessage = 'CPF é obrigatório';
        VALID_INPUT_LIST[0].cpf = null;
        List<LXD_ClientDTO.HasAppointmentsOutput> response = LXD_ConnectSFCoreToVlocity.checkIfClientHasAppointments(VALID_INPUT_LIST);

        Boolean isEmpty = response.isEmpty();
        System.assertEquals(false, isEmpty, 'response must not be empty');
        
        if(!isEmpty){
            LXD_ClientDTO.HasAppointmentsOutput output = response[0];
            System.assertEquals(false, output.hasAppointments, 'hasAppointments should be false');
            System.assertEquals(400, output.statusCode, 'statusCode should be 400');
            System.assertEquals(true, output.errorDTO != null, 'errorDTO should not be null');
            System.assertEquals(true, output.errorDTO.errorMessage.contains(errorMessage), 'Wrong error message');
            System.assertEquals(true, output.errorDTO.hasError, 'true');
        }
    }

    @isTest
    public static void checkIfClientHasAppointmentsNoProcedureNameFail(){
        setMockResponse();

        String errorMessage = 'procedureName é obrigatório';
        VALID_INPUT_LIST[0].procedureName = null;
        List<LXD_ClientDTO.HasAppointmentsOutput> response = LXD_ConnectSFCoreToVlocity.checkIfClientHasAppointments(VALID_INPUT_LIST);

        Boolean isEmpty = response.isEmpty();
        System.assertEquals(false, isEmpty, 'response must not be empty');
        
        if(!isEmpty){
            LXD_ClientDTO.HasAppointmentsOutput output = response[0];
            System.assertEquals(false, output.hasAppointments, 'hasAppointments should be false');
            System.assertEquals(400, output.statusCode, 'statusCode should be 400');
            System.assertEquals(true, output.errorDTO != null, 'errorDTO should not be null');
            System.assertEquals(true, output.errorDTO.errorMessage.contains(errorMessage), 'Wrong error message');
            System.assertEquals(true, output.errorDTO.hasError, 'true');
        }
    }

    @isTest
    public static void checkIfClientHasAppointmentsNoInputFail(){
        setMockResponse();

        String errorMessage = 'Nenhum input encontrado';
        List<LXD_ClientDTO.HasAppointmentsOutput> response = LXD_ConnectSFCoreToVlocity.checkIfClientHasAppointments(new List<LXD_ClientDTO.HasAppointmentsInput>());

        Boolean isEmpty = response.isEmpty();
        System.assertEquals(false, isEmpty, 'response must not be empty');
        
        if(!isEmpty){
            LXD_ClientDTO.HasAppointmentsOutput output = response[0];
            System.assertEquals(false, output.hasAppointments, 'hasAppointments should be false');
            System.assertEquals(400, output.statusCode, 'statusCode should be 400');
            System.assertEquals(true, output.errorDTO != null, 'errorDTO should not be null');
            System.assertEquals(true, output.errorDTO.errorMessage.contains(errorMessage), 'Wrong error message');
            System.assertEquals(true, output.errorDTO.hasError, 'true');
        }
    }

    /* THIS TEST MUST BE THE LAST */
    @isTest
    public static void checkIfClientHasAppointmentsMisconfiguredIPFail(){
        removeMockResponse();

        String errorMessage = 'Resposta mal configurada';
        List<LXD_ClientDTO.HasAppointmentsOutput> response = LXD_ConnectSFCoreToVlocity.checkIfClientHasAppointments(VALID_INPUT_LIST);

        Boolean isEmpty = response.isEmpty();
        System.assertEquals(false, isEmpty, 'response must not be empty');
        
        if(!isEmpty){
            LXD_ClientDTO.HasAppointmentsOutput output = response[0];
            System.assertEquals(false, output.hasAppointments, 'hasAppointments should be false');
            System.assertEquals(500, output.statusCode, 'statusCode should be 500');
            System.assertEquals(true, output.errorDTO != null, 'errorDTO should not be null');
            System.assertEquals(true, output.errorDTO.errorMessage.contains(errorMessage), 'Wrong error message');
            System.assertEquals(true, output.errorDTO.hasError, 'true');
        }
    }

    private static void setMockResponse(){
        if(!MOCK_OUTPUT.containsKey('response')) MOCK_OUTPUT.put('response', new Map<String, Object>{
            'hasAppointment' => true
        });
    }

    private static void removeMockResponse(){
        if(MOCK_OUTPUT.containsKey('response')) MOCK_OUTPUT.remove('response');
    }
}
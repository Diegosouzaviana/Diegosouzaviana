@isTest
public with sharing class LXD_QuestionnaireControllerTest {
    private static final LXD_QuestionnaireController SUT = new LXD_QuestionnaireController();
    private static final String SAVE_QUESTIONNAIRE_METHOD_NAME = 'saveQuestionnaire';
    private static final Map<String, Object> INPUT_JSON = new Map<String, Object>{
        'Q_RadioWhatProblem' => 'Qual o problema?',
        'Q_RadioOneDevice' => 'O problema ocorre em apenas um dispositivo no local?',
        'Q_RadioLastVersion' => 'O aplicativo está atualizado para a última versão disponível?',
        'A_RadioWhatProblem' => 'Todos os canais que o cliente tenta acessar',
        'A_RadioOneDevice' => 'Sim',
        'A_RadioLastVersion' => 'Não',
        'RedeWifi' => new Map<String, Object>{
            'Q_RadioSignal' => 'O sinal do cliente está dentro do padrão?',
            'Q_RadioRepeater' => 'O cliente tem um Roteador / Repetidor adicional?',
            'Q_RadioCompatibleRepeater' => 'O Roteador / Repetidor é compatível com o Plano contratado?',
            'A_RadioSignal' => 'Sim',
            'A_RadioRepeater' => 'Não',
            'A_RadioCompatibleRepeater' => 'Sim',
            'Rede' => null
        }
    };

    @TestSetup
    static void makeData(){
        Account account = new Account(
	        Name = 'Wesley Prado'
        );
        insert account;

        Case newCase = new Case(
            LXD_QuestionnaireAnswered__c = false,
            AccountId = account.Id
        );
        insert newCase;
    }

    @isTest
    public static void saveQuestionnaireSuccess(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => INPUT_JSON,
            'title' => 'Questionário de Teste',
            'caseId' => [SELECT Id FROM Case WHERE Account.Name = 'Wesley Prado' LIMIT 1].Id
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        SUT.invokeMethod(SAVE_QUESTIONNAIRE_METHOD_NAME, inputs, output, new Map<String, Object>());
        Test.stopTest();

        Map<String, Object> result = (Map<String, Object>) output.get('result');
        System.assertEquals(true, result.containsKey('ContentNote'), 'ContentNote not found');
        System.assertEquals(true, result.containsKey('ContentDocumentLink'), 'ContentDocumentLink not found');
    }

    @isTest
    public static void saveQuestionnaireNoFieldValue(){
        Map<String, Object> inputs = new Map<String, Object>{
            'title' => 'Questionário de Teste',
            'caseId' => [SELECT Id FROM Case WHERE Account.Name = 'Wesley Prado' LIMIT 1].Id
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        SUT.invokeMethod(SAVE_QUESTIONNAIRE_METHOD_NAME, inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(400, (Decimal) output.get('statusCode'), 'Status code should be 400');
        System.assertEquals(true, ((String) output.get('error')).equals('Bad Request: field "value" is required'), 'Error message should be "Bad Request: field "value" is required"');
        System.assertEquals(null, output.get('result'), 'Result should be null');
    }

    @isTest
    public static void saveQuestionnaireWrongDataType(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => 'Wrong_Data_Type',
            'title' => 'Questionário de Teste',
            'caseId' => [SELECT Id FROM Case WHERE Account.Name = 'Wesley Prado' LIMIT 1].Id
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        SUT.invokeMethod(SAVE_QUESTIONNAIRE_METHOD_NAME, inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(400, (Decimal) output.get('statusCode'), 'Status code should be 400');
        System.assertEquals(true, ((String) output.get('error')).equals('Bad Request: value must be a Map<String, Object>'), 'Error message should be "Bad Request: value must be a Map<String, Object>"');
        System.assertEquals(null, output.get('result'), 'Result should be null');
    }

    @isTest
    public static void saveQuestionnaireNoCaseId(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => INPUT_JSON,
            'title' => 'Questionário de Teste',
            'caseId' => null
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        SUT.invokeMethod(SAVE_QUESTIONNAIRE_METHOD_NAME, inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(400, (Decimal) output.get('statusCode'), 'Status code should be 400');
        System.assertEquals(true, ((String) output.get('error')).startsWith('Bad Request:'), 'Error message should start with "Bad Request:"');
        System.assertEquals(null, output.get('result'), 'Result should be null');
    }
}
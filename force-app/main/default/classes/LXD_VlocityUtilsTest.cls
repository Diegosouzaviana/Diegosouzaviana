@isTest
public with sharing class LXD_VlocityUtilsTest {
    private static final String TEST_STRING = 'ANY_STRING';
    private static final LXD_VlocityUtils UTILS = new LXD_VlocityUtils();

    /* STRING TO BLOB */
    @isTest
    public static void stringToBlobSuccess(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => TEST_STRING
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringToBlob', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(Blob.valueOf(TEST_STRING), output.get('result'), 'Wrong blob value');
    }
    
    @isTest
    public static void stringToBlobNoValue(){
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringToBlob', new Map<String, Object>(), output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(null, output.get('result'), 'Result should be null');
        System.assertEquals('Bad Request: field "value" is required', output.get('error'), 'Wrong error message');
        System.assertEquals(400, output.get('statusCode'), 'Wrong status code');
    }

    @isTest
    public static void stringToBlobNotAString(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => 2
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringToBlob', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(null, output.get('result'), 'Result should be null');
        System.assertEquals('Bad Request: value must be a String', output.get('error'), 'Wrong error message');
        System.assertEquals(400, output.get('statusCode'), 'Wrong status code');
    }

    /* STRING LENGTH */
    @isTest
    public static void stringLengthSuccess(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => TEST_STRING
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringLength', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(10, output.get('result'), 'Wrong string length');
    }
    
    @isTest
    public static void stringLengthNoValue(){
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringLength', new Map<String, Object>(), output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(null, output.get('result'), 'Result should be null');
        System.assertEquals('Bad Request: field "value" is required', output.get('error'), 'Wrong error message');
        System.assertEquals(400, output.get('statusCode'), 'Wrong status code');
    }

    @isTest
    public static void stringLengthNotAString(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => 2
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('stringLength', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(null, output.get('result'), 'Result should be null');
        System.assertEquals('Bad Request: value must be a String', output.get('error'), 'Wrong error message');
        System.assertEquals(400, output.get('statusCode'), 'Wrong status code');
    }

    /* VALIDATE REGEX */
    @isTest
    public static void validateRegexSuccess(){
        String ONLY_NUMBER_REGEX = '^\\d{3,6}$';
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => '12345',
            'regex' => ONLY_NUMBER_REGEX
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('validateRegex', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(true, output.get('result'), 'Wrong regex result');
    }

    @isTest
    public static void validateRegexFail(){
        String ONLY_NUMBER_REGEX = '^\\d{3,6}$';
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => new Map<String, Object>(),
            'regex' => ONLY_NUMBER_REGEX
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('validateRegex', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(true, ((String) output.get('error')).startsWith('Bad Request: Invalid conversion'), 'Wrong error message');
    }
    
    @isTest
    public static void validateRegexNoValue(){
        String ONLY_NUMBER_REGEX = '^\\d{3,6}$';
        Map<String, Object> inputs = new Map<String, Object>{
            'regex' => ONLY_NUMBER_REGEX
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('validateRegex', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals('Bad Request: field "value" is required', output.get('error'), 'Wrong error message');
    }

    @isTest
    public static void validateRegexNoRegex(){
        Map<String, Object> inputs = new Map<String, Object>{
            'value' => TEST_STRING
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('validateRegex', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals('Bad Request: field "regex" is required', output.get('error'), 'Wrong error message');
    }

    /* CONVERT DATE */
    @isTest
    public static void compareDatesSuccess(){
        Map<String, Object> inputs = new Map<String, Object>{
            'firstDate' => '31/01/2023',
            'secondDate' => '01/01/2023'
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('compareDates', inputs, output, new Map<String, Object>());
        Test.stopTest();

        Assert.isNotNull(output.get('result'), 'should have a result');
        Assert.isTrue((Boolean) output.get('result'), 'firstDate should be greater than secondDate');
    }
    
    /* ADD DAYS */
    @isTest
    public static void addDaysToDateSuccess(){
        Map<String, Object> inputs = new Map<String, Object>{
            'date' => Date.valueOf('2023-01-25'),
            'days' => 6
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        UTILS.invokeMethod('addDaysToDate', inputs, output, new Map<String, Object>());
        Test.stopTest();

        System.debug('output: ' + output);
        
        Assert.isNotNull(output.get('result'), 'should have a result');
        Assert.areEqual('31/01/2023', (String) output.get('result'), 'Dates are not equal');
    }
    /* HELPERS */
    @isTest
    public static void internalServer(){
        String errorMessage = 'Any_Error_Message';
        Map<String, Object> output = new Map<String, Object>();
        
        Test.startTest();
        LXD_VlocityUtils.internalServer(output, errorMessage);
        Test.stopTest();

        System.assertEquals(true, ((String) output.get('error')).contains(errorMessage), 'Wrong error message');
        System.assertEquals(500, output.get('statusCode'), 'Wrong error message');
    }

    @isTest
    public static void notFound(){
        String errorMessage = 'Any_Error_Message';
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        LXD_VlocityUtils.notFound(output, errorMessage);
        Test.stopTest();

        System.assertEquals(true, ((String) output.get('error')).contains(errorMessage), 'Wrong error message');
        System.assertEquals(404, output.get('statusCode'), 'Wrong error message');
    }

    @isTest
    public static void badRequest(){
        String errorMessage = 'Any_Error_Message';
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        LXD_VlocityUtils.badRequest(output, errorMessage);
        Test.stopTest();

        System.assertEquals(true, ((String) output.get('error')).contains(errorMessage), 'Wrong error message');
        System.assertEquals(400, output.get('statusCode'), 'Wrong error message');
    }
}
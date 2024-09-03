@isTest
public class WorkOrderMotivoServiceTest {
	
    @isTest
    static void testGetPicklistValues() {
        // Test case 1: Single value
        List<String> singleValue = new List<String>{'Value1'};
        List<List<String>> result1 = WorkOrderMotivoService.getPicklistValues(singleValue);
        System.assertEquals(1, result1.size(), 'Expected 1 value');
        System.assertEquals('Value1', result1[0][0], 'Unexpected value');

        // Test case 2: Multiple values separated by semicolon
        List<String> multipleValues = new List<String>{'Value1;Value2;Value3'};
        List<List<String>> result2 = WorkOrderMotivoService.getPicklistValues(multipleValues);
        //System.assertEquals(3, result2.size(), 'Expected 3 values');
        System.assertEquals('Value1', result2[0][0], 'Unexpected value');
        System.assertEquals('Value2', result2[0][1], 'Unexpected value');
        System.assertEquals('Value3', result2[0][2], 'Unexpected value');

        // Test case 3: Single value without semicolon
        List<String> singleValueNoSemicolon = new List<String>{'SingleValue'};
        List<List<String>> result3 = WorkOrderMotivoService.getPicklistValues(singleValueNoSemicolon);
        System.assertEquals(1, result3.size(), 'Expected 1 value');
        System.assertEquals('SingleValue', result3[0][0], 'Unexpected value');
    }

 
}
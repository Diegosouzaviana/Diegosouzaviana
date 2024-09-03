@isTest
public class GetSerialNumberProductTransferTest{
    @isTest
    static void GetSerialNumberProductTransferTest(){
        List<string> tempLst = new list<string>();
        tempLst.add('AccidentalCoder');
        tempLst.add('Salesforce');
        GetSerialNumberProductTransfer.CheckValues(tempLst);
    }
}
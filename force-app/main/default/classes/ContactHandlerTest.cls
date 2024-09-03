@IsTest
public class ContactHandlerTest {
    @TestSetup
    static void setup(){
        insert new Contact(
        	FirstName='First Name',
            LastName='LastName',
            Email='invalidEmail@desktop.com.br',
            LXD_AlternativeEmail__c = 'dummy@dummy.com.br',
            LXD_CPF__c = '11111111111'
        );
    }

    @IsTest
    static void DeleteValidationTest() {
        try {
            Contact c = [SELECT Id FROM Contact WHERE LXD_CPF__c = '11111111111'];
            delete c;
        } catch (Exception e) {
            System.debug('Erro ao excluir Contato: '+e.getMessage()+ ' - '+e.getStackTraceString());
        }
    }

    @IsTest
    static void UpdateValidationTest() {
        try {
            Contact c = [SELECT LXD_AlternativeEmail__c, LXD_CPF__c, Id FROM Contact WHERE LXD_CPF__c = '11111111111'];
            c.LXD_AlternativeEmail__c = null;
            update c;        
        } catch (Exception e) {
            System.debug('Erro ao atualizar Contato: '+e.getMessage()+ ' - '+e.getStackTraceString());
        }
    }
}
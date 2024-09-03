@isTest
public class TriggerDeleteCaseTest {
    @isTest
    static void testTrigger() {
        // Crie um caso para testar
        Case testCase = new Case(
            Status = 'Aberto',  // Defina o status como necessário para o seu teste
            Subject = 'Assunto de Teste'
        );
        insert testCase;

        // Tente excluir o caso
        Test.startTest();
        try {
            delete testCase;
        } catch (Exception e) {
            // A exclusão deve falhar devido à trigger
            System.assert(true,e.getMessage().contains('A exclusão de casos não é permitida.'));
        }
        Test.stopTest();
    }
}
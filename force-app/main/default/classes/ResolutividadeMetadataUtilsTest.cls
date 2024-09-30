@isTest
public class ResolutividadeMetadataUtilsTest {

    @TestSetup
    static void setup() {
            Case caso = new Case(
                Area_de_atendimento__c ='SAC',
                motive__c ='Ativo NPS',
                solution__c ='Sem Retorno',
                submotive__c ='Faturamento',
                Tema__c ='Ativo',
                Tipo__c ='Informação'
            );
            insert caso;
         }
         @isTest static void testUpdateCaseMotivoSubmotivoByMetadata() {
            List<Case> cases = [SELECT Id, Tema__c, motive__c, Tipo__c, submotive__c FROM Case WHERE Tema__c = 'Ativo'];
            List<Case> newCases = ResolutividadeMetadataUtils.updateCaseMotivoSubmotivoByMetadataValues(cases);
            System.assert(newCases.size() == 1);
            System.assertEquals(newCases[0].motive__c, 'Motivo Resolutividade Teste');
            System.assertEquals(newCases[0].submotive__c, 'Submotivo Resolutividade Teste');
         }
    }
@isTest
public class EveryGraficoEvolutividadeControllerTest {

    @testSetup
    static void setup() {
        // Criar casos de teste
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        
        QueueSobject mappingObject = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;}

        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account a = new Account(
                Name = 'New Account Name ' + i,
                CNPJ__c = '494016670001' + i,
                LXD_CPF__c = '400948800' + i,
                LXD_Email__c='teste' + i + '@gmail.com'
            );
            accs.add(a);
        }

        insert accs;

        List<Contract> contracts = new List<Contract>();

        for(Account a : accs){
            contracts.add(new Contract(
                AccountId = a.Id
            ));
        }

        insert contracts;

        List<Case> cases = new List<Case>();

        Integer counter = 0;
        for(Contract c : contracts){
            counter++;
            cases.add(new Case(
                motive__c = 'Financeiro',
                submotive__c = 'Ativo NPS' + counter,
                Status = 'Finalizado',
                solution__c = 'Resolvido por operações',
                Contrato__c = c.Id,
                OwnerId = Math.mod(counter,2) == 0 ? UserInfo.getUserId() : testGroup.Id 
            ));

            if(Math.mod(counter, 2) == 0){
                //Date dt = Date.today().addMonths(-counter);
                cases.add(new Case(
                    motive__c = 'Financeiro',
                    submotive__c = 'Ativo NPS' + counter,
                    Status = 'Finalizado',
                    solution__c = 'Resolvido por operações',
                    Contrato__c = c.Id,
                    OwnerId = Math.mod(counter,2) == 0 ? UserInfo.getUserId() : testGroup.Id 
                ));
            }
        }

        insert cases;
    }

    @isTest
    static void testGetGroupedCasesFromLast12Months() {
        // Preparar métricas JSON
        List<EveryGraficoEvolutividadeController.Metricas> metricas = new List<EveryGraficoEvolutividadeController.Metricas>();
        //for (Integer i = 1; i <= 5; i++) {
            EveryGraficoEvolutividadeController.Metricas d1 = new EveryGraficoEvolutividadeController.Metricas();
            d1.name = 'D+1';
            d1.id = '1';
            d1.value = '1';
            metricas.add(d1);
        
        EveryGraficoEvolutividadeController.Metricas d7 = new EveryGraficoEvolutividadeController.Metricas();
            d7.name = 'D+7';
            d7.id = '7';
            d7.value = '7';
            metricas.add(d7);
        
        //}
        String metricasJson = JSON.serialize(metricas);

        // Executar o método a ser testado
        EveryGraficoEvolutividadeController.MetricasResolutividade result = EveryGraficoEvolutividadeController.getGroupedCasesFromLast12Months(metricasJson, true);

        // Verificar resultados
        /*System.assertNotEquals(null, result);
        System.assertEquals(12, result.meses.size());
        System.assertEquals(5, result.metricas.size());

        for (EveryGraficoEvolutividadeController.MetricaResolutividade metrica : result.metricas) {
            System.assertNotEquals(null, metrica.nome);
            System.assertEquals(12, metrica.metricasPorMes.size());
        }*/
    }

    @isTest
    static void testGetGroupedCasesFromLast12Months_AtendimentoMistoFalse() {
        // Preparar métricas JSON
        List<EveryGraficoEvolutividadeController.Metricas> metricas = new List<EveryGraficoEvolutividadeController.Metricas>();
        for (Integer i = 1; i <= 5; i++) {
            EveryGraficoEvolutividadeController.Metricas metrica = new EveryGraficoEvolutividadeController.Metricas();
            metrica.name = 'Metrica ' + i;
            metrica.id = String.valueOf(i);
            metrica.value = String.valueOf(i * 2); // 2, 4, 6, 8, 10
            metricas.add(metrica);
        }
        String metricasJson = JSON.serialize(metricas);

        // Executar o método a ser testado
        EveryGraficoEvolutividadeController.MetricasResolutividade result = EveryGraficoEvolutividadeController.getGroupedCasesFromLast12Months(metricasJson, false);

        // Verificar resultados
        System.assertNotEquals(null, result);
        System.assertEquals(12, result.meses.size());
        System.assertEquals(5, result.metricas.size());

        for (EveryGraficoEvolutividadeController.MetricaResolutividade metrica : result.metricas) {
            System.assertNotEquals(null, metrica.nome);
            System.assertEquals(12, metrica.metricasPorMes.size());
        }
    }
}
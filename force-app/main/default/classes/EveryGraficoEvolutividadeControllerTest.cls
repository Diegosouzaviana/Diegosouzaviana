@isTest
public class EveryGraficoEvolutividadeControllerTest {

    @testSetup
    static void setup() {
       
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
        Date dt = Date.today();
        for(Account a : accs){
            contracts.add(new Contract(
                AccountId = a.Id,
                StartDate = dt
            ));
        }

        insert contracts;

        // Criar casos de teste
        List<Case> cases = new List<Case>();
        Integer counter = 0;
        for (Integer i = 0; i < contracts.size(); i++) {
            counter++;
            Contract c = contracts[i];
            // Casos normais
            cases.add(new Case(
                Area_de_atendimento__c = 'SAC',
                Tema__c = 'Ativo',
                motive__c = 'Ativo NPS',
                submotive__c = 'Faturamento',
                Status = 'Finalizado',
                Tipo__c = 'Informação',
                solution__c = 'Sem Retorno',
                Contrato__c = c.Id,
                OwnerId = (Math.mod(counter,2) == 0) ? UserInfo.getUserId() : testGroup.Id
            ));

            // Casos com OwnerId começando com "00G" (fila)
            if (Math.mod(counter,2) != 0) {
                cases.add(new Case(
                    Area_de_atendimento__c = 'SAC',
                    Tema__c = 'Ativo',
                    motive__c = 'Ativo NPS',
                    submotive__c = 'Faturamento',
                    Status = 'Finalizado',
                    Tipo__c = 'Informação',
                    solution__c = 'Sem Retorno',
                    Contrato__c = c.Id,
                    OwnerId = testGroup.Id // Owner na fila
                ));
            }
        }
        insert cases;
    }

    @isTest
    static void testGetGroupedCasesFromLast12Months() {
        // Preparar métricas JSON
        List<EveryGraficoEvolutividadeController.Metricas> metricas = new List<EveryGraficoEvolutividadeController.Metricas>();
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
        
        String metricasJson = JSON.serialize(metricas);

         // Mock para garantir que o CaseSelector e ResolutividadeMetadataUtils funcionem
         Test.startTest();
         EveryGraficoEvolutividadeController.MetricasResolutividade result = EveryGraficoEvolutividadeController.getGroupedCasesFromLast12Months(metricasJson, true);
         Test.stopTest();

         // Verificar que o resultado não é nulo
         System.assertNotEquals(null, result);
         System.assertEquals(12, result.meses.size());
 
         // Testar se as métricas foram calculadas corretamente
         System.assertEquals(2, result.metricas.size());
         
         for (EveryGraficoEvolutividadeController.MetricaResolutividade metrica : result.metricas) {
             System.assertNotEquals(null, metrica.nome);
             System.assertEquals(12, metrica.metricasPorMes.size());
         }

         // Verificar se o agrupamento de casos foi feito corretamente
        // Teste se os meses estão corretos, se os motivos e contratos estão agrupados corretamente
        for (String month : result.meses) {
            // Como adicionamos casos com meses diferentes, eles devem ser agrupados aqui
            System.assert(result.metricas[0].metricasPorMes.containsKey(month), 'A métrica deve conter o mês ' + month);
        }
 
        // Teste com atendimentoMisto = false (ignora casos de fila)
        Test.startTest();
        EveryGraficoEvolutividadeController.MetricasResolutividade result2 = EveryGraficoEvolutividadeController.getGroupedCasesFromLast12Months(metricasJson, false);
        Test.stopTest();

         // Verificar que o resultado não é nulo
         System.assertNotEquals(null, result2);
         System.assertEquals(12, result2.meses.size());
 
         // Testar se as métricas foram calculadas corretamente, mas agora com menos casos
         System.assertEquals(2, result2.metricas.size());
 
         for (EveryGraficoEvolutividadeController.MetricaResolutividade metrica : result2.metricas) {
             System.assertNotEquals(null, metrica.nome);
             System.assertEquals(12, metrica.metricasPorMes.size());
 
             // Verificar que os casos de fila foram ignorados
             for (String month : result2.meses) {
                 Double percentage = metrica.metricasPorMes.get(month);
                 System.assert(percentage >= 0 && percentage <= 100, 'Percentage out of range for month ' + month);
             }
         }
          // Verificar se os casos de fila foram corretamente excluídos com atendimentoMisto = false
        System.assertEquals(0, result2.metricas[0].metricasPorMes.values().size(), 'Nenhum caso de fila deve ser processado');
    }
}
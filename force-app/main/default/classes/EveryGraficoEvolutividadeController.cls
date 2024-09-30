global with sharing class EveryGraficoEvolutividadeController {

    @AuraEnabled
    global static MetricasResolutividade getGroupedCasesFromLast12Months(String metricasJson, Boolean atendimentoMisto) {

        System.debug('atendimento misto -> ' + atendimentoMisto);
        // Deserialize the metrics JSON
        List<Metricas> metricas = (List<Metricas>) JSON.deserialize(metricasJson, List<EveryGraficoEvolutividadeController.Metricas>.class);
        Date oneYearAgo = Date.today().addMonths(-12);

        List<Case> recentCases = ResolutividadeMetadataUtils.updateCaseMotivoSubmotivoByMetadataValues(CaseSelector.getCasesLastYear());

        // Group cases by month, motive, and contract
        Map<String, Map<String, Map<String, List<Case>>>> groupedCases = new Map<String, Map<String, Map<String, List<Case>>>>();
        Map<String, Integer> totalCasesPerMonth = new Map<String, Integer>();

        Integer casesProc = 0;
        for (Case c : recentCases) {
            String month = c.CreatedDate.format('MM-yyyy');
            String motive = c.motive__c != null ? c.motive__c : 'Unknown Motive';
            String contract = c.Contrato__c != null ? c.Contrato__c : 'Unknown Contract';

            // String ownerId = String.valueOf(c.OwnerId);
            if(!atendimentoMisto && String.valueOf(c.OwnerId).startsWith('00G')){
                System.debug('atendimento misto = false e owner id -> ' + c.OwnerId);
                continue;
            }

            casesProc++;

            if (!groupedCases.containsKey(month)) {
                groupedCases.put(month, new Map<String, Map<String, List<Case>>>());
                totalCasesPerMonth.put(month, 0);
            }
            if (!groupedCases.get(month).containsKey(motive)) {
                groupedCases.get(month).put(motive, new Map<String, List<Case>>());
            }
            if (!groupedCases.get(month).get(motive).containsKey(contract)) {
                groupedCases.get(month).get(motive).put(contract, new List<Case>());
                totalCasesPerMonth.put(month, totalCasesPerMonth.get(month) + 1);
            }
            groupedCases.get(month).get(motive).get(contract).add(c);
            // totalCasesPerMonth.put(month, totalCasesPerMonth.get(month) + 1);
        }
        
        System.debug('Total cases -> ' + casesProc);

        // Calculate metrics for each month
        MetricasResolutividade metricasResolutividade = new MetricasResolutividade();
        metricasResolutividade.meses = getLast12Months();
        Map<String, MetricaResolutividade> mapMetricas = new Map<String, MetricaResolutividade>();

        for (Metricas metrica : metricas) {
            MetricaResolutividade metricaResolutividade = new MetricaResolutividade();
            metricaResolutividade.nome = 'D' + metrica.value;
            mapMetricas.put(metrica.value, metricaResolutividade);
        }

        Set<Id> processedCases = new Set<Id>();

        for (String month : groupedCases.keySet()) {
            for (String motive : groupedCases.get(month).keySet()) {
                for (String contract : groupedCases.get(month).get(motive).keySet()) {

                    List<Case> cases = groupedCases.get(month).get(motive).get(contract);
                    if (cases.size() == 1 && !processedCases.contains(cases[0].Id)) {
                        String closestMetrica = '1';
                        processedCases.add(cases[0].Id);

                        if (mapMetricas.containsKey(closestMetrica)) {
                            MetricaResolutividade metricaResolutividade = mapMetricas.get(closestMetrica);
                            Integer currentCount = metricaResolutividade.metricasPorMes.containsKey(month) 
                                ? Integer.valueOf(metricaResolutividade.metricasPorMes.get(month)) 
                                : 0;
                            metricaResolutividade.metricasPorMes.put(month, currentCount + 1);
                        }
                    } else if (cases.size() > 1) {

                        cases.sort(new CaseCreatedDateComparator());

                        Date firstDate = cases[0].CreatedDate.date();
                        Date lastDate = cases[cases.size() - 1].CreatedDate.date();
                        Integer diffInDays = firstDate.daysBetween(lastDate);
                        if (diffInDays == 0) diffInDays = 1;


                        String closestMetrica = String.valueOf(findClosestMetrica(metricas, diffInDays));

                        if (mapMetricas.containsKey(closestMetrica)) {
                            MetricaResolutividade metricaResolutividade = mapMetricas.get(closestMetrica);
                            Integer currentCount = metricaResolutividade.metricasPorMes.containsKey(month) 
                                ? Integer.valueOf(metricaResolutividade.metricasPorMes.get(month)) 
                                : 0;
                            metricaResolutividade.metricasPorMes.put(month, currentCount + 1);

                            for (Case c : cases) {
                                processedCases.add(c.Id);
                            }

                        }
                    }
                }
            }
        }

        for (MetricaResolutividade metricaResolutividade : mapMetricas.values()) {
            for (String month : metricasResolutividade.meses) {
                Integer totalCases = totalCasesPerMonth.containsKey(month) ? totalCasesPerMonth.get(month) : 0;
                Decimal metricaCount = metricaResolutividade.metricasPorMes.containsKey(month) ? metricaResolutividade.metricasPorMes.get(month) : 0;
                Decimal percentage = totalCases > 0 ? ((Decimal) metricaCount / totalCases) * 100 : 0;
                metricaResolutividade.metricasPorMes.put(month, percentage != null ? percentage.setScale(1) : 0.0);
            }
        }

        metricasResolutividade.metricas.addAll(mapMetricas.values());
        System.debug('Metricas Resolutividade: ' + metricasResolutividade);
        return metricasResolutividade;
    }

    @AuraEnabled
    global static List<Case> getCases(Date startDate, Date endDate) {
        try{
            return ResolutividadeMetadataUtils.updateCaseMotivoSubmotivoByMetadataValues(CaseSelector.getCasesBetweenTwoDates(startDate, endDate));
        } catch(Exception e){
            return new List<Case>();
        }
    }

    private static Integer findClosestMetrica(List<Metricas> metricas, Integer diffInDays) {
        Integer closestMetrica = null;

        if(metricas.size() == 0){
            return 1;
        }
        
        for (Metricas metrica : metricas) {
            Integer mValue = Integer.valueOf(metrica.value);
            if(diffInDays == 0 || diffInDays == 1){
                return 1;
            } else if (mValue >= diffInDays) {
                if (closestMetrica == null || mValue < closestMetrica) {
                    closestMetrica = mValue;
                }
            }
        }
        return closestMetrica != null ? closestMetrica : Integer.valueOf(metricas[metricas.size() - 1].value);
    }

    public static List<String> getLast12Months() {
        List<String> last12Months = new List<String>();
        Date currentDate = Date.today(); // Data atual
        
        for (Integer i = 11; i >= 0; i--) {
            Date monthDate = currentDate.addMonths(-i); // Subtrai i meses da data atual
            Integer month = monthDate.month();
            Integer year = monthDate.year();
            
            // Formata a data como "MM/yyyy"
            String formattedMonth = (month < 10 ? '0' + month : ''+month) + '-' + year;
            
            last12Months.add(formattedMonth); // Adiciona à lista
        }
        
        return last12Months;
    }

    global class MetricasResolutividade {

        @AuraEnabled
        global List<String> meses;
        @AuraEnabled
        global List<EveryGraficoEvolutividadeController.MetricaResolutividade> metricas;

        global MetricasResolutividade() {
            this.meses = new List<String>();
            this.metricas = new List<EveryGraficoEvolutividadeController.MetricaResolutividade>();
        }

    }

    global class MetricaResolutividade {

        @AuraEnabled
        global String nome;
        @AuraEnabled
        global Map<String, Double> metricasPorMes;  // Altere para Double

        global MetricaResolutividade() {
            this.metricasPorMes = new Map<String, Double>();
        }

    }

    global class Metricas {
        global String name;
        global String id;
        global String value;
    }

    public class CaseCreatedDateComparator implements Comparator<Case> {
        public Integer compare(Case a, Case b) {
            if (a.CreatedDate == b.CreatedDate) return 0;
            return a.CreatedDate > b.CreatedDate ? 1 : -1;
        }
    }
}
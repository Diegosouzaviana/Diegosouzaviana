global with sharing class UtilService implements vlocity_cmt.VlocityOpenInterface2{
    // public UtilService() {}
    global String invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String result = '';
        try {
            if ('GenerateRandomString'.equalsIgnoreCase(methodName)) {
                result = generateRandomString();
                outMap.put('CorrelationId', result);
            } else {
                result = '';
            }
        } catch (Exception e) {
            result = '';
        }
        return result;
    }
        public static String generateRandomString() {
            Boolean finded = false;
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randStr = '';
            do {
                finded = false;
                while (randStr.length() < 10) {
                   Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                   randStr += chars.substring(idx, idx+1);
                }
                system.debug('value-> '+randStr);
        
                List<ServiceAppointment> saList = [SELECT id, CorrelationId__c FROM ServiceAppointment WHERE CorrelationId__c = :randStr];
                if (saList.size()>0) {
                    finded=true;
                }
                
            } while (finded);
            return randStr;
        }

    
}
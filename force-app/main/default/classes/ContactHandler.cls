public class ContactHandler {
    public static void DeleteValidation(List<Contact> contactListOld) {
        for (Contact c : contactListOld) {
            if (c.LXD_AlternativeEmail__c == 'dummy@dummy.com.br' && c.LXD_CPF__c == '11111111111') {
                c.addError('Favor não apagar este registro de contato pois é utilizado em uma classe');
            }
        }
    }

    public static void UpdateValidation(List<Contact> contactListOld, List<Contact> contactListNew) {
        String alternativeEmailOld, alternativeEmailNew, cpfOld, cpfNew;
        for (Contact c : contactListOld) {
            alternativeEmailOld = c.LXD_AlternativeEmail__c;
            cpfOld = c.LXD_CPF__c;
        }

        for (Contact c : contactListNew) {
            alternativeEmailNew = c.LXD_AlternativeEmail__c;
            cpfNew = c.LXD_CPF__c;
        }

        if ((alternativeEmailOld != alternativeEmailNew) || (cpfOld != cpfNew)) {
            for (Contact c : contactListNew) {
                c.addError('Campos CPF e Email Alternativo não podem ser alterados');
            }
        }
    }
}
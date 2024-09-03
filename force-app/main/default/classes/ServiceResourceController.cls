public with sharing class ServiceResourceController {
    public static Integer FirstCall=0;
    static String MessageInfoVF;
    public Boolean renderList {get; set;}
    public ServiceResourceController() {
        renderList = true;
    }
    public static void checkCPF(List<ServiceResource> sRes, Boolean IsActiving) {
        try {
            String srId, CPF, CPFNumbers, FormatedCPF, Name, RegistrationNumber, ownerId, messageBody = '';
            for (ServiceResource sr : sRes) {
                CPF = sr.CPF__c;
                Name = sr.Name;
                RegistrationNumber = sr.RegistrationNumber__c;
                srId = sr.Id;
                ownerId = sr.OwnerId;
            }
            if (isCPF(CPF)) {
                String UserProfileName = [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
                System.debug('UserProfileName '+UserProfileName);
                List<ServiceResource> sResourceList = [SELECT Id, Name, RegistrationNumber__c FROM ServiceResource WHERE CPF__c = :CPF AND Id != :srId];
                if (sResourceList.size() > 0) {
                    if(UserProfileName != 'Planejamento') {
                        messageBody = '';
                        for (ServiceResource sr : sResourceList) {
                            String rnMessage = sr.RegistrationNumber__c == null ? '' : ', código '+ sr.RegistrationNumber__c;
                            messageBody = 'CPF já está cadastrado para o técnico '+sr.Name+rnMessage;
                        }
                        if (!IsActiving) {
                            for (ServiceResource sr : sRes) {
                                sr.CPF__c.addError(messageBody);
                            }
                        } else {
                            messageBody = 'Não é possíel ativar este recurso pois '+messageBody;
                            for (ServiceResource sr : sRes) {
                                sr.IsActive.addError(messageBody);
                            }
                        }
                    } else {
                        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'BulkNotifications' AND CustomNotifTypeName = 'BulkNotifications' LIMIT 1].Id;
                        Messaging.CustomNotification obj = new Messaging.CustomNotification();
                        obj.setNotificationTypeId(typeId);
                        obj.setTargetId(UserInfo.getUserId());
                        obj.setTitle('Validação CPF');
                        if (sResourceList.size() == 1) {
                            for (ServiceResource sr : sResourceList) {
                                String rnMessage = sr.RegistrationNumber__c == null ? '' : ', código '+ sr.RegistrationNumber__c;
                                messageBody = 'O CPF '+CPF+' já está cadastrado para o técnico '+sr.Name+rnMessage+'. Por favor, validar duplicidade.';
                            }
                        } else {
                            messageBody = 'O CPF '+CPF+' já está cadastrado para:\n';
                            for (ServiceResource sr : sResourceList) {
                                String rnMessage = sr.RegistrationNumber__c == null ? '' : ', código '+ sr.RegistrationNumber__c;
                                messageBody += 'Técnico '+sr.Name + ', código '+sr.RegistrationNumber__c+rnMessage+'\n';
                            }
                            messageBody += 'Por favor validar duplicidades.';
                        }
                        obj.setBody(messageBody);
                        obj.send(new Set<String> {UserInfo.getUserId()});
                    }
                }
            } else {
                for (ServiceResource sr : sRes) {
                    sr.CPF__c.addError('CPF Inválido.');
                }
            }
        } catch (Exception e) {
            System.debug('Erro ao verificar/inserir CPF Service Resource: '+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    public static void checkUpdatingCPF(List<ServiceResource> sResOld, List<ServiceResource> sResNew) {
        try {
            String CPF_Old, CPF_New;
            Boolean IsActiveOld = false, IsActiveNew = false;
            for (ServiceResource sr : sResOld) {
                CPF_Old = sr.CPF__c;
                IsActiveOld = sr.IsActive;
            }

            for (ServiceResource sr : sResNew) {
                CPF_New = sr.CPF__c;
                IsActiveNew = sr.IsActive;
            }

            if (CPF_Old != CPF_New) {
                checkCPF(sResNew, false);
            }
            if (IsActiveOld==false && IsActiveNew==true) {
                checkCPF(sResNew, true);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao verificar CPF Service Resource: '+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    public static void insertEmail(List<ServiceResource> sRes, String email) {
        try {
            String ownerId, serviceResourceId;
            System.debug('insertEmail...');
            for (ServiceResource sr : sRes) {
                serviceResourceId = sr.Id;
            }
            //vericar campo do usuario RelatedRecord.Id e ativo = true do recurso
            ServiceResource sResource = [SELECT Id, Email__c, RelatedRecord.Email FROM ServiceResource WHERE  Id = :serviceResourceId];
            List<ServiceResource> sRList = [SELECT Id FROM ServiceResource WHERE Email__c = :sResource.RelatedRecord.Email And Id != :serviceResourceId];
            
            if (sRList.size() > 0) {
                System.debug('entrou if size>0');
                for (ServiceResource  sr : sRes) {
                    sr.Email__c.addError('O email do usuário já está cadastrado: '+email);
                }
            } else {
                System.debug('atualizando email...');
                sResource.Email__c = sResource.RelatedRecord.Email;
                update sResource;
            }
        } catch (Exception e) {
            System.debug('Erro ao inserir email do usuário: '+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    public static void checkUpdateServiceResource(List<ServiceResource> sResOld, List<ServiceResource> sResNew) {
        try {
            Boolean insertEmail = false, isActiveOld, isActiveNew;
            String RelatedRecIdOld, RelatedRecIdNew;
            System.debug('checkUpdateServiceResource');
            System.debug(sResNew[0].RelatedRecordId);
            for (ServiceResource sr : sResOld) {
                System.debug('relatedRecord old '+sr.RelatedRecordId);
                RelatedRecIdOld = sr.RelatedRecordId;
                isActiveOld     = sr.IsActive;
            }

            for (ServiceResource sr : sResNew) {
                System.debug('relatedRecord new '+sr.RelatedRecordId);
                RelatedRecIdNew = sr.RelatedRecordId;
                isActiveNew     = sr.IsActive;
            }

            String emailUser = [SELECT id, Email FROM User WHERE id = :RelatedRecIdNew].Email;
            System.debug('RelatedRecIdOld '+RelatedRecIdOld);
            System.debug('RelatedRecIdNew '+RelatedRecIdNew);
            System.debug('isActiveOld '+isActiveOld);
            System.debug('isActiveNew '+isActiveNew);
            System.debug('emailUser '+emailUser);

            if (RelatedRecIdOld != RelatedRecIdNew || (isActiveOld == false && isActiveNew == true))
                insertEmail(sResNew, emailUser);
            
        } catch (Exception e) {
            System.debug('Erro ao verificar usuário e \'ativo\' em Service Resource '+e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }

    public static void checkUpdateServiceResource(List<ServiceResource> sResNew) {
        try {
            String RelatedRecIdNew;
            for (ServiceResource sr : sResNew) {
                RelatedRecIdNew = sr.RelatedRecordId;
            }
            String emailUser = [SELECT id, Email FROM User WHERE id = :RelatedRecIdNew].Email;
            insertEmail(sResNew, emailUser);
        } catch (Exception e) {
            System.debug('Erro ao verificar usuário e \'ativo\' em Service Resource '+e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }

    public static boolean isCPF(String CPF) {
        if (CPF == NULL)
            return false;
        CPF = CPF.replace('.', '');
        CPF = CPF.replace('.', '');
        CPF = CPF.replace('.', '');
        CPF = CPF.replace('-', '');

        if (CPF.equals('00000000000') || CPF.equals('11111111111') ||
            CPF.equals('22222222222') || CPF.equals('33333333333') ||
            CPF.equals('44444444444') || CPF.equals('55555555555') ||
            CPF.equals('66666666666') || CPF.equals('77777777777') ||
            CPF.equals('88888888888') || CPF.equals('99999999999') ||
            (CPF.length() != 11))
        return(false);

        Integer dig10, dig11, sm, i, r, num, peso;
        sm = 0;
        peso = 10;
        List<String> cpfString = cpf.split('');
        for (i=0; i<9; i++) {
            num = Integer.valueOf(cpfString[i]); 
            sm = sm + (num * peso);
            peso = peso - 1;
        }

        r = 11 - (math.mod(sm,11));
        if ((r == 10) || (r == 11))
            dig10 = 0;
        else dig10 = r;

        // Calculo do 2o. Digito Verificador
        sm = 0;
        peso = 11;
        for(i=0; i<10; i++) {
            num = Integer.valueOf(cpfString[i]);
            sm = sm + (num * peso);
            peso = peso - 1;
        }

        r = 11 - (math.mod(sm,11));
        if ((r == 10) || (r == 11))
            dig11 = 0;
        else dig11 = r;

        // Verifica se os digitos calculados conferem com os digitos informados.
        if (dig10 == Integer.valueOf(cpfString[9]) && dig11 == Integer.ValueOf(cpfString[10]))
            return true;
        else return false;
    }
}
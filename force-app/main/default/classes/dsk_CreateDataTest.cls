/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Victor Pacheco
--- Description: Crea datos de Contact, Account, PricebookEntry, Product, Opportunity, OpportunityLineItem, Quote, 
				 QuoteLineItem, QuoteLineItem, Contract, Order, OrderGroup, OrderMember, OrderItem
--- CreateDate:  17/11/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/
@isTest
public without sharing class dsk_CreateDataTest {
	@TestSetup
    public static void generateMakeData(){
        try{
            Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE name = 'System Administrator'
                        LIMIT 1];
            
            User u = new User();
            u.Username = 'testSalesforce2021_@yopmail.com';
            u.put('Email','testSalesforce2021_@yopmail.com');
            u.FirstName = 'test user';
            u.LastName = 'lastname';
            u.ProfileId = p.Id;
            u.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
            u.LocaleSidKey = 'es';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'es';
            u.isActive = true;
            // u.UserRoleId = rol.Id;
            u.Alias = 'test123';
            Insert u;
            
            System.runAs(u){
                Account newAccountConsumer = new Account();
                newAccountConsumer.Name = 'accTest';
                newAccountConsumer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId(); //cuenta service
                newAccountConsumer.vlocity_cmt__Status__c = 'Active';
                insert newAccountConsumer;
                
                Account newAccountBilling = new Account();
                newAccountBilling.Name = 'accTest';
                newAccountBilling.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); //cuenta billing
                newAccountBilling.vlocity_cmt__Status__c = 'Active';
                insert newAccountBilling;
                
                Contact newContact = new Contact();
                newContact.Email = 'labsxdTest@labsxd.com';
                newContact.FirstName = 'FirstName';
                newContact.LastName = 'LastName';
                newContact.AccountId = newAccountConsumer.Id;
                insert newContact;
                
                newAccountConsumer.vlocity_cmt__PrimaryContactId__c = newContact.Id;
                update newAccountConsumer;
                
                Product2 newProductPlan = new Product2();
                newProductPlan.Name = 'Plan Movil';
                newProductPlan.ProductCode = 'plan_movil';
                newProductPlan.Family = 'Movil';
                newProductPlan.IsActive  = true;
                newProductPlan.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
                //newProduct.vlocity_cmt__JSONAttribute__c = '{"ATTCAT_Caracteristicas_Planes":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4W00000BNOADQA5","attributeid__c":"a0P3B000004gt0XUAQ","attributecategoryid__c":"a0O3B0000034wSzUAI","categorycode__c":"ATTCAT_Caracteristicas_Planes","categoryname__c":"Caracteristicas del Plan","attributeuniquecode__c":"ATT_Datos_Nacionales","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Datos Nacionales","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0M3B000008xGPLUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"500 MB","valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"500 MB"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4W00000BNOADQA5","attributeid__c":"a0P3B000004gt0ZUAQ","attributecategoryid__c":"a0O3B0000034wSzUAI","categorycode__c":"ATTCAT_Caracteristicas_Planes","categoryname__c":"Caracteristicas del Plan","attributeuniquecode__c":"ATT_Voz","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Voz","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0M3B000008xGPNUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"100 llamadas","valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"100 llamadas"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4W00000BNOADQA5","attributeid__c":"a0P3B000004gt0YUAQ","attributecategoryid__c":"a0O3B0000034wSzUAI","categorycode__c":"ATTCAT_Caracteristicas_Planes","categoryname__c":"Caracteristicas del Plan","attributeuniquecode__c":"ATT_SMS","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SMS","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0M3B000008xGPMUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"100 SMS","valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"100 SMS"},"$$AttributeDefinitionEnd$$":null}],"ATTCAT_SIMcard":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4W00000BNOADQA5","attributeid__c":"a0P3B000004gt0dUAA","attributecategoryid__c":"a0O3B0000034wT4UAI","categorycode__c":"ATTCAT_SIMcard","categoryname__c":"Caracteristicas SIM Card","attributeuniquecode__c":"ATT_MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0M3B000008xGPOUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
                insert newProductPlan;
                
                PricebookEntry newPricebookEntry = new PriceBookEntry();
                Id pbId = Test.getStandardPricebookId();
                newPricebookEntry.PriceBook2Id = pbId;
                newPricebookEntry.Product2Id = newProductPlan.id; 
                newPricebookEntry.UnitPrice = 100; 
                newPricebookEntry.IsActive = true;
                insert newPricebookEntry;
                
                Order newOrder = new Order();
                newOrder.AccountId = newAccountConsumer.Id;
                newOrder.EffectiveDate = Date.Today()+7;
                newOrder.Status = 'Draft';
                newOrder.PriceBook2Id = newPricebookEntry.PriceBook2Id; 
                insert newOrder;
                
                OrderItem newOrderItemPlan = new OrderItem();
                newOrderItemPlan.OrderId = newOrder.Id;
                newOrderItemPlan.UnitPrice = 0.0;
                newOrderItemPlan.Quantity = 1;
                newOrderItemPlan.PricebookEntryId = newPricebookEntry.Id;
                newOrderItemPlan.vlocity_cmt__Action__c = 'Add';
                newOrderItemPlan.vlocity_cmt__BillingAccountId__c = newAccountBilling.Id;
                newOrderItemPlan.vlocity_cmt__ServiceAccountId__c = newAccountConsumer.id;
                newOrderItemPlan.vlocity_cmt__Product2Id__c = newProductPlan.id;
                insert newOrderItemPlan;
                
                // OM                
                vlocity_cmt__FulfilmentRequestLine__c ffrl = new vlocity_cmt__FulfilmentRequestLine__c();
                ffrl.vlocity_cmt__Product2Id__c = newProductPlan.Id;
                insert ffrl;
                
                vlocity_cmt__FulfilmentRequestLineDecompRelationship__c ffrldr = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c();
                ffrldr.vlocity_cmt__DestinationFulfilmentRequestLineId__c = ffrl.Id;
                ffrldr.vlocity_cmt__SourceOrderItemId__c = newOrderItemPlan.Id;
                insert ffrldr;
                
                vlocity_cmt__OrchestrationPlan__c orchestrationPlan = new vlocity_cmt__OrchestrationPlan__c();
                orchestrationPlan.vlocity_cmt__OrderId__c = newOrder.Id;
                insert orchestrationPlan;
                
                newOrder.vlocity_cmt__OrchestrationPlanId__c = orchestrationPlan.Id;
                Update newOrder;
                
                vlocity_cmt__OrchestrationItem__c newOrchestrationItem = new vlocity_cmt__OrchestrationItem__c();
                newOrchestrationItem.vlocity_cmt__OrchestrationPlanId__c = orchestrationPlan.Id;
                newOrchestrationItem.vlocity_cmt__FulfilmentRequestLineId__c =  ffrl.Id;  
                newOrchestrationItem.vlocity_cmt__OrderItemId__c = newOrderItemPlan.Id;
                newOrchestrationItem.vlocity_cmt__OrchestrationItemType__c = 'AutoTask';
                newOrchestrationItem.name = 'Test 1';
                insert newOrchestrationItem;

            }
        }
        catch(DmlException e){
            System.debug('Error method generate data ' + e.getCause() + ' ' + e.getMessage() + ' Error in line ' + e.getLineNumber()); 
        }
    }
}
export const OMNIDEF = {"userTimeZone":-180,"userProfile":"System Administrator","userName":"lamis.dahbur@desktop.com.br.partial","userId":"0058b00000IRaL6AAL","userCurrencyCode":"BRL","timeStamp":"2024-06-21T19:23:03.879Z","sOmniScriptId":"a34Ha000000EPcrIAG","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":"LXD_OSOverride"},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollToTopWhenNavigatingBetweenStepsOnExperienceCloudSites":true,"scrollBehavior":"smooth","saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":true,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"allowCancel":true},"prefillJSON":"{}","lwcId":"247934dd-5230-dcf2-0fff-e76e811dc30d","labelMap":{"TextBlock1":"Dados Inconsistentes:TextBlock1","CustomLWC1":"Enviar E-mail:CustomLWC1","Enviar E-mail":"Enviar E-mail","Dados Inconsistentes":"Dados Inconsistentes","IntegrationProcedureAction1":"IntegrationProcedureAction1"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendOnlyExtraPayload":true,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"GetContactByCase","remoteTimeout":30000,"remoteOptions":{"postTransformBundle":"","preTransformBundle":"","chainable":false,"useFuture":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"IntegrationProcedureAction1","integrationProcedureKey":"Every_GetContactByCase","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"caseId":"%ContextId%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"IntegrationProcedureAction1","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IntegrationProcedureAction1","lwcId":"lwc0"},{"type":"Step","propSetMap":{"HTMLTemplateId":"","allowSaveForLater":false,"businessCategory":"","businessEvent":"","cancelLabel":"Cancel","cancelMessage":"Are you sure?","chartLabel":null,"completeLabel":"Complete","completeMessage":"Are you sure you want to complete the script?","conditionType":"Hide if False","errorMessage":{"custom":[],"default":null},"instruction":"<p><img style=\"display: block; margin-left: auto; margin-right: auto;\" src=\"/resource/1663183427000/icon_sideBar2/Status_Icon/IconError.png\" alt=\"\" width=\"152\" height=\"152\" /></p>\n<p style=\"text-align: center;\"><strong>Dados inconsistentes para executar essa a&ccedil;&atilde;o, abrir um chamado no GLPI.</strong></p>","instructionKey":"","knowledgeOptions":{"dataCategoryCriteria":"","keyword":"","language":"English","publishStatus":"Online","remoteTimeout":30000,"typeFilter":""},"label":"","message":{},"nextLabel":"Next","nextWidth":"0","previousLabel":"Previous","previousWidth":"0","pubsub":false,"remoteClass":"","remoteMethod":"","remoteOptions":{},"remoteTimeout":30000,"saveLabel":"","saveMessage":"","show":{"group":{"rules":[{"field":"GetContactByCase:statusCode","condition":"=","data":"422"}],"operator":"AND"}},"showPersistentComponent":[true,false],"ssm":false,"validationRequired":true,"wpm":false,"uiElements":{"Dados Inconsistentes":""},"aggElements":{}},"offSet":0,"name":"Dados Inconsistentes","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":1,"response":null,"propSetMap":{"sanitize":false,"textKey":"","HTMLTemplateId":"","dataJSON":false,"show":null,"text":"<p style=\"text-align: center;\"></p>\n<p style=\"text-align: center;\"><strong><img src=\"/resource/1663183427000/icon_sideBar2/Status_Icon/IconError.png\" alt=\"\" width=\"152\" height=\"152\" /></strong></p>\n<p style=\"text-align: center;\"><strong>Dados inconsistentes para executar essa a&ccedil;&atilde;o, abrir um chamado no GLPI.</strong></p>","label":"TextBlock1","controlWidth":12},"name":"TextBlock1","level":1,"JSONPath":"Dados Inconsistentes:TextBlock1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc10-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Dados Inconsistentes","lwcId":"lwc1"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":"0","previousLabel":"Previous","nextWidth":"0","nextLabel":"Next","message":{},"label":"","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"Enviar E-mail":""},"aggElements":{"CustomLWC1":""}},"offSet":0,"name":"Enviar E-mail","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":2,"response":null,"propSetMap":{"show":null,"lwcName":"every_EnviarEmail","label":"CustomLWC1","hide":false,"customAttributes":[{"source":"%GetContactByCase%","name":"records"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"CustomLWC1","level":1,"JSONPath":"Enviar E-mail:CustomLWC1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc20-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Enviar E-mail","lwcId":"lwc2"}],"bReusable":false,"bpVersion":2,"bpType":"Every","bpSubType":"EnvioDeEmail","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"GetContactByCase":null}};
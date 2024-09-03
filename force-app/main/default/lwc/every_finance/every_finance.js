import { LightningElement, track, api } from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { getNamespaceDotNotation } from "vlocity_cmt/omniscriptInternalUtils";
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { OmniscriptActionCommonUtil } from "vlocity_cmt/omniscriptActionUtils";

export default class EveryFinance extends OmniscriptBaseMixin(FlexCardMixin(LightningElement)) {

  _actionUtil;
  _ns = getNamespaceDotNotation();

  @api records;
  @track assetId;
  @track ContextId;
  @track jsoncase;
  @api ppoeUser;
  @track erroAtivoContrato = false;
  erroContrato = false;
  erroAtivo = false;


  connectedCallback(){
    if (this.records.Case.AssetId == null || this.records.Case.Contrato__c == null) {
      this.erroAtivoContrato = true;
      this.erroAtivo = this.records.Case.AssetId == null ? true : false;
      this.erroContrato = this.records.Case.Contrato__c == null ? true : false;
      return;
    }
    this.jsoncase = this.records.Case;
    // console.log("records ", JSON.stringify(this.records));
    this.assetId = JSON.stringify(this.records.Case.AssetId);
    this.ContextId = this.records.Case.AssetId;
    this.ppoeUser = this.records.Case.Asset.PlanLogin__c;
  }
}
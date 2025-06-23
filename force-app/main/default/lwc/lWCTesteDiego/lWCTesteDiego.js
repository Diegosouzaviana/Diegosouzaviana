import { LightningElement, api, track } from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';


export default class LWCTesteDiego extends OmniscriptBaseMixin(LightningElement) {

    @track _input;

    @api
    get INPUT() {
        return this._input;
    }

    set INPUT(value) {
        this._input = value;
        console.log(JSON.stringify(this._input));
        console.log((this._input));
    }

    connectedCallback() {
        console.log('connectedCallback INPUT:', JSON.stringify(this.INPUT));
    }

}
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class Every_NextPageSchedule extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    @api label;
    nextButton(evt) {
        if (evt) {
            this.omniNextStep();
        }
    }
}
/*
    =================================================================
    CHANGE LOG  
    ---------------------------------------------------
    * 2023-01-18 - Wesley Prado - Refactor: Major component refactor ♻️.
    ---------------------------------------------------
    =================================================================
*/

import { api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import Tab from 'vlocity_cmt/tab';
import tmpl from './lXD_SelectPlanItems.html';

const CURRENCY_REGEX = /[0-9.]+,\d{2}$/

export default class LXD_SelectPlanItems extends OmniscriptBaseMixin(Tab) {
    @api userprofile = {}; 
    @api product = {};
    @api customlabels;
    @api index = '';
    // @api defaultproductimage
    defaultproductimage = '/resource/backgroundProduct';

    get hasListPrice(){
        return CURRENCY_REGEX.test(this.product.ListPrice)
     }

    get hasRecurringPrice(){
       return CURRENCY_REGEX.test(this.product.RecurringPrice)
    }

    get image() {
        if(this.userprofile == this.profileFromCommunity){
            
            return this.product.Image
            //return '..' + this.product.Image
            
        }else{

            return this.product.Image.substr(2)
            //return this.product.Image;
        }
    }
    render(){
        return tmpl;
    }
}
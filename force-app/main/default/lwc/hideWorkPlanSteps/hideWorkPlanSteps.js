import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOM_STYLES from '@salesforce/resourceUrl/AcessoMinimoWorkOrderStyle';

export default class HideWorkPlanSteps extends LightningElement {
    isCssLoaded = false;
    renderedCallback() {   
    if (this.isCssLoaded) return;  
    loadStyle(this, CUSTOM_STYLES)
        .then(() => { 
            console.log('hideEndChatButton css file loaded.');    
            this.isCssLoaded = true;   
        }).catch(error => {   
            console.log('hideEndChatButton css file FAILED to load.' + error);  
        }); 
    }
}
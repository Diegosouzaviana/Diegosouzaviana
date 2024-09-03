/*
    @author: Wesley Prado
    @description: Custom button component to act like an IP action button.
    @created: 2023-02-15

    =================================================================
    CHANGE LOG  
    ---------------------------------------------------
    aaaa-mm-dd      dev name        work description
    ---------------------------------------------------
    =================================================================
*/

import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LXD_ActionButton extends OmniscriptBaseMixin(NavigationMixin(LightningElement)){
    _ns = getNamespaceDotNotation();

    @api methodName = '';
    @api buttonText = 'Click here';
    @api omniSpinnerEnabled = false;
    @api cssClass = 'slds-button slds-button_brand';
    // @api styleInLine = '';
    @api optionsNode = '';
    @api inputNode = '';
    @api formulaAddressNode = '';
    showbuttom= true;
    showPreviousButton = false;
    showNextButton = false;

    @track showSpinner = false;

    async handleClick(_){
        this.showSpinner = true;
        const formulaAddress = this.omniJsonData[this.inputNode][this.formulaAddressNode];
        const responseformulaAddress = formulaAddress.replace(/\s/g, '');
        this.omniApplyCallResp({[this.inputNode]: {'responseformulaAddress' : responseformulaAddress}})
        if(!this.omniJsonData[this.inputNode]) this.errorHelper('Invalid input node: ' + this.inputNode);
        
        const input = this.omniJsonData[this.inputNode];
        const options = this.omniJsonData[this.optionsNode] ? this.omniJsonData[this.optionsNode] : {};
        const VCEP = this.validarCEP(input.Input_CEP);
        console.log("VCEP", VCEP);
        console.log("input", JSON.stringify(input));

        if (!input.Input_Number || !input.Input_TypeAddress || !VCEP) {
            this.mostrarToast('Preencha os campos obrigatórios', 'error');
            this.showSpinner = false;
        }else {
            const params ={
                input: JSON.stringify(input),
                options: JSON.stringify(options),
                sClassName: `${this._ns}IntegrationProcedureService`,
                sMethodName: this.methodName
            };      
            try {
                const response = await this.omniRemoteCall(params, this.omniSpinnerEnabled);
                this.omniApplyCallResp(JSON.parse(JSON.stringify(response)));
                console.log("response", JSON.stringify(response));
                if (response.result.IPResult.MudancaEndereco.availability == false ||
                    response.result.IPResult.MudancaEndereco.networkCoverage == false ||
                    response.result.IPResult.MudancaEndereco.ctoAvailability == false) {
                    this.mostrarToast('Tecnologia não disponível no endereço.', 'Erro');
                    this.showPreviousButton = true;
                    this.showSpinner = false;
                } else{
                    this.mostrarToast('Tecnologia disponível no endereço.', 'success');
                    this.showSpinner = false; 
                    this.showNextButton = true;
                    this.showPreviousButton = true;
                } 
            } catch (error) {
                console.error(error);
                this.showSpinner = false;
                console.log('showSpinner2 '+ this.showSpinner);
            }
        }
    }

    errorHelper(msg){
        throw new Error(msg);
    }
    validarCEP(cep) {
        cep = cep.trim();
        var regexCEP = /^[0-9]{5}-?[0-9]{3}$/;
        return regexCEP.test(cep);
    }
    
    //Diego
    mostrarToast(message, variant) {
        const evt = new ShowToastEvent({
            title: variant === 'success' ? 'Sucesso' : 'Erro',
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
    nextButton(evt) { 
        if(evt) {
            this.omniNextStep();
        }
    }  
    
    prevButton(evt) { 
        if(evt) {
            this.omniPrevStep();
        }

        
    }
}
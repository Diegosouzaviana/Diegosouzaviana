import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class Lwc_BotaoAgendaVaga extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    @api records;
    // @track records = { "dentro24hrs": false, "possuiSlots24hrs": false };
    @track SolicitaAntecipacao = '';
    @track ConvenienciaCliente = '';


    connectedCallback() {
        console.log("records", JSON.stringify(this.records));
    }
    get options() {
        return [
            { label: 'Sim', value: 'true' },
            { label: 'Não', value: 'false' },
        ];
    }

    get options1() {
        return [
            { label: 'Sim', value: 'true' },
            { label: 'Não', value: 'false' },
        ];
    }


    get isOptionSelected1() {
        return this.SolicitaAntecipacao !== ''; // Verifica se alguma opção foi selecionada
    }


    handleRadioChange1(event) {
        this.SolicitaAntecipacao = event.detail.value;
        // console.log("SolicitaAntecipacao", this.SolicitaAntecipacao);

    }

    get showProximo() {
        return !this.records.dentro24hrs && !this.records.possuiSlots24hrs;
    }

    get showOtherButtons() {
        return !this.records.dentro24hrs && this.records.possuiSlots24hrs;
    }

    avancButton(evt) {
        if (evt) {
            this.omniApplyCallResp({ "SolicitaAntecipacao": this.SolicitaAntecipacao });
            this.omniNextStep();
        }
    }

    nextButton(evt) {
        if (evt) {
            this.omniApplyCallResp({ "ConvenienciaCliente": true });
            this.omniNextStep();
        }
    }

    goToStep(evt) {
        if (evt) {
            this.omniNavigateTo(this.omniScriptHeaderDef.asIndex - 4);
        }
    }


}
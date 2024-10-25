import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Every_recordPopupChurn extends OmniscriptBaseMixin(LightningElement) {

    _actionUtil;
    _ns = getNamespaceDotNotation();
    @api recordId;
    @track isOpen = false;
    @track motivo = false;
    // @track url = "https://desktopsa--partial.sandbox.lightning.force.com/";
    @track url = "/lightning/r/Case/";
    @track resources = {
        // statusVerde: '/resource/iconChurn/icon/verde.jpg',
        // statusAmarelo: '/resource/iconChurn/icon/amarelo.jpg',
        // statusVermelho: '/resource/iconChurn/icon/Vermelho.jpg',
        statusVerde: '/resource/iconChurn/icon/Circulo_verde.png',
        statusAmarelo: '/resource/iconChurn/icon/Circulo_amarelo.png',
        statusVermelho: '/resource/iconChurn/icon/Circulo_vermelho.png',
    };
    connectedCallback(){
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.CallIntegrationGeral(this.recordId);
    }

    @api
    open() {
        this.isOpen = true;
    }

    handleClose() {
        this.isOpen = false;
    }
    segments = ['Diamante', 'Rubi', 'Esmeralda', 'Safira', 'Cliente novo'];

    get segmentClasses() {
        return this.segments.map(segment => ({
            name: segment,
            className: segment == this.segmento ? 'special-segment' : 'dim-opacity',
            isCurrent: segment == this.segmento ? true : false
        }));
    }

    get chancedeChurnImage() {
        let baseClass = 'slds-truncate';
        if (this.prioridadeAtendimento === 'Alta') {
                return `${baseClass} high-priority`;
            } else if (this.chancedeChurn === 'Média') {
                return `${baseClass} medium-priority`;
            } else if (this.chancedeChurn === 'Baixa') {
                return `${baseClass} low-priority`;
            }
            return baseClass;
    }

    get prioridadeClass() {
        
        switch (this.chancedeChurn) {
            case 'Alto':
                return this.resources.statusVermelho;
            case 'Médio':
                return this.resources.statusAmarelo;
            case 'Baixo':
                return this.resources.statusVerde;
            default:
                return '';
        }
    }
    get prioridadeValitacaosldssize() {
        let baseClass = 'slds-size_1-of-12';
        let baseClass2 = 'slds-size_2-of-12 slds-cell-wrap';
        if (this.Valitacao === 'Não') {
            return `${baseClass}`;
        }else{
            return `${baseClass2}`;
        }
    }
    get prioridadeValitacao() {
        let baseClass = '';
        if (this.Valitacao === 'Não') {
            return `${baseClass} validatrue`;
        }else{
            return `${baseClass} validafalse`;
        }
    }
    get motivofianlizado() {
        // console.log("motivo ", this.motivo);
        if (this.motivo != "Finalizado") {
            return true;
        }else{
            return false;
        }
    }
    get verificaTipoValitacao() {
        // console.log("motivo ", this.motivo);
        if (this.Valitacao != "Não") {
            return false;
        }else{
            return true;
        }
    }
    get formattedValitacao() {
        return this.url + this.CaseIdantigo + "/view";
    }
    get valitacaoLabel() {
        return this.CaseNumber;
    }

    CallIntegrationGeral(caseId){

        const input = {
            CaseId: caseId,
        };

        const params = {
            input: JSON.stringify(input),
            sClassName: "IntegrationProcedureService",
            sMethodName: "Every_recordPopupChurn",
            options: "{}",
        };

        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            // console.log('response' + JSON.stringify(response));
            const ipResult = response.result.IPResult;
             if (ipResult && typeof ipResult === 'object' && Object.keys(ipResult).length > 0 && ipResult.ChurnId != null) {
                if(ipResult.UserName == "Retenção" || ipResult.UserName == "Administrador"){
                    this.processResponse(ipResult); 
                    this.open();
                }
            }             
         })
        .catch((error) => {
            console.error(error, "ERROR");
        });
    }
    formatdata(CreatedDate){
        const data = new Date(CreatedDate);
        const dataFormatada = data.toLocaleDateString('pt-BR');
        return dataFormatada;
    }
    processResponse(response) {
        if (response) {
            this.chancedeChurn = response.ChancedeChurn || '';
            this.prioridadeAtendimento = response.PrioridadeAtendimento || '';
            this.segmento = response.Segmento || '';
            this.Valitacao = response.Valitacao || '';
            this.motivo =  response.Status || '';
            this.CaseIdantigo =  response.CaseIdantigo || '';
            this.CaseNumber =  response.CaseNumber || '';
            this.CreatedDate =  this.formatdata(response.CreatedDate) || '';
            
            const Motivo = response.Motivo || '';
            if (Motivo.startsWith('Cancelamento')) {
                this.Motivo = Motivo.replace('Cancelamento', '').trim();
                // console.log("this.Motivo", this.Motivo);
                
            }
        }
    }
}
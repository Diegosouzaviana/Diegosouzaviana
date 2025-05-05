import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_BotaoNextRemocaoPontoMesh extends OmniscriptBaseMixin(LightningElement) {

    @track meshSelecionado;
    @track removerMesh;
    @track removerPontoMesh;
    @track quantidademeshSelecionado;
    @api stepName;
    @api contador;

    connectedCallback() {
        // console.log("stepName", JSON.stringify(this.stepName));
    }

    validaSelecaomesh() {
        // console.log("stepName 1", JSON.stringify(this.stepName));
        this.meshSelecionado = this.stepName.Formula2;
        this.quantidademesh = this.stepName.Formula3;
        this.quantidademeshSelecionado = this.stepName.Formula4;
        this.removerMesh = this.stepName.Block3.removerMesh;
        this.removerPontoMesh = this.stepName.Block3.removerPontoMesh;
        this.contador = this.contador;


        // console.log("removerMesh", this.removerMesh);
        // console.log("removerPontoMesh", this.removerPontoMesh);
        // console.log("meshSelecionado", this.meshSelecionado);
        // console.log("this.quantidademeshSelecionado", this.quantidademeshSelecionado);
        // console.log("cantodorIqual", cantodorIqual);

        if (this.removerMesh == "Não") {
            this.nextButton();
        } else {
            if (this.removerMesh == "Sim" && this.removerPontoMesh == null && this.meshSelecionado == false) {
                // console.log("entrou 1");
                this.nextButton();

            } else if (this.removerMesh == undefined && this.removerPontoMesh == null && this.meshSelecionado == false) {
                // console.log("entrou 3");
                this.nextButton();

            } else if (this.removerMesh == "Sim" && this.removerPontoMesh > 0 && this.removerPontoMesh <= this.contador && this.meshSelecionado == false && this.quantidademesh == 0) {
                // console.log("entrou 4");
                this.mostrarToast('Selecione pontos Mesh a serem removidos.', 'warning');
            } else if (this.removerMesh == "Sim" && this.removerPontoMesh != null && this.meshSelecionado == false && this.quantidademeshSelecionado == true) {
                // console.log("entrou 5");
                // this.mostrarToast('Por favor, selecione pontos Mesh a serem removidos.', 'warning');
            } else {
                // console.log("entrou 6");
                this.nextButton();
            }
        }
    }

    mostrarToast(message, variant) {
        const evt = new ShowToastEvent({
            title: 'Atenção',
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    nextButton() {
        this.omniNextStep();

    }

    prevButton(evt) {
        if (evt) {
            this.omniPrevStep();
        }
    }
}
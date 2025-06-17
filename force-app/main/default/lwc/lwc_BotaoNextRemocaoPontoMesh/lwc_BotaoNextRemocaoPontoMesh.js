import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_BotaoNextRemocaoPontoMesh extends OmniscriptBaseMixin(LightningElement) {

    @track meshSelecionado;
    @track removerMesh;
    @track removerPontoMesh;
    @track quantidademeshSelecionado;
    @track quantidadetv;
    @track quantidademesh;
    @track tvSelecionado;
    @track removerTV;
    @track removerPontoTV;
    @track quantidadetvSelecionado;
    @api stepName;
    @api contador;
    @api contadortv;

    connectedCallback() {
        console.log("stepName", JSON.stringify(this.stepName));
    }

    validaSelecaomesh() {
        // console.log("stepName 1", JSON.stringify(this.stepName));
        //mesh
        this.meshSelecionado = this.stepName.Formula2;
        this.quantidademesh = this.stepName.Formula3;
        this.quantidademeshSelecionado = this.stepName.Formula4;
        this.removerMesh = this.stepName.Block3.removerMesh;
        this.removerPontoMesh = this.stepName.Block3.removerPontoMesh;
        this.contador = this.contador;
        // tv
        this.tvSelecionado = this.stepName.Formula6;
        this.quantidadetv = this.stepName.Formula7;
        this.quantidadetvSelecionado = this.stepName.Formula8;
        this.removerTV = this.stepName.Block9.removerTV;
        this.removerPontoTV = this.stepName.Block9.removerPontoTV;
        this.contadortv = this.contadortv;


        console.log("removerMesh", this.removerMesh);
        console.log("meshSelecionado", this.meshSelecionado);
        console.log("removerPontoMesh", this.removerPontoMesh);
        console.log("quantidademesh", this.quantidademesh);
        console.log("this.quantidademeshSelecionado", this.quantidademeshSelecionado);
        console.log("contador", this.contador);

        console.log("removerTV", this.removerTV);
        console.log("tvSelecionado", this.tvSelecionado);
        console.log("removerPontoTV", this.removerPontoTV);
        console.log("quantidadetv", this.quantidadetv);
        console.log("quantidadetvSelecionado", this.quantidadetvSelecionado);
        console.log("contadorTV", this.contadortv);

        // if (this.removerMesh == "Não") {
        //     this.nextButton();
        // } else {
        //     if (this.removerMesh == "Sim" && this.removerPontoMesh == null && this.meshSelecionado == false) {
        //         // console.log("entrou 1");
        //         this.nextButton();

        //     } else if (this.removerMesh == undefined && this.removerPontoMesh == null && this.meshSelecionado == false) {
        //         // console.log("entrou 3");
        //         this.nextButton();

        //     } else if (this.removerMesh == "Sim" && this.removerPontoMesh > 0 && this.removerPontoMesh <= this.contador && this.meshSelecionado == false && this.quantidademesh == 0) {
        //         // console.log("entrou 4");
        //         this.mostrarToast('Selecione pontos Mesh a serem removidos.', 'warning');
        //     } else if (this.removerMesh == "Sim" && this.removerPontoMesh != null && this.meshSelecionado == false && this.quantidademeshSelecionado == true) {
        //         // console.log("entrou 5");
        //         // this.mostrarToast('Por favor, selecione pontos Mesh a serem removidos.', 'warning');
        //     } else {
        //         // console.log("entrou 6");
        //         this.nextButton();
        //     }
        // }

        // Chamada da lógica unificada
        // if ((this.removerMesh == "Nao" || this.removerMesh == undefined) && (this.removerTV == "Nao" || this.removerTV == undefined)) {
        //     this.mostrarToast('Você deve selecionar os panto de remoção (TV e Mesh).', 'warning');
        // } else {
        //     if (this.removerMesh == "Sim") {
        //         this.validaTipo(
        //             this.removerMesh,
        //             this.removerPontoMesh,
        //             this.meshSelecionado,
        //             this.quantidademesh,
        //             this.quantidademeshSelecionado,
        //             this.contador,
        //             'Mesh'
        //         );
        //     }

        //     if (this.removerTV == "Sim") {
        //         this.validaTipo(
        //             this.removerTV,
        //             this.removerPontoTV,
        //             this.tvSelecionado,
        //             this.quantidadetv,
        //             this.quantidadetvSelecionado,
        //             this.contadortv,
        //             'TV'
        //         );
        //     }
        // }
        const nenhumSelecionado = (this.removerMesh !== "Sim" && this.removerTV !== "Sim");

        if (nenhumSelecionado) {
            this.mostrarToast('Você deve selecionar os pontos de remoção (TV e Mesh).', 'warning');
            return;
        }

        if (this.removerMesh === "Sim") {
            this.validarRemocao({
                remover: this.removerMesh,
                ponto: this.removerPontoMesh,
                selecionado: this.meshSelecionado,
                quantidade: this.quantidademesh,
                quantidadeSelecionado: this.quantidademeshSelecionado,
                contador: this.contador,
                tipo: 'Mesh'
            });
        }

        if (this.removerTV === "Sim") {
            this.validarRemocao({
                remover: this.removerTV,
                ponto: this.removerPontoTV,
                selecionado: this.tvSelecionado,
                quantidade: this.quantidadetv,
                quantidadeSelecionado: this.quantidadetvSelecionado,
                contador: this.contadortv,
                tipo: 'TV'
            });
        }
    }
    validarRemocao({ remover, ponto, selecionado, quantidade, quantidadeSelecionado, contador, tipo }) {
        const nenhumSelecionado = ponto == null && selecionado === false;

        if (remover !== "Sim") {
            this.nextButton();
            return;
        }

        if (nenhumSelecionado && (remover === "Sim" || remover === undefined)) {
            this.nextButton();
            return;
        }

        const dentroDoLimite = ponto > 0 && ponto <= contador;
        const nenhumDisponivel = quantidade === 0;

        if (dentroDoLimite && !selecionado && nenhumDisponivel) {
            this.mostrarToast(`Selecione pontos ${tipo} a serem removidos.`, 'warning');
            return;
        }

        if (ponto != null && !selecionado && quantidadeSelecionado) {
            // this.mostrarToast(`Por favor, selecione pontos ${tipo} a serem removidos.`, 'warning');
            return;
        }

        this.nextButton();
    }
    validaTipo(remover, ponto, selecionado, quantidade, quantidadeSelecionado, contador, tipo) {
        if (remover == "Não") {
            console.log("1");
            this.nextButton();
            return;
        } else if (remover == "Sim" && ponto == null && selecionado == false) {
            console.log("2");
            this.nextButton();
            return;
        } else if (remover == undefined && ponto == null && selecionado == false) {
            console.log("3");
            this.nextButton();
            return;
        } else if (remover == "Sim" && ponto > 0 && ponto <= contador && selecionado == false && quantidade == 0) {
            console.log("4");
            this.mostrarToast(`Selecione pontos ${tipo} a serem removidos.`, 'warning');
            return;
        } else if (remover == "Sim" && ponto != null && selecionado == false && quantidadeSelecionado == true) {
            console.log("5");
            return;
            // this.mostrarToast(`Por favor, selecione pontos ${tipo} a serem removidos.`, 'warning');
        } else {
            console.log("6");
            this.nextButton();
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
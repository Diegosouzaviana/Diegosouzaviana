import { LightningElement, track, api } from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Every_ButonCopyQrCode extends FlexCardMixin(LightningElement) {
    @api textoParaCopiar = null;
    @track mostrarHelpText = false;

    imagemBotao = "/resource/icon_sideBar/icon/pix.png";

    alterarCursor(event) {
        event.target.style.cursor = 'pointer';
        this.mostrarHelpText = true;
    }

    resetarCursor(event) {
        event.target.style.cursor = 'default';
        this.mostrarHelpText = false;
    }
    
    copiarTexto() {
        console.log('copy' + this.textoParaCopiar);
        // if (this.textoParaCopiar && this.textoParaCopiar.trim() !== '') {
        //     this.copyToClipboard(this.textoParaCopiar);
        // } 
        if (this.textoParaCopiar && this.textoParaCopiar.length > 6) {
            this.copyToClipboard(this.textoParaCopiar);
            console.log('copyToClipboard' + this.copyToClipboard);
        }else {
            this.mostrarToast('O texto está vazio ou é null', 'error');
        }
    }

    copyToClipboard(data) {
        const textarea = document.createElement('textarea');
        textarea.value = data;
        document.body.appendChild(textarea);
        textarea.select();
        try {
            document.execCommand('copy');
            this.mostrarToast('Texto copiado para a área de transferência', 'success');
        } catch ( err) {
            console.error('Erro ao copiar dados para a área de transferência', err);
            this.mostrarToast('Erro ao copiar o texto', 'error');
        }
        document.body.removeChild(textarea);
    }

    mostrarToast(message, variant) {
        const evt = new ShowToastEvent({
            title: variant === 'success' ? 'Sucesso' : 'Erro',
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}
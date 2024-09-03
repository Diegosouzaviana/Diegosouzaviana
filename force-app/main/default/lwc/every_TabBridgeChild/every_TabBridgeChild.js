import { LightningElement, api, track} from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";

export default class Every_TabBridgeChild extends FlexCardMixin(LightningElement) {
    // @api ips; // Propriedade para receber a lista de IPs
    // @api macs; // Propriedade para receber a lista de MACs
    @track ipsValida = false; // Flag para indicar se ips é válido
    @track macsValida = false; // Flag para indicar se macs é válido
    // @api input;
    // @api inputAssetId;
    // @api tipoBridge;
    @track bridgeInfoError = false;
    @api
    get ips() {
        // console.log('IPs acessados:', JSON.stringify(this._ips));
        return this._ips;
    }
    set ips(value) {
        this._ips = value;
        this.ipsValida = this.isListaValida(value);
        this.bridgeInfoError = !this.ipsValida && !this.macsValida;
        // setTimeout(() => {
        //     this.bridgeInfoError = !this.ipsValida && !this.macsValida;
        //     // this.bridgeInfoError = (!Array.isArray(this.macs) || !this.macs) && (!Array.isArray(value) || !value);
        //     }, 500)
    }
    @api
    get macs() {
        // console.log('MACs acessados:', JSON.stringify(this._macs));
        return this._macs;
    }
    set macs(value) {
        this._macs = value;
        this.macsValida = this.isListaValida(value);
        this.bridgeInfoError = !this.ipsValida && !this.macsValida;
        // setTimeout(() => {
        //     this.bridgeInfoError = !this.ipsValida && !this.macsValida;
        //     // this.bridgeInfoError = (!Array.isArray(this.ips) || !this.ips) && (!Array.isArray(value) || !value);
        //     }, 500) 
    }

    // Método para verificar se é uma lista válida e não nula
    isListaValida(lista) {
        return Array.isArray(lista) && lista.length > 0;
    }


    connectedCallback() {
        //console.log('Lista válida ', JSON.stringify(this.isListaValida));
    }
}
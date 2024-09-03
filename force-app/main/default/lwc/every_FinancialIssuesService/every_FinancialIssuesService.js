import { LightningElement, track, api, wire } from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Every_FinancialIssuesService extends OmniscriptBaseMixin(FlexCardMixin(LightningElement)) {

    @api caseData;
    @track data = [];
    @track page = 1;
    @track itemsPerPage = 10;
    @track searchTerm = '';
    @track set_size = 5;
    @track pages = [];
    @track ppoe = '';
    @track ultimoAcesso = '';
    @api assetId;
    @api ppoeUser;
    @track erroAtivoContrato = false;
    @track erroAtivo = false;
    @track erroContrato = false;
    @track showSpinner = false;

    @track itemsPerPageOptions = [
        { label: '2', value: 2},
        { label: '3', value: 3},
        { label: '5', value: 5},
        { label: '10', value: 10}
    ];

    _actionUtil;
    _ns = getNamespaceDotNotation();
    historico = [];
    mensageErrorGeral = "";
    errorGeral = false;
    showdado = false;
    errocpf;
    erroadm;

    columns = [
        { label: 'Boleto', fieldName: 'Boleto', wrapText: true},
        { label: 'Vencimento', fieldName: 'Vencimento', wrapText: true},
        { label: 'Valor', fieldName: 'Valor', wrapText: true},
        { label: 'Multa', fieldName: 'Multa', wrapText: true},
        { label: 'Juros', fieldName: 'Juros', wrapText: true },
        { label: 'Total', fieldName: 'Total', wrapText: true },
    ];

    connectedCallback(){
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.CallIntegrationGeral(this.assetId);
        this.pppoe = this.ppoeUser;

        // console.log('Asset Id '+this.assetId);
        // console.log('ppoeUser*****************'+this.ppoeUser);
        // this.CallIntegrationGeral(this.caseData.Case.AssetId);
        // this.pppoe = this.caseData.Case.Asset.PlanLogin__c;
    }

    get filteredData() {
        const lowerCaseSearchTerm = this.searchTerm.toLowerCase();
    
        return this.data.filter(record => 
            Object.values(record).some(value => 
                value.toString().toLowerCase().includes(lowerCaseSearchTerm)
            )
        );
    }

    get paginatedData() {
        const start = (this.page - 1) * this.itemsPerPage;
        const end = this.page * this.itemsPerPage;
        return this.filteredData.slice(start, end);
    }

    get paginationInfo() {
        const firstRecordOnPage = (this.page - 1) * this.itemsPerPage + 1;
        const lastRecordOnPage = Math.min(this.page * this.itemsPerPage, this.data.length);
        return `Mostrando do ${firstRecordOnPage} ao ${lastRecordOnPage} de ${this.data.length} registros.`;
    }

    get showPreviousButton() {
        return this.page > 1;
    }
    
    get showNextButton() {
        const lastRecordOnPage = this.page * this.itemsPerPage;
        return lastRecordOnPage < this.filteredData.length;
    }

    get pagesList() {
        let mid = Math.floor(this.set_size / 2) + 1;
        if (this.page > mid) {
            return this.pages.slice(
                this.page - mid, 
                this.page + mid - 1);
        }
        return this.pages.slice(0, this.set_size);
    }

    get shouldShowPagination() {
        return this.pagesList && this.pagesList.length > 1;
    }

    get totalSum() {
        const sum = this.filteredData.reduce((acc, record) => acc + parseFloat(record.Total.replace('R$ ', '')), 0);
        return sum.toFixed(2);
    }

    get pageTotalSum() {
        const start = (this.page - 1) * this.itemsPerPage;
        const end = this.page * this.itemsPerPage;
        const pageData = this.filteredData.slice(start, end);
        const sum = pageData.reduce((acc, record) => acc + parseFloat(record.Total.replace('R$ ', '')), 0);

        return sum.toFixed(2);
    }

    setPages = (data) => { 
        let numberOfPages = Math.ceil(data.length / this.itemsPerPage);
        this.pages = [];

        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }
    
    handleNext = () => {
        if (this.page < this.pages.length) {
            ++this.page;
        }
    }

    handlePrevious = () => {
        if (this.page > 1) {
            --this.page;
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.page = 1; 
    }

    handleItemsPerPageChange(event) {
        this.itemsPerPage = parseInt(event.target.value, 10);
        this.page = 1;
        this.setPages(this.filteredData);
    }

    handlePageClick(event) {
        this.page = parseInt(event.target.dataset.id, 10);
    }

    CallIntegrationGeral(AssetId) {
        this.showSpinner = true;
        const currentDate = new Date();
        const formattedDate = `${currentDate.getDate()}/${currentDate.getMonth() + 1}/${currentDate.getFullYear()}`;
        this.ultimoAcesso = formattedDate;

        const input = {
            AssetId: AssetId,
        };

        const params = {
            input: JSON.stringify(input),
            sClassName: "IntegrationProcedureService",
            sMethodName: "Every__GetFeesIntegration",
            options: "{}",
        };

        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            // console.log("response", JSON.stringify(response));
            if (response.result.IPResult.statusCode == 422) {
                this.showSpinner = false;
                this.erroAtivoContrato = true;
                this.errocpf = response?.result?.IPResult.CPF == null || response?.result?.IPResult.CPF == ""? true : false;
                this.erroadm = response?.result?.IPResult.ADM == null || response?.result?.IPResult.ADM == ""? true : false;
                return;
            }else if(response.result.IPResult.statusCode == 400 || response.result.IPResult.statusCode == 404 ||response.result.IPResult.statusCode == 500){
                this.errorGeral = true;
                this.showSpinner = false;
                this.mensageErrorGeral = response.result.IPResult.message;
                return;
            }else if(response.result.IPResult.response == null || response.result.IPResult.statusCode == ""){
                this.showdado = true;
                this.showSpinner = false;
                return;
            }     
          
            this.historico = Array.isArray(response.result.IPResult.response) ? response.result.IPResult.response : [response.result.IPResult.response];
            // console.log("historica", JSON.stringify(this.historico));
            this.data = this.historico.map((item, index) => {
                if(item.statusCode == 200){
                    this.showdado = true;
                    this.showSpinner = false;
                    return {
                        //id: index + 1,
                        Boleto: item.boleto,
                        Vencimento: item.vencimento,
                        Valor: 'R$ ' + item.valor.toFixed(2),
                        Multa: 'R$ ' + item.HTTPResponse.fine.toFixed(2),
                        Juros: 'R$ ' + item.HTTPResponse.fees.toFixed(2),
                        Total: 'R$ ' + item.HTTPResponse.amount.toFixed(2),
                    }
                } else if(item.statusCode == 400){
                    this.errorGeral = true;
                    this.showSpinner = false;
                    this.mensageErrorGeral = item.message;
                } else if(item.statusCode == 404){
                    this.errorGeral = true;
                    this.showSpinner = false;
                    this.mensageErrorGeral = item.message;
                }else if(item.statusCode == 500){
                    this.errorGeral = true;
                    this.showSpinner = false;
                    this.mensageErrorGeral = item.message;
                }
            })
            this.showdado = true;
            this.showSpinner = false;
            this.setPages(this.data);
            
        })
        .catch((error) => {
            console.error(error, "ERROR");
        });
    }

}
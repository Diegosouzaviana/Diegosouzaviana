import { LightningElement, track, api } from 'lwc';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Every_HistoryService extends OmniscriptBaseMixin(FlexCardMixin(LightningElement)) {

    @api legacyId;
    @track data = [];
    @track page = 1;
    @track itemsPerPage = 10;
    @track searchTerm = '';
    @track set_size = 5;
    @track pages = [];

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
    showGeral = false;
    erroAtivoContrato = false;
    errorcampobrigatorio = false;
    erroAtivo;
    erroContrato;
    adm;

    columns = [
        { label: 'Data', fieldName: 'Data', wrapText: true, initialWidth: 110  },
        { label: 'Tipo', fieldName: 'Tipo', wrapText: true, initialWidth: 110 },
        { label: 'Comentários', fieldName: 'Comentarios', wrapText: true,},
        { label: 'Funcionário', fieldName: 'Funcionario', wrapText: true, initialWidth: 110 },
    ];

    connectedCallback(){
        this._actionUtil = new OmniscriptActionCommonUtil();
        // console.log("legacyId", JSON.stringify(this.legacyId));
        this.adm = this.legacyId.Case.Asset.vlocity_cmt__BillingAccountId__r.LegacyId__c;
        if (this.legacyId.Case.AssetId == null || this.legacyId.Case.Contrato__c == null) {
            this.erroAtivoContrato = true;
            this.erroAtivo = this.legacyId.Case.AssetId == null ? true : false;
            this.erroContrato = this.legacyId.Case.Contrato__c == null ? true : false;
            return;
        }else if (this.adm == null || this.adm == '' || this.adm == undefined) {
            this.errorcampobrigatorio = true;
            return;
        }
       

        // if(this.legacyId == null || this.legacyId == '' || this.legacyId == undefined){
        //     this.errorGeral = true;
        //     this.mensageErrorGeral = "Dados inconsistentes para executar essa ação, abrir um chamado no GLPI.";
        // } 

        this.getapexresult();
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
    
    async getapexresult() {
        this.CallIntegrationGeral(this.adm);
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

    CallIntegrationGeral(legacyId) {

        const input = {
            customerId: legacyId,
        };

        const params = {
            input: JSON.stringify(input),
            sClassName: "IntegrationProcedureService",
            sMethodName: "Every_API_ServiceHistory",
            options: "{}",
        };

        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            // console.log("response: ", JSON.stringify(response));
            this.historico = response.result.IPResult.response;
            if(response?.result?.IPResult?.statusCode == 200){
                this.showGeral = true;
                this.data = this.historico.map((item, index) => ({
                    id: index + 1,
                    Data: item.date,
                    Tipo: item.type,
                    //Tipo: item.type === 'C' ? 'Cliente' : item.type === 'A' ? 'Administrativo' : item.type === 'V' ? 'Venda' : item.type === 'S' ? 'Sistema' : 'Outro',
                    Comentarios: item.description,
                    Funcionario: item.employee,
                }));

                this.setPages(this.data);
            }
            else if(response?.result?.IPResult?.statusCode == 400){
                this.errorGeral = true;
                this.mensageErrorGeral = "Dados de entrada invalidos.";
            }
            else if(response?.result?.IPResult?.statusCode == 404){
                this.errorGeral = true;
                this.mensageErrorGeral = "O cliente não possui registros de atendimento.";
            }
            else{
                this.errorGeral = true;
                this.mensageErrorGeral = "Erro interno de servidor, abrir um chamado no GLPI.";
            }
        })
        .catch((error) => {
            console.error(error, "ERROR");
        });
    }

}
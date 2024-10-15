import { LightningElement, api, track } from 'lwc';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Every_GetMiscellaneousCaseChart extends LightningElement {

    _actionUtil;
    _ns = getNamespaceDotNotation();
    @track colunasMetricas = [];
    @track rowsMetricas = [];
    @track rowsMetricasSubmotivos = [];
    @track motivoSelected = '';
    @track newColumnValue = {};
    @track showTable = false;
    @track DataCase = [];
    @track casesExport = [];
    @track fullCasesList = [];
    @track startDate = new Date();
    @track endDate = new Date();
    @track showSpinner = true;
    @track atendimentoMisto = true;
    @track atendimentoValue = "Misto";
    @track showNewTable = false;
    @track showGrafico = false;

    get options() {
        return [

            { label: 'Atendimento humano', value: 'Humano' },
            { label: 'Misto (humano + automático)', value: 'Misto' },

        ];
    }

    connectedCallback(){
        this._actionUtil = new OmniscriptActionCommonUtil();
        // console.log("this.atendimentoValue", this.atendimentoValue);

        var today = new Date();
        const pastDate = new Date();
        pastDate.setDate(today.getDate() - 30);

        this.endDate = today.toISOString();
        this.startDate = pastDate.toISOString();

        this.CallIntegrationGeral(this.startDate, this.endDate);
        this.colunasMetricas = [{ name: 'D+1', id:'D1', value: 1}, { name: 'D+7', id: 'D7', value: 7}];
        this.showGrafico = true;

    }
    handleRowClick(event) {
        const colunaMotivo = event.currentTarget.dataset.motivo;
        if(colunaMotivo == 'Total') return;

        if (!this.showNewTable) {
            const tableRows = this.template.querySelectorAll('.slds-table tbody tr');
            tableRows.forEach(row => {
                row.classList.remove('selected');
            });
        }

        this.showNewTable = !this.showNewTable;

        if (this.showNewTable) {
            event.currentTarget.classList.add('selected');
        } else {
            event.currentTarget.classList.remove('selected');
        }    

        this.motivoSelected = event.currentTarget.dataset.motivo;
        this.rowsMetricasSubmotivos = this.calcularMetricasResolutividadePorMotivo(this.agruparPorContractId(this.DataCase), this.colunasMetricas, this.motivoSelected);
        this.handleUpdateExportData();
    }

    handleSelectChange(event) {
        this.atendimentoValue = event.target.value;
        // console.log("handleSelectChange atendimentoValue", this.atendimentoValue);

        this.filtrarAtendimento(event.target.value);

    }

    CallIntegrationGeral(startDate, endDate){
        this.showSpinner = true;
        const input = {dataInicio : startDate, dataFim : endDate};

        const params = {
            input: JSON.stringify(input),
            sClassName: "IntegrationProcedureService",
            sMethodName: "Every_MiscellaneousCaseChart",
            options: "{}",
        };

        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            this.DataCase = response.result.IPResult;
            this.handleUpdateExportData();
            this.fullCasesList = response.result.IPResult;
            console.log('cases IP -> ' + JSON.stringify(response.result.IPResult));
            this.handleCalcular();
            this.showSpinner = false;

         })
        .catch((error) => {
            console.error(error, "ERROR");
        });
    }

    handleUpdateExportData(){
        console.log('motivo selected -> ' + this.motivoSelected);
        if(!this.showNewTable){
            this.casesExport = this.DataCase;
        } else {
            this.casesExport = this.DataCase.filter(caso => caso.Motivo == this.motivoSelected);
        }
    }

    handleCalcular() {
        try {
            //const metricasArray = this.colunasMetricas.map(metrica => metrica.value);
            this.showTable = false;
            this.showSpinner = true;
            this.calcularMetricasResolutividade(this.agruparPorContractId(this.DataCase), this.colunasMetricas);
        } catch (error) {
            console.log('Erro ao processar os dados: ' + error.message);
        }
    }

    agruparPorContractId(dadosEntrada) {
        const casos = dadosEntrada;
        let casosMotivoContract = [];
    
        casos.forEach(caso => {
            // Encontrar ou criar objeto do motivo
            let motivoObj = casosMotivoContract.find(m => m.motivo === caso.Motivo);
    
            if (!motivoObj) {
                motivoObj = { motivo: caso.Motivo, contratos: [], submotivos: [], total: 0 };
                casosMotivoContract.push(motivoObj);
            }
    
            // Incrementar o total de casos do motivo
            motivoObj.total += 1;
    
            // Encontrar ou criar objeto do contrato dentro do motivo
            let contratoObj = motivoObj.contratos.find(c => c.contrato === caso.ContractId);
    
            if (!contratoObj) {
                contratoObj = { contrato: caso.ContractId, casos: [], total: 0 };
                motivoObj.contratos.push(contratoObj);
            }
    
            // Incrementar o total de casos do contrato
            contratoObj.total += 1;
            contratoObj.casos.push(caso);
    
            // Encontrar ou criar objeto do submotivo dentro do motivo
            let submotivoObj = motivoObj.submotivos.find(s => s.Submotivo === caso.Submotivo);
    
            if (!submotivoObj) {
                submotivoObj = { Submotivo: caso.Submotivo, contratos: [], total: 0 };
                motivoObj.submotivos.push(submotivoObj);
            }

            submotivoObj.total += 1;
    
            // Encontrar ou criar objeto do contrato dentro do submotivo
            let subContratoObj = submotivoObj.contratos.find(c => c.contrato === caso.ContractId);
    
            if (!subContratoObj) {
                subContratoObj = { contrato: caso.ContractId, casos: [] };
                submotivoObj.contratos.push(subContratoObj);
            }
    
            // Adicionar caso ao contrato dentro do submotivo
            subContratoObj.casos.push(caso);
        });
    
        this.casesByContract = casosMotivoContract;
        // console.log('casos motivo -> ' + JSON.stringify(casosMotivoContract));
        return casosMotivoContract;
    }

    calcularMetricasResolutividade(dadosAgrupados, colunasMetricas) {
        // Ordena as colunas de métricas
        colunasMetricas.sort((a, b) => a.value - b.value);
    
        let resultado = [];
        let totalCasosGlobal = 0;
        let metricasGlobal = colunasMetricas.map(metrica => ({
            metrica: `D${metrica.value}`,
            id: `Tot${metrica.value}`,
            value: 0,
            classToAdd: `total`
        }));
    
        dadosAgrupados.forEach(motivoObj => {
            let motivo = motivoObj.motivo;
            let totalCasos = motivoObj.contratos.length;
    
            let metricasResult = colunasMetricas.map(metrica => ({
                metrica: `D${metrica.value}`,
                id: `${motivo.substring(0, 3)}${metrica.value}`,
                value: 0
            }));
    
            totalCasosGlobal += totalCasos;
            console.log('total casos global => ' + totalCasosGlobal);
            console.log('total casos => ' + totalCasos);
    
            motivoObj.contratos.forEach(contratoObj => {
                let casos = contratoObj.casos.filter(caso => caso.CreatedDate !== undefined);
                let diffInDays = 0;
    
                if (casos.length > 1) {
                    casos.sort((a, b) => new Date(a.CreatedDate) - new Date(b.CreatedDate));
                    diffInDays = parseInt((new Date(casos[casos.length - 1].CreatedDate) - new Date(casos[0].CreatedDate)) / (1000 * 60 * 60 * 24));
                } else {
                    diffInDays = 1;
                }
    
                let metrica = this.findClosestMetrica(colunasMetricas, diffInDays);
    
                let metricaObjeto = metricasResult.find(m => m.metrica === `D${metrica}`);
    
                if (metricaObjeto) {
                    metricaObjeto.value += 1;
                    metricasGlobal.find(m => m.metrica === `D${metrica}`).value += 1;
                }
            });
    
            metricasResult.forEach(metricaResult => {
                metricaResult.value = totalCasos > 0 ? (metricaResult.value / totalCasos) * 100 : 0;
                metricaResult.value = metricaResult.value.toFixed(1);  // Aqui formatamos o valor para uma casa decimal
            });
    
            resultado.push({
                motivo: motivo,
                metricas: metricasResult
            });
        });
    
        metricasGlobal.forEach(metrica => {
            metrica.value = totalCasosGlobal > 0 ? (metrica.value / totalCasosGlobal) * 100 : 0;
            metrica.value = metrica.value.toFixed(1);  // Aqui formatamos o valor para uma casa decimal
        });
    
        resultado.unshift({
            motivo: 'Total',
            metricas: metricasGlobal,
            classToAdd: 'total'
        });
    
        this.rowsMetricas = resultado;
        this.showTable = true;
        this.showSpinner = false;
        this.showGrafico = true;
    
        return resultado;
    }
    

    calcularMetricasResolutividadePorMotivo(dadosAgrupados, colunasMetricas, motivo) {
        // Filtrar os dados agrupados para obter apenas o motivo especificado
        let dadosFiltrados = dadosAgrupados.find(motivoObj => motivoObj.motivo === motivo);
        if (!dadosFiltrados) {
            console.log(`Submotivo ${motivo} não encontrado nos dados agrupados.`);
            return [];
        }
    
        // Ordenar as colunas de métricas pelo valor
        colunasMetricas.sort((a, b) => a.value - b.value);
    
        let resultado = [];
        let totalCasosGlobal = 0;
        let metricasGlobal = colunasMetricas.map(metrica => ({
            metrica: `D${metrica.value}`,
            id: `Tot${metrica.value}`,
            value: 0,
            classToAdd: `total`
        }));
    
        // Iterar sobre cada submotivo do motivo especificado
        dadosFiltrados.submotivos.forEach(submotivoObj => {
            let submotivo = submotivoObj.Submotivo;
            let totalCasos = submotivoObj.contratos.length;
            totalCasosGlobal += totalCasos;
    
            let metricasResult = colunasMetricas.map(metrica => ({
                metrica: `D${metrica.value}`,
                id: `${submotivo.substring(0, 3)}${metrica.value}`,
                value: 0
            }));
    
            submotivoObj.contratos.forEach(contratoObj => {
                let casos = contratoObj.casos.filter(caso => caso.CreatedDate !== undefined);
                let diffInDays = 0;
    
                if (casos.length > 1) {
                    casos.sort((a, b) => new Date(a.CreatedDate) - new Date(b.CreatedDate));
                    diffInDays = parseInt((new Date(casos[casos.length - 1].CreatedDate) - new Date(casos[0].CreatedDate)) / (1000 * 60 * 60 * 24));
                } else {
                    diffInDays = 1;
                }
    
                let metrica = this.findClosestMetrica(colunasMetricas, diffInDays);
    
                let metricaObjeto = metricasResult.find(m => m.metrica === `D${metrica}`);
    
                if (metricaObjeto) {
                    metricaObjeto.value += 1;
                    metricasGlobal.find(m => m.metrica === `D${metrica}`).value += 1;
                }
            });
    
            // Calcular percentual das métricas para o submotivo atual
            metricasResult.forEach(metricaResult => {
                metricaResult.value = totalCasos > 0 ? (metricaResult.value / totalCasos) * 100 : 0;
                metricaResult.value = metricaResult.value.toFixed(1);  // Aqui formatamos o valor para uma casa decimal
            });
    
            resultado.push({
                submotivo: submotivo,
                metricas: metricasResult
            });
        });
    
        // Calcular percentual das métricas globais
        metricasGlobal.forEach(metrica => {
            metrica.value = totalCasosGlobal > 0 ? (metrica.value / totalCasosGlobal) * 100 : 0;
            metrica.value = metrica.value.toFixed(1);  // Aqui formatamos o valor para uma casa decimal
        });
    
        this.rowsMetricasSubmotivos = resultado;
        this.showTable = true;
        this.showSpinner = false;
    
        return resultado;
    }

    findClosestMetrica(metricas, diffInDays) {
        console.log('metricas -> ' + JSON.stringify(metricas));
        if (!metricas) {
            metricas = this.colunasMetricas;
        }
    
        let closestMetrica = null;
    
        if (metricas.length == 0) {
            return 1;
        }
    
        metricas.forEach(metrica => {
            let mValue = metrica.value;
            if (diffInDays == 0 || diffInDays == 1) {
                closestMetrica = 1;
            } else if (mValue >= diffInDays) {
                if (closestMetrica == null || mValue < closestMetrica) {
                    closestMetrica = mValue;
                }
            }
        });
    
        return closestMetrica != null ? closestMetrica : metricas[metricas.length - 1].value;
    }

    diferencaDias(data1, data2) {
        const umDia = 24 * 60 * 60 * 1000; // Milissegundos em um dia
        const primeiraData = new Date(data1);
        const segundaData = new Date(data2);
        return Math.round(Math.abs((primeiraData - segundaData) / umDia));
    }

    getFieldValue(item, fieldName) {
        return item[fieldName];
    }

    handleAddMetrica(event){
        
        const metricaNumber = parseInt(this.newColumnValue, 10);
        //const metricaInput = this.template.querySelector('lightning-input[data-id="metricaInput"]');
        const errorMessageDiv = this.template.querySelector('.error-message');
        errorMessageDiv.textContent = '';
        console.log('this.metricaExists(metricaNumber)',this.metricaExists(metricaNumber));
        

        if(metricaNumber > 30 || metricaNumber < 1 || this.metricaExists(metricaNumber)|| isNaN(metricaNumber)){
            if (metricaNumber > 30) {
                //metricaInput.setCustomValidity('A métrica não pode ser maior que 30.');
                errorMessageDiv.textContent = 'A métrica não pode ser maior que 30.';
            } else if(metricaNumber < 1){
                errorMessageDiv.textContent = 'A métrica não pode ser menor que 1';
            } else if (this.metricaExists(metricaNumber)){
                //metricaInput.setCustomValidity('A métrica já existe.');
                errorMessageDiv.textContent = 'A métrica já existe.';
            } else {
                //metricaInput.setCustomValidity('Número da métrica deve ser informado.');
                errorMessageDiv.textContent = 'Número da métrica deve ser informado.';
            }
            this.newColumnValue = '';
            return;
        }

        // if(metricaNumber <= 30 && metricaNumber > 0 && !this.metricaExists(metricaNumber)){
            // this.showTable = false;
            // this.showGrafico = false;
            const newColumn = { name: 'D+' + metricaNumber, id: 'D' + metricaNumber, value: metricaNumber, classToAdd: 'nova-coluna-header'};
             // Adicionando uma classe à nova coluna
             console.log("newColumn", JSON.stringify(newColumn));
             console.log("colunasMetricas", JSON.stringify(this.colunasMetricas));
            // newColumn.classToAdd = 'new-column';

            this.colunasMetricas.push(newColumn);

            // ordenar
            this.colunasMetricas.sort((a, b) => a.value - b.value);

            // limpar erros
            //metricaInput.setCustomValidity('');
            errorMessageDiv.textContent = '';

            // recalcular métricas
            let atMist = this.atendimentoValue == 'Misto';
            this.template.querySelector("c-every_-grafico-evolucao-resolutividade").recalculateMetrics(this.colunasMetricas, atMist);
            
            this.calcularMetricasResolutividade(this.agruparPorContractId(this.DataCase), this.colunasMetricas);
            this.rowsMetricasSubmotivos = this.calcularMetricasResolutividadePorMotivo(this.agruparPorContractId(this.DataCase), this.colunasMetricas, this.motivoSelected);
            this.handleUpdateExportData();
            this.newColumnValue = '';
        // } 

        // this.showTable = true;
        

    }


    handleNewColumnValue(event){
        this.newColumnValue = event.target.value;

        const metricaInput = this.template.querySelector('lightning-input[data-id="metricaInput"]');

        if(event.target.value > 30){
            //metricaInput.setCustomValidity('A métrica não pode ser maior que 30');
        }

        if(this.metricaExists(this.newColumnValue)){
            //metricaInput.setCustomValidity('A métrica já existe');
        } else {
            //metricaInput.setCustomValidity('');
        }
    }

    metricaExists(metricaNumber) {
        const nomeProcurado = 'D+' + metricaNumber;
        console.log("nomeProcurado",nomeProcurado);
        
        return this.colunasMetricas.some(item => item.name === nomeProcurado);
    }

    // handleInputDate(event) {
    //     const field = event.target.dataset.id;
    //     const value = event.target.value;
    //     const errorMessageDiv = this.template.querySelector('.error-message-data');

    //     if (field === 'startDate') {
    //         this.startDate = value;

    //     } else if (field === 'endDate') {
    //         this.endDate = value;
    //     }

    //     if(this.startDate > this.endDate && this.endDate != '') {
    //         errorMessageDiv.textContent = 'A data de início deve ser menor que a data fim.';
    //     } else {
    //         errorMessageDiv.textContent = '';
    //         this.CallIntegrationGeral(this.startDate, this.endDate);
    //     }

    // }
    handleInputDate(event) {
        console.log("handleInputDate");
        const field = event.target.dataset.id;
        const value = event.target.value;
        // const errorMessageDiv = this.template.querySelector('.error-message-data');
        console.log("field", field);
        console.log("value", value);

        if (field === 'startDate') {
            this.startDate = value;

        } else if (field === 'endDate') {
            this.endDate = value;
        }
        this.validateDates();
        // if(this.startDate > this.endDate && this.endDate != '') {
        //     errorMessageDiv.textContent = 'A data de início deve ser menor que a data fim.';
        // } else {
        //     errorMessageDiv.textContent = '';
        //     this.CallIntegrationGeral(this.startDate, this.endDate);
        // }

    }

    validateDates() {
        console.log("validateDates");
        // const startDateElem = this.template.querySelector("[data-id='startDate']");
        // const endDateElem = this.template.querySelector("[data-id='endDate']");
        const startErrorElem = this.template.querySelector("[data-id='startError']");
        const endErrorElem = this.template.querySelector("[data-id='endError']");

        startErrorElem.textContent = '';
        endErrorElem.textContent = '';

        if (this.startDate && this.endDate) {
            console.log("entrou no IF");
            const startDate = new Date(this.startDate);
            const endDate = new Date(this.endDate);
            const diffTime = Math.abs(endDate - startDate);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            if (startDate > endDate) {
                startErrorElem.textContent = 'A data de início não pode ser maior que a data de fim.';
            } else if (diffDays > 31) {
                endErrorElem.textContent = 'O período não pode ser superior a 30 dias.';
            }else {
                console.log("startDate", startDate + endDate);
                startErrorElem.textContent = '';
                endErrorElem.textContent = '';
                this.CallIntegrationGeral(startDate, endDate);
            }
        }
    }

    filtrarAtendimento(atendimentoValue){
        console.log("filtrarAtendimento");
        //this.showSpinner = true;
        this.showTable = false;
        let atMist = false;
        if(atendimentoValue == "Misto"){
            this.DataCase = JSON.parse(JSON.stringify(this.fullCasesList));
            atMist = true;
        } else {
            // remover todos os casos cujo campo OwnerId comece com '00G', pois são casos de filas e não do atendimento
            this.DataCase = this.fullCasesList.filter(caso => !caso.OwnerId.startsWith('00G'));
        }

        this.handleCalcular();
        this.template.querySelector("c-every_-grafico-evolucao-resolutividade").recalculateMetrics(this.colunasMetricas, atMist);
        this.rowsMetricasSubmotivos = this.calcularMetricasResolutividadePorMotivo(this.agruparPorContractId(this.DataCase), this.colunasMetricas, this.motivoSelected);
        this.handleUpdateExportData();  
    }

    handleReset() {
        this.rowsMetricas = [];
        this.rowsMetricasSubmotivos = [];
        this.motivoSelected = '';
        this.atendimentoValue = "Misto";
        this.newColumnValue = {};
        this.showTable = false;
        this.showNewTable = false;
        this.DataCase = JSON.parse(JSON.stringify(this.fullCasesList));
        this.colunasMetricas = [{ name: 'D+1', id:'D1', value: 1}, { name: 'D+7', id: 'D7', value: 7}];
        // Remove a estilização 'selected' de todas as linhas da tabela
        const tableRows = this.template.querySelectorAll('.slds-table tbody tr');
        tableRows.forEach(row => {
            row.classList.remove('selected');
        });
        this.handleCalcular();
        this.template.querySelector("c-every_-grafico-evolucao-resolutividade").recalculateMetrics(this.colunasMetricas, true);
        this.rowsMetricasSubmotivos = this.calcularMetricasResolutividadePorMotivo(this.agruparPorContractId(this.DataCase), this.colunasMetricas, this.motivoSelected);         
        this.handleUpdateExportData();
    }


}
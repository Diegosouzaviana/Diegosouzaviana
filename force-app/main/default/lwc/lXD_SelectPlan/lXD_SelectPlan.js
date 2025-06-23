/*
    =================================================================
    CHANGE LOG  
    ---------------------------------------------------
    * 2023-01-18 - Wesley Prado - Fix: Remove omniNextStep when requiredplan is false 🐛.
    * 2023-01-18 - Wesley Prado - Refactor: Major component refactor ♻️.
    ---------------------------------------------------
    =================================================================
*/
import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import tmpl from './lXD_SelectPlan.html';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';


export default class LXD_SelectPlan extends OmniscriptBaseMixin(LightningElement) {
    _ns = getNamespaceDotNotation();

    @api isTest = false;
    @api defaultProductImage = '/resource/backgroundProduct';
    @api requiredplan = false;
    @api validatestock = false;
    @api userprofile;
    @api steperrormessage = 'Deve escolher um produto para continuar.';
    @api customlabels = {
        RecurringPrice: "valor mensal",
        ListPrice: "valor mensal",
    }
    @api cartid;
    @api indexClick = -1;
    @api selectmultiple = false;
    @api crm;
    @track _products = [];
    @track dadoparametro;
    @track showButonTodos = true;
    @track showButonMesmo = false;
    @track exibeMuitosDados = 'fixed-bottom-button';

    get selectMultipleEnabled() {
        return this.selectmultiple.toString().toLocaleLowerCase() === 'false'
    }
    @api
    get productList() {
        return Array.isArray(this._products) ? this._products : [];
    }
    set productList(value) {
        this._products = this.productNormalizer(value);
    }
    showValidation;
    showSpinner = false;
    showError = false;
    cart = null;

    connectedCallback() {
        this.dadoparametro = this.omniJsonData?.dadoparametrojson;
        // console.log("productList", JSON.stringify(this.productList));
        // console.log("dadoparametro", JSON.stringify(this.dadoparametro));
        if (this._products.length == 0) {
            this.exibeMuitosDados = 'fixed-bottom-button-sem-dado';
        }
        if (this._products.length > 0) {
            this._products = this._products.map(plano => {
                return {
                    ...plano,
                    lwctipodeplano: 'mesmoplano'
                };
            });
        }
    }
    handleGetPlano(event) {
        const buttonId = event.currentTarget.dataset.id;
        if (buttonId === 'mesma-categoria') {
            this.enableLoading();
            this.showButonMesmo = false;
            this.showButonTodos = true;
            const tipodeplano = "mesmoplano";
            const input = {
                "seller_id": "7540",
                "minDownloadSpeed": "1",
                "migrated_provider": false,
                "maxDownloadSpeed": "1000000",
                "loyalty_contract": false,
                "city": this.dadoparametro.city,
                "category": this.dadoparametro.category,
                "PlanoAntigoId": this.dadoparametro.PlanoAntigoId,
                "currentPlan": this.dadoparametro.currentPlan,
                "retentionPlan": this.dadoparametro.retentionPlan,
                "sameCategory": true
            };
            this.handleCatalogOffers(input, tipodeplano);
        } else if (buttonId === 'outro-planos') {
            this.enableLoading();
            this.showButonMesmo = true;
            this.showButonTodos = false;
            const tipodeplano = "outroplano";
            const input = {
                "seller_id": "7540",
                "minDownloadSpeed": "1",
                "migrated_provider": false,
                "maxDownloadSpeed": "1000000",
                "loyalty_contract": false,
                "city": this.dadoparametro.city,
                "category": this.dadoparametro.category,
                "PlanoAntigoId": this.dadoparametro.PlanoAntigoId,
                "currentPlan": this.dadoparametro.currentPlan,
                "retentionPlan": this.dadoparametro.retentionPlan,
                "sameCategory": false
            };
            this.handleCatalogOffers(input, tipodeplano);
        }
    }

    handleCatalogOffers(input, tipodeplano) {
        console.log('input', JSON.stringify(input));
        const params = {
            input: JSON.stringify(input),
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'Every_IPCatalogOffers',
            options: '{}',
        };
        this.omniRemoteCall(params, false).then(response => {
            // console.log('response', JSON.stringify(response));
            this.disableLoading();

            if (response?.result?.IPResult?.productList?.length > 0) {
                // console.log('entrou ak 1');
                this.exibeMuitosDados = 'fixed-bottom-button';
                this.productList = response.result.IPResult.productList.map(plano => {
                    return {
                        ...plano,
                        lwctipodeplano: tipodeplano
                    };
                });
                console.log("this._products", JSON.stringify(this.productList));
                // this._products = response.result.IPResult.productList;

            } else {
                if (response?.result?.IPResult?.plans == 0) {
                    // console.log('entrou ak 2');
                    this.exibeMuitosDados = 'fixed-bottom-button-sem-dado';
                    this._products = [];
                    // console.log("_products", JSON.stringify(this._products));
                    const resultsToast = new ShowToastEvent({
                        variant: "warning",
                        message: "Nenhum plano semelhante disponível no momento. Clique em 'Outros planos' para ver mais opções.",
                        title: "Planos indisponíveis"
                    });
                    this.dispatchEvent(resultsToast);
                } else {
                    // console.log('entrou ak 3');
                    this.exibeMuitosDados = 'fixed-bottom-button-sem-dado';
                    this._products = [];
                    const resultsToast = new ShowToastEvent({
                        variant: "error",
                        message: "Erro interno de servidor, abra um chamado GLPI",
                        title: "Erro em busca planos"
                    });
                    this.dispatchEvent(resultsToast);
                }
            }


        }).catch(error => {
            console.error(error)
        });
    }

    @api
    checkValidity() {
        console.log(this.crm);
        if (this.requiredplan.toString().toLowerCase() === 'true') {
            for (let i = 0; i < this.productList.length; i++) {
                if (this.productList[i].selected && this.productList[i].orderItem != null) {
                    this.omniNextStep()
                    return true;
                }
            }
            return false;
        }

        return true;
    }

    handleClick(event) {
        this.enableLoading();

        this.showError = false;
        this.indexClick = event.currentTarget.dataset.name;

        const product = this.productList[this.indexClick];

        const hasOrderItem = product.orderItem !== null;
        const isSelected = product.selected

        if (!hasOrderItem || !isSelected) {
            if (this.selectMultipleEnabled) this.deleteProductsFromOrder();

            if (this.validatestock && !this.isTest) {
                if (this.validateStockAction(product.ProductCode)) this.addProduct();
            }
            else this.addProduct();

            this.showValidation = false;

        } else this.deleteProduct(this.indexClick, true)

        this.disableLoading()
    }

    addProduct() {
        const selectProduct = (product, itemId) => {
            product.selected = true;
            product.orderItem = itemId;
        }


        const responseOS = {
            "selectedItem": this.productList[this.indexClick]
        };
        // console.log('selectedItem ' , JSON.stringify(this.productList));

        if (this.isTest) {
            console.log('%c addProduct -> isTest', 'background-color: #111; color: #bada55')
            selectProduct(this.productList[this.indexClick], `any_id_${Date.now()}`)
            this.omniApplyCallResp(responseOS);

            return;
        }

        const input = {
            "OrderId": this.cartid,
            "Items": [
                {
                    "itemId": this.productList[this.indexClick].PricebookEntryId,
                    "itemName": this.productList[this.indexClick].name,
                    "itemCompleto": this.productList[this.indexClick]
                }
            ]
        };
        console.log('input itemId ', stringify(this.productList[this.indexClick].PricebookEntryId));
        const params = {
            input: JSON.stringify(input),
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'DeskDigital_PostCartsItems',
            options: '{}',
        };


        this.omniRemoteCall(params, false).then(response => {
            if (response?.result?.IPResult?.totalSize > 0) {
                selectProduct(this.productList[this.indexClick], response.result.IPResult.itemId)
                this.omniApplyCallResp(responseOS);

            } else {
                const resultsToast = new ShowToastEvent({
                    variant: "error",
                    message: "Não foi possível adicionar o produto.",
                });
                this.dispatchEvent(resultsToast);
            }


        }).catch(error => {
            console.error(error)
        });
    }

    cancelProduct(event) {
        this.deleteProduct(event.detail, true);
    }

    deleteProduct(index, desactivarSpinner) {
        this.enableLoading();

        const deselectProduct = (product) => {
            product.selected = false;
            product.orderItem = null;
        }

        if (this.isTest) {
            deselectProduct(this.productList[index])
            this.omniApplyCallResp({
                selectedItem: null
            });
            if (desactivarSpinner) this.disableLoading();

            return;
        }

        const input = {
            OrderItemId: this.productList[index].orderItem,
            OrderId: this.cartid
        };

        const params = {
            input: JSON.stringify(input),
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'DeskDigital_DeleteCartItems',
            options: '{}',
        };

        this.omniRemoteCall(params, false).then(response => {
            if (response?.result?.IPResult?.DeleteCartItemsStatus) {
                deselectProduct(this.productList[index])
            } else {
                const resultsToast = new ShowToastEvent({
                    variant: "error",
                    message: "Não foi possível remover o produto.",
                });
                this.dispatchEvent(resultsToast);
            }
        }).catch(error => {
            console.error(error)
        });

        if (desactivarSpinner) this.disableLoading();
    }

    /* addProduct */
    deleteProductsFromOrder() {
        this.productList.forEach((product, index) => {
            if (product.selected) this.deleteProduct(index, false);
        })
    }

    /* HELPERS */
    enableLoading() {
        this.showSpinner = true;
    }
    disableLoading() {
        this.showSpinner = false;
    }

    formatCurrencyToBRL(number = '') {
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(number);
    }

    getFloatFromText(text = '') {
        const regex = new RegExp('([0-9.,]+)')
        if (regex.test(text)) return text.match(regex)[0];

        return null;
    }

    productNormalizer(value) {
        const normalizedList = [];

        if (Array.isArray(value)) {
            value.forEach(product => {
                if (typeof product === 'object') {
                    const recurringPrice = this.formatCurrencyToBRL(this.getFloatFromText(product.RecurringPrice))
                    const listPrice = this.formatCurrencyToBRL(this.getFloatFromText(product.RecurringPrice))

                    normalizedList.push({
                        ...product,
                        RecurringPrice: recurringPrice,
                        ListPrice: listPrice,
                        selected: false
                    })
                };
            });
        }

        return normalizedList;
    }

    render() {
        return tmpl;
    }
    nextButton() {
        this.omniNextStep();
    }
    // scrollToBottom() {
    //     // Seleciona o elemento com ID 'scrollContainer'
    //     // const container = this.template.querySelector('.bottom');
    //     // if (container) {
    //     //     // Rola para o final do conteúdo
    //     //     console.log('scrolling to bottom...');
    //     //     container.scrollTo({
    //     //         top: container.scrollHeight,
    //     //         behavior: 'smooth'
    //     //     });
    //     // } else {
    //     //     console.error('Elemento com ID #scrollContainer não encontrado.');
    //     // }
    // }
}
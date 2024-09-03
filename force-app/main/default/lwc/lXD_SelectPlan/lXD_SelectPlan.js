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
   

    get selectMultipleEnabled(){
        return this.selectmultiple.toString().toLocaleLowerCase() === 'false'
    }

    @api
    get productList(){
        return Array.isArray(this._products) ? this._products : [];
    }
    set productList(value){
        this._products = this.productNormalizer(value);
    }    
    showValidation;
    
    showSpinner = false;
    showError = false;
    cart = null;
    
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

            if (this.validatestock && !this.isTest){
                if(this.validateStockAction(product.ProductCode)) this.addProduct();
            }
            else this.addProduct();

            this.showValidation = false;

        } else  this.deleteProduct(this.indexClick, true)

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
        console.log('selectedItem ' , JSON.stringify(this.productList));

        if(this.isTest){
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
        console.log('input itemId ' , stringify(this.productList[this.indexClick].PricebookEntryId));
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

        const deselectProduct = (product) =>{
            product.selected = false;
            product.orderItem = null;
        }

        if(this.isTest){
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
    deleteProductsFromOrder(){
        this.productList.forEach((product, index)=>{
            if(product.selected) this.deleteProduct(index, false);
        })
    }

    /* HELPERS */
    enableLoading(){
        this.showSpinner = true;
    }
    disableLoading(){
        this.showSpinner = false;
    }
    
    formatCurrencyToBRL(number = ''){
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(number);
    }
    
    getFloatFromText(text = ''){
        const regex = new RegExp('([0-9.,]+)')
        if(regex.test(text)) return text.match(regex)[0];
        
        return null;
    }

    productNormalizer(value){
        const normalizedList = [];
        
        if(Array.isArray(value)){
            value.forEach(product => {
                if(typeof product === 'object'){
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
}
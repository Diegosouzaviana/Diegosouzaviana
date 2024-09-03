import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
import { getNamespaceDotNotation } from "vlocity_cmt/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "vlocity_cmt/omniscriptActionUtils";

export default class LXD_ConnectionStatus extends FlexCardMixin(LightningElement) {
  //extends OmniscriptBaseMixin(LightningElement) {

  _actionUtil;
  _ns = getNamespaceDotNotation();
  messagesResyncOnu = [
    "Resync ONU efetuado com sucesso.",
    "Resync ONU não foi realizado. Erro ao encontrar as informações do cliente, verifique os dados e tente novamente.",
    "Resync ONU não foi realizado. ONU não provisionada.",
    "Resync ONU não foi realizado. Erro de comunicação, verifique as informações e tente novamente.",
  ];
  messagesResyncDevice = [
    "Resync Device efetuado com sucesso.",
    "Resync Device não foi realizado. Erro ao encontrar as informações do cliente, verifique os dados e tente novamente.",
    "Resync Device não foi realizado. Dispositivo não provisionado no ACS.",
    "Resync Device não foi realizado. Erro de comunicação, verifique as informações e tente novamente.",
  ];
  messagesResetONU = [
    "Reset ONU efetuado com sucesso.",
    "Reset ONU não foi realizado. Pedido inválido, verifique os dados e tente novamente.",
    "Reset ONU não foi realizado. Dispositivo não provisionado no ACS.",
    "Reset ONU não foi realizado. Erro de comunicação, verifique as informações e tente novamente.",
  ];

  @api input;
  @api inputAssetId;
  //Static resources
  resources = {
    statusAtivo:
      "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/STATUS@2x.jpg",
    trafegoAtivo:
      "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/TRAFEGO@2x.png",
    conexoesAtivo:
      "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/CONEXOES.png",
    gponAtivo: "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/GPON.png",
    bridgersAtivo:
      "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/BRIDGERS.png",
    consumoAtivo:
      "/resource/icon_sideBar/icon/StatusConexao/ACTIVOS/CONSUMO.png",
    statusDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/STATUS@2x.jpg",
    trafegoDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/TRAFEGO@2x.png",
    conexoesDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/CONEXOES.png",
    gponDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/GPON.png",
    bridgersDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/BRIDGERS.png",
    consumoDesativo:
      "/resource/icon_sideBar/icon/StatusConexao/DESACTIVADO/CONSUMO.png",
    reset:
      "/resource/icon_sideBar/icon/StatusConexao/BOTONESACCIONES/RESET.png",
    resetOnu:
      "/resource/icon_sideBar/icon/StatusConexao/BOTONESACCIONES/RESETONU.png",
    caixaActivo:
      "/resource/1663183427000/icon_sideBar/icon/CAIXA.png",
    caixaDesactivo:
      "/resource/1663183427000/icon_sideBar/icon/CAIXA.png",
    ultimoslogsActivo:
    "/resource/BridgeIcon/BridgeIcon/utility/apex_120.png",
    ultimoslogsDesactivo:
    "/resource/BridgeIcon/utility/apex_120.png",
  };

  //tab control
  @track tabs;
  @track icons;

  //Status Tab
  @track routerList = [];
  @track onuList = [];
  @api tipoBridge;
  showItem = false;
  loadOnu;
  loadRouter;
  showSpinner = false;
  errorGeral = false;
  items;
  errorcampobrigatorio = false;
  erroAtivoContrato = false;
  mensageErrorGeral = "";
  //Mocks
  onuMock = [
    {
      type: "Success",
      message: "Sinal de ONU dentro do range permitido.",
      icon: "utility:success",
      class: "slds-box slds-box_x-small box-success",
    },
    {
      type: "Success",
      message: "Sinal na OLT dentro do range permitido.",
      icon: "utility:success",
      class: "slds-box slds-box_x-small box-success",
    },
    {
      type: "Success",
      message: "Estado do OMCI da ONU: 'Ativo'.",
      icon: "utility:success",
      class: "slds-box slds-box_x-small box-success",
    },
    {
      type: "Success",
      message: "Nenhum alarme na ONU.",
      icon: "utility:success",
      class: "slds-box slds-box_x-small box-success",
    },
    {
      type: "Success",
      message: "MAC esta associados na bridge de dados.",
      icon: "utility:success",
      class: "slds-box slds-box_x-small box-success",
    },
  ];
  routerMock = [
    {
      type: "error",
      message: "Roteador não esta sincronizado ao ACS.",
      icon: "utility:close",
      class: "slds-box slds-box_x-small box-error",
    },
  ];

  connectedCallback() {
    this.setTabs();
    this._actionUtil = new OmniscriptActionCommonUtil();
    //console.log('this input', JSON.stringify(this.input));
    if (this.input.Case.AssetId == null || this.input.Case.Contrato__c == null) {
      this.erroAtivoContrato = true;
      this.erroAtivo = this.input.Case.AssetId == null ? true : false;
      this.erroContrato = this.input.Case.Contrato__c == null ? true : false;
      console.log("erroAtivo",this.erroAtivo);
      console.log("erroContrato",this.erroContrato);
      return;
    }
    this.CallIntegrationGeral(this.input.Case.AssetId);
  }

  setTabs() {
    this.icons = {
      ativo: {
        status: this.resources.statusAtivo,
        trafego: this.resources.trafegoAtivo,
        conexoes: this.resources.conexoesAtivo,
        gpon: this.resources.gponAtivo,
        bridger: this.resources.bridgersAtivo,
        consumo: this.resources.consumoAtivo,
        caixa: this.resources.caixaActivo,
        ultimoslogs: this.resources.ultimoslogsActivo,
      },
      desativo: {
        status: this.resources.statusDesativo,
        trafego: this.resources.trafegoDesativo,
        conexoes: this.resources.conexoesDesativo,
        gpon: this.resources.gponDesativo,
        bridger: this.resources.bridgersDesativo,
        consumo: this.resources.consumoDesativo,
        caixa: this.resources.caixaDesactivo,
        ultimoslogs: this.resources.ultimoslogsDesactivo,
      },
    };

    //default tabs
    this.tabs = {
      status: this.icons.ativo.status,
      trafego: this.icons.desativo.trafego,
      conexoes: this.icons.desativo.conexoes,
      gpon: this.icons.desativo.gpon,
      bridger: this.icons.desativo.bridger,
      consumo: this.icons.desativo.consumo,
      caixa: this.icons.desativo.caixa,
      ultimoslogs: this.icons.desativo.ultimoslogs,      
    };
  }

  handleTabs(event) {
    let previousTab = this.template.querySelector(".slds-is-active");

    //change icon
    this.tabs[previousTab.firstElementChild.dataset.tab] =
      this.icons.desativo[previousTab.firstElementChild.dataset.tab];
    this.tabs[event.currentTarget.dataset.tab] =
      this.icons.ativo[event.currentTarget.dataset.tab];

    //previous tab
    previousTab.classList.remove("slds-is-active");
    let previousTabContent = this.template.querySelector(".slds-show");
    previousTabContent.classList.replace("slds-show", "slds-hide");

    //new tab
    let newTab = event.currentTarget.closest("li");
    newTab.className = "tab-size slds-tabs_default__item slds-is-active";

    let newTabContent = this.template.querySelectorAll(".slds-hide");
    for (const iterator of newTabContent) {
      // ESTA CERTO 3 === NO IF ABAIXO???
      if (iterator.dataset.content === event.currentTarget.dataset.tab) {
        iterator.classList.replace("slds-hide", "slds-show");
        break;
      }
    }
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: this._title,
      message: this.message,
      variant: this.variant,
    });
    this.dispatchEvent(evt);
  }

//  NÃO FOI ALTERADA PARA ASSETID POIS MIGROU A CHAMADA PARA DENTRO DO FLEXCARD
  handlerResyncOnu() {
    this.showSpinner = true;
    this.CallIntegration(
      this.input.Case.Contrato__c,
      "resyncONU",
      this.messagesResyncOnu
    );
  }

  handlerResyncDevice() {
    this.showSpinner = true;
    this.CallIntegration(
      this.input.Case.Contrato__c,
      "resyncDevice",
      this.messagesResyncDevice
    );
  }

  handlerResetONU() {
    this.showSpinner = true;
    this.CallIntegration(
      this.input.Case.Contrato__c,
      "resetONU",
      this.messagesResetONU
    );
  }

//  NÃO FOI ALTERADA PARA ASSETID POIS MIGROU A CHAMADA PARA DENTRO DO FLEXCARD
  CallIntegration(ContractId, integrationType, messageArray) {

    var titleTxt = "";
    var variantTxt = "";
    var messageNum = 0;

    const input = {
      contractId: ContractId,
      integrationType: integrationType,
    };

    const params = {
      input: JSON.stringify(input),
      sClassName: "IntegrationProcedureService",
      sMethodName: "LXD_ConnectionStatusResync",
      options: "{}",
    };

    this._actionUtil
      .executeAction(params, null, this, null, null)
      .then((response) => {
        console.log(
          "statusCode: " +
            JSON.stringify(response.result.IPResult.info.statusCode)
        );

        if (response?.result?.IPResult?.info.statusCode == 200) {
          titleTxt = "Sucesso";
          variantTxt = "success";
          messageNum = 0;
        } else if (response?.result?.IPResult?.info.statusCode == 400) {
          titleTxt = "Erro";
          variantTxt = "error";
          messageNum = 1;
        } else if (response?.result?.IPResult?.info.statusCode == 404) {
          titleTxt = "Erro";
          variantTxt = "error";
          messageNum = 2;
        } else {
          titleTxt = "Erro";
          variantTxt = "error";
          messageNum = 3;
        }
        this.showSpinner = false;
        const resultsToast = new ShowToastEvent({
          title: titleTxt,
          variant: variantTxt,
          message: messageArray[messageNum],
        });
        this.dispatchEvent(resultsToast);
      })
      .catch((error) => {
        console.error(error, "ERROR");
      });
  }

  CallIntegrationGeral(AssetId) {
    
    const input = {
      AssetId: AssetId
    };
        
    this.showSpinner = true;
    const params = {
      input: JSON.stringify(input),
      sClassName: "IntegrationProcedureService",
      sMethodName: "LXD_APIConnectionStatus",
      options: "{}",
    };

    this._actionUtil
    .executeAction(params, null, this, null, null)
      .then((response) => {
        // console.log("response", JSON.stringify(response));
        if (response?.result?.IPResult?.success == 200) {

          this.showSpinner = false;
          this.showItem = true;
          this.items = {
            plano_id: JSON.stringify(response.result.IPResult.adm.plano_id),
            pppoe_user: JSON.stringify(response.result.IPResult.adm.pppoe_user),
            ContractId: this.input.Case.Contrato__c,
            //AssetId: this.input.Case.AssetId,
            AssetId: AssetId,
            slot: JSON.stringify(response.result.IPResult.adm.slot),
            ip: JSON.stringify(response.result.IPResult.adm.ip),
            olt: JSON.stringify(response.result.IPResult.adm.olt),
            onu: JSON.stringify(response.result.IPResult.adm.onu),
            fsan: JSON.stringify(response.result.IPResult.adm.fsan),
            cto: JSON.stringify(response.result.IPResult.adm.cto),
          };
          // console.log('items contractId', this.items.ContractId);
          // console.log('items ', JSON.stringify(this.items));
          this.template
            .querySelector("c-cf-l-x-d_-Tabs-G-P-O-N-A-P-I")
            .callData(this.items);
          
        }else if (response?.result?.IPResult?.statusCode == 422){
          this.errorcampobrigatorio = true;
          this.showSpinner = false;
          this.mensageErrorGeral = "Dados inconsistentes para executar essa ação, abrir um chamado no GLPI.";
        }else if (response?.result?.IPResult?.success == 404){
          this.errorGeral = true;
          this.showSpinner = false;
          this.mensageErrorGeral = "Erro ao encontrar informações do cliente.";
        }else if (response?.result?.IPResult?.success == 500){
          this.errorGeral = true;
          this.showSpinner = false;
          this.mensageErrorGeral = "Algo ocorreu errado. Entre em contato com o administrador.";
        }
      })
      .catch((error) => {
        console.error(error, "ERROR");
      });
  }
  handleClose(){
    this.erroAtivoContrato = false;
    this.errorGeral = false;
  }

  handleTypeBridge(){
    this.tipoBridge = "dados";
    // console.log('tipo bridge&&&&&&&&& ',this.tipoBridge);
  }
}
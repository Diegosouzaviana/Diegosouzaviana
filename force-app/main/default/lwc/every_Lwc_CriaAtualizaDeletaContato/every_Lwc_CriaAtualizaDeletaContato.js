import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Every_Lwc_CriaAtualizaDeletaContato extends OmniscriptBaseMixin(LightningElement) {
    _actionUtilClass;
    _ns = getNamespaceDotNotation();
    _obj;
    @track phones = []; // Array para armazenar os telefones recebidos
    @track emails = []; // Variável para armazenar o e-mail recebido
    @track isPhoneLimitReached = false;
    @track contIndex = [];
    @track emailIndex = [];
    @track phoneIndexToDelete = ''; // Índice do telefone a ser deletado
    @track showModal = false; // Controla a exibição do modal
    @track showModal1 = false; // Controla a exibição do modal
    @track showModal2 = false; // Controla a exibição do modal
    @track showModal3 = false; // Controla a exibição do modal
    @track customerid;
    @track cpf;
    @track contactId;
    @track caseId;
    @track campoClasse = '';
    @track mostrarMensagem = false;
    @track mensagemClasse = '';
    QuantIndex = true;
    emailQuantIndex = true;
    beforeUpdateIndexes = [];
    Type;
    customerid;
    TipoFone;
    newPhoneNumber = '';
    oldPhoneNumber = '';
    mensagemPersonalizada = '';
    novoEmail;
    emailAtual;
    emailAntigo = '';
    errorMessage = 'Formato de e-mail inválido';
    items;
    isNew = false;
    newClass = '';
    isValidEmail;
    isNewOfClickedIndex;
    msg = '';
    emailvisivel = false;
    emailestilo = '';
    currentPhone;
    currentEmail;
    oldPhone;
    oldEmail;
    copiaOBJ;
    errormsg;
    // Inicialize um objeto para armazenar os telefones antigos
    oldPhoneNumbers = {};
    oldEmailNumbers = {};
    @track originalValues = {};
    @track emailErrors = {
        old_email1: '',
        old_email2: '',
        old_email3: '',
        old_email4: ''
    };
    @track emailvalidado = {
        old_email1: '',
        old_email2: '',
        old_email3: '',
        old_email4: ''
    };
    desabilitasbutton = true;
    hasChangesemail = true;
    @api
    get obj() {
        return this._obj;
    }
    set obj(value) {
        this._obj = value;
    }
    extrairCampos(obj) {
        return {
            omniPhones: [obj.old_telefone1, obj.old_telefone2, obj.old_telefone3, obj.old_telefone4, obj.old_telefone5],
            EmailContato: [obj.old_email1, obj.old_email2, obj.old_email3, obj.old_email4, obj.old_email5],
            customerid: obj.customerid,
            cpf: obj.cpf,
            contactId: obj.contactId,
            caseId: obj.caseId
        };
    };
    connectedCallback() {
        let omniData = this.extrairCampos(this.obj);
        this._actionUtilClass = new OmniscriptActionCommonUtil();
        this.phones = omniData.omniPhones.filter(phone => phone !== '');
        this.emails = omniData.EmailContato.filter(email => email !== '');
        this.customerid = omniData.customerid;
        this.caseId = omniData.caseId;
        this.copiaOBJ = { ...this.obj };

        // console.log("copiaOBJ", JSON.stringify(this.copiaOBJ));
        // console.log("OBJ", JSON.stringify(this.obj));

        // Adiciona ouvintes de evento após a renderização inicial
        const emailInput1 = this.template.querySelector('lightning-input[data-fieldname="old_email1"]');
        if (emailInput1) {
            emailInput1.addEventListener('change', event => this.handleEmailChange(event, 'old_email1'));
        }
        // this.emailIndex = this.emails.map((email, index) => ({
        //     index: index + 1,
        //     email: email,
        //     isNew: this.isNew,
        //     newClass: this.newClass,
        //     mostrarMensagem: this.mostrarMensagem,
        //     mensagemClasse: this.mensagemClasse,
        //     mensagemPersonalizada: this.mensagemPersonalizada
        // }));

        // console.log("emailIndex ", JSON.stringify(this.emailIndex));
        // if (this.emailIndex.length < 5) {
        //     this.emailQuantIndex = true;
        // }else{
        //     this.emailQuantIndex = false;
        // }

        this.contIndex = this.phones.map((phone, index) => ({
            index: index + 1,
            phone: phone,
            isNew: this.isNew, // Defina isNew como false para todos os telefones existentes inicialmente
            newClass: this.newClass,
            mostrarMensagem: this.mostrarMensagem,
            mensagemClasse: this.mensagemClasse,
            mensagemPersonalizada: this.mensagemPersonalizada
        }));
        if (this.contIndex.length < 5) {
            this.QuantIndex = true;
        } else {
            this.QuantIndex = false;
        }
    }
    handlePhoneChange(event) {
        console.log("handlePhoneChange ");
        const phoneIndex = event.target.dataset.index;
        const newPhone = event.target.value;
        // Armazena o novo telefone no estado do componente
        this.contIndex[phoneIndex - 1].phone = newPhone;
        // Armazena o telefone antigo no objeto usando o índice como chave
        this.oldPhone = this.phones[phoneIndex - 1];
        console.log("oldPhone: ", JSON.stringify(this.oldPhone));
        console.log("phones: ", JSON.stringify(this.phones));
        // Armazena o telefone atual
        this.currentPhone = this.phones[phoneIndex - 1];
        console.log("currentPhone: ", JSON.stringify(this.currentPhone));
        // Armazena o telefone antigo no objeto usando o índice como chave
        const oldPhone = this.phones[phoneIndex - 1];
        this.oldPhoneNumbers[phoneIndex] = {
            oldPhone: oldPhone,
            newPhone: newPhone
        };
        // Em algum ponto, você pode acessar tanto o telefone antigo quanto o telefone novo
        const telefones = this.oldPhoneNumbers[phoneIndex];
        const currentPhone = this.contIndex[phoneIndex - 1];
        if (telefones.oldPhone === undefined && telefones.newPhone !== "") { // Verifica se o telefone foi criado e teve valor enseriado
            console.log("entro no if 1");
            currentPhone.mensagemPersonalizada = "Clique em salvar para concluir o processo.";
            currentPhone.mostrarMensagem = true; // Exibe a mensagem
            currentPhone.mensagemClasse = "mensagem-alterada"; // Classe para estilização da mensagem
        } else if (telefones.oldPhone === undefined && telefones.newPhone === "") { // Verifica se o novo telefone foi criado e que o telefone esta em branco
            console.log("entro no if 2");
            currentPhone.mensagemPersonalizada = "";
            currentPhone.mostrarMensagem = false; // Exibe a mensagem
            currentPhone.mensagemClasse = ""; // Classe para estilização da mensagem
        } else if (telefones.oldPhone !== "" && telefones.newPhone !== telefones.oldPhone) { // Verifica se o valor foi alterado
            console.log("entro no if 3");
            currentPhone.mensagemPersonalizada = "Clique em salvar para concluir o processo.";
            currentPhone.mostrarMensagem = true; // Exibe a mensagem
            currentPhone.mensagemClasse = "mensagem-alterada"; // Classe para estilização da mensagem
        } else {
            console.log("entro no else");
            currentPhone.mensagemPersonalizada = "";
            // currentPhone.newClass = ""; // Remove a classe de estilização
            currentPhone.mostrarMensagem = false; // Esconde a mensagem
            currentPhone.mensagemClasse = "";
        }
    }
    handleEmailChange(event) {
        const FIELD_NAMES = ["old_email1", "old_email2", "old_email3", "old_email4"];
        const emailInput = event.target;
        const fieldValue = emailInput.value;
        const fieldName = emailInput.dataset.fieldname;
        console.log("fieldValue ", fieldValue);
        // Limpa mensagens de erro atuais
        FIELD_NAMES.forEach(name => this.clearError(name));
        const isValid = this.validateEmail(fieldValue);
        //salvo o valor true ou false da validação do email
        this.emailvalidado[fieldName] = isValid;
        //consulta se existe algum email no formato invalido
        const valoresConsultados = this.consultarValores();
        // Verifica se há e-mails repetidos no copiaOBJ
        const saoDiferentes = this.validarEmailsRepetidos(fieldValue);
        // Verifica se email e diferente do email de origem
        const checkForEmail = this.checkForEmailChanges(fieldName, fieldValue);
        // Atualiza os email novo valor apenas se for válido
        if(fieldValue == "" || fieldValue == null){
            console.log("entrou1");
            this.updateEmailInfo(fieldName, fieldValue, "", "", false);
        }
        else if (isValid && checkForEmail && !valoresConsultados) {
            console.log("entrou2");
            if (!saoDiferentes) {
                console.log("entrou3");
                this.updateEmailInfo(fieldName, fieldValue, "Clique em atualizar email para concluir o processo.", "mensagem-alterada", false);
            } else {
                console.log("entrou5");
                this.updateEmailInfo(fieldName, fieldValue, "Já existe um e-mail do mesmo tipo.", "mensagem-alterada", true);
            }
        } else if (!isValid && checkForEmail) {
            console.log("entrou6");
            this.updateEmailInfo(fieldName, fieldValue, "Por favor, insira um endereço de e-mail válido.", "mensagem-alterada", true);
        } else {
            console.log("entrou7");
            this.clearError(fieldName);
            this.copiaOBJ = { ...this.copiaOBJ, [fieldName]: fieldValue };
            this.desabilitasbutton = true;
        }
    }
    //atualiza o mssagem de erro dos email
    updateEmailInfo(fieldName, fieldValue, errorMessage, errorType, disableButton) {
        this.desabilitasbutton = disableButton;
        this.emailErrors[fieldName] = errorMessage;
        this.errormsg = errorType;
        this.copiaOBJ = { ...this.copiaOBJ, [fieldName]: fieldValue };
    }
    validarEmailsRepetidos(fieldValue) {
        const chaves = Object.keys(this.copiaOBJ)
        for (let i = 0; i < chaves.length; i++) {
            const chave = chaves[i];
            const valor = this.copiaOBJ[chave];
            // Verifica se o valor é uma string "false"
            if (valor == fieldValue) {
                return true; // Retorna true ao encontrar um valor "false"
            }
        }
        return false;
    }
    // Função para consultar e retornar os valores true/false
    consultarValores() {
        // Obtemos uma matriz das chaves do objeto
        const chaves = Object.keys(this.emailvalidado);
        // Iteramos sobre as chaves e verificamos se há algum valor "false"
        for (let i = 0; i < chaves.length; i++) {
            const chave = chaves[i];
            const valor = this.emailvalidado[chave];
            // Verifica se o valor é uma string "false"
            if (valor == "false") {
                return true; // Retorna true ao encontrar um valor "false"
            }
        }
        // Se nenhum valor "false" for encontrado, retorna false
        return false;
    }
    checkForEmailChanges(fieldName, fieldValue) {
        // Verifica se o campo de e-mail foi alterado em relação ao objeto original
        const hasChanged = this.obj[fieldName] !== fieldValue;
        // if (hasChanged) {
        //     console.log(`O campo ${fieldName} foi alterado? Sim`);
        // } else {
        //     console.log(`O campo ${fieldName} foi alterado? Não`);
        // }
        return hasChanged;
    }
    validateEmail(email) {
        // Validação de e-mail usando uma expressão regular
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

        // Retorna true se o e-mail for válido, false caso contrário
        return emailRegex.test(email);
    }
    clearError(fieldName) {
        // Limpa a mensagem de erro para o campo especificado
        this.emailErrors[fieldName] = '';
    }
    // verifica se os campos de email do obj origem são deferente do copiaOBJ para atualiza as menssagem updateEmailErrors
    getChangedEmailFields() {
        const changedEmailFields = [];
        const obj = this.obj;
        const copiaobj = this.copiaOBJ;
    
        for (const field in obj) {
            if (field.startsWith("old_email") && obj[field] !== copiaobj[field]) {
                changedEmailFields.push(field);
            }
        }
        return changedEmailFields;
    }
    //usando a resposta getChangedEmailFields atualiza a mensagem para sucesso nos campos de email
    updateEmailErrors(changedEmailFields) {
                
        changedEmailFields.forEach(fieldName => {
            const oldValue = this.obj[fieldName]; // Obtém o valor antigo do campo
            const newValue = this.copiaOBJ[fieldName]; // Obtém o novo valor do campo
            
            if (newValue !== "") {
                console.log("fieldName", fieldName);
                this.emailErrors[fieldName] = "O e-mail foi atualizado com sucesso.";
                this.errormsg = "mensagem-suseco";
            }else{
                console.log("fieldName2", fieldName);
                this.emailErrors[fieldName] = "O e-mail excluido com sucesso.";
                this.errormsg = "mensagem-alterada";
            }
        });
    }
    // handleEmailChange(event) {
    //     console.log("handleEmailChange ");
    //     const indexEmail = event.target.dataset.index;
    //     const novoEmail = event.target.value;
    //     console.log("indexEmail: ", indexEmail);
    //     console.log("novoEmail: ", novoEmail);
    //     // Armazena o novo telefone no estado do componente
    //     this.emailIndex[indexEmail - 1].email = novoEmail;
    //     // Armazena o telefone antigo no objeto usando o índice como chave
    //     this.oldEmail = this.emails[indexEmail - 1];
    //     console.log("oldEmail: ", JSON.stringify(this.oldEmail));
    //     console.log("emails: ", JSON.stringify(this.emails));
    //     // Armazena o telefone atual
    //     this.currentEmail = this.emails[indexEmail - 1];
    //     console.log("currentEmail: ", JSON.stringify(this.currentEmail));
    //     // Armazena o telefone antigo no objeto usando o índice como chave
    //     const oldEmail = this.emails[indexEmail - 1];
    //     console.log("oldEmail: ", oldEmail);
    //     this.oldEmailNumbers[indexEmail] = {
    //         oldEmail: oldEmail,
    //         novoEmail: novoEmail
    //     };
    //     console.log("oldEmailNumbers: ", JSON.stringify(this.oldEmailNumbers));
    //     const todosemail = this.oldEmailNumbers[indexEmail];
    //     const currentemail = this.emailIndex[indexEmail - 1];

    //     if (todosemail.oldEmail === undefined && todosemail.novoEmail !== "") { // Verifica se o telefone foi criado e teve valor enseriado
    //         console.log("entro no if 1");
    //         currentemail.mensagemPersonalizada = "Clique em Criar para concluir o processo.";
    //         currentemail.mostrarMensagem = true; // Exibe a mensagem
    //         currentemail.mensagemClasse = "mensagem-alterada"; // Classe para estilização da mensagem
    //     } else if (todosemail.oldEmail === undefined && todosemail.novoEmail === "") { // Verifica se o novo telefone foi criado e que o telefone esta em branco
    //         console.log("entro no if 2");
    //         currentemail.mensagemPersonalizada = "";
    //         currentemail.mostrarMensagem = false; // Exibe a mensagem
    //         currentemail.mensagemClasse = ""; // Classe para estilização da mensagem
    //     } else if (todosemail.oldEmail !== "" && todosemail.novoEmail !== todosemail.oldEmail) { // Verifica se o valor foi alterado
    //         console.log("entro no if 3");
    //         currentemail.mensagemPersonalizada = "Clique em salvar para concluir o processo.";
    //         currentemail.mostrarMensagem = true; // Exibe a mensagem
    //         currentemail.mensagemClasse = "mensagem-alterada"; // Classe para estilização da mensagem
    //     } else {
    //         console.log("entro no else");
    //         currentemail.mensagemPersonalizada = "";
    //         // currentPhone.newClass = ""; // Remove a classe de estilização
    //         currentemail.mostrarMensagem = false; // Esconde a mensagem
    //         currentemail.mensagemClasse = "";
    //     }

    //     // const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    //     // if (!regex.test(this.novoEmail)) {
    //     //     this.errorMessage = 'Formato de e-mail inválido';
    //     //     event.target.setCustomValidity(this.errorMessage);
    //     // } else {
    //     //     this.errorMessage = '';
    //     //     event.target.setCustomValidity('');
    //     // }
    //     // event.target.reportValidity();
    //     // console.log("handlePhoneChange-novoEmail " + this.novoEmail);
    //     // console.log("handlePhoneChange-Email " + this.email);

    //     // if (this.email !== this.novoEmail && this.email !== '') {
    //     //     // O e-mail foi alterado e é diferente do e-mail antigo
    //     //     this.msg = 'Clique em Salvar para concluir o processo.';
    //     //     this.emailvisivel = true;
    //     //     // this.emailestilo = 'mensagem-alterada'; // Substitua pela classe desejada
    //     //     this.emailestilo = 'mensagem-alterada'; // Substitua pela classe desejada
    //     // } else {
    //     //     // Não houve alteração ou é o primeiro valor inserido
    //     //     this.msg = '';
    //     //     this.emailvisivel = false;
    //     //     this.emailestilo = '';
    //     // }
    // }
    formatPhone(phoneNumber) {
        console.log("formatPhone ", +1);
        const cleaned = ('' + phoneNumber).replace(/\D/g, ''); // Remove caracteres não numéricos
        if (phoneNumber == null || phoneNumber == '') {
            return null;
        } else if (cleaned.length === 11) {
            // Formato para celular: (99) 9xxxx-xxxx
            return '(' + cleaned.substring(0, 2) + ')' + cleaned.substring(2, 7) + '-' + cleaned.substring(7);
        } else {
            // Formato para telefone fixo: (99) xxxx-xxxx
            return '(' + cleaned.substring(0, 2) + ')' + cleaned.substring(2, 6) + '-' + cleaned.substring(6);
        }
    }
    addPhone() {
        console.log("addPhone ");
        if (this.contIndex.length < 5) {
            // Adicione um novo objeto à lista com o índice correto e o telefone como uma string vazia
            this.contIndex.push({ index: this.contIndex.length + 1, phone: '', isNew: true, newClass: '', mostrarMensagem: false });
            if (this.contIndex.length == 5) {
                this.QuantIndex = false;
            }
            //console.log("addPhone contIndex: "+ JSON.stringify(this.contIndex));
        }
    }
    // addEmail() {
    //     console.log("addEmail ");
    //     if (this.emailIndex.length < 5) {
    //         // Adicione um novo objeto à lista com o índice correto e o telefone como uma string vazia
    //         this.emailIndex.push({ index: this.emailIndex.length + 1, phone: '', isNew: true, newClass: '', mostrarMensagem: false });
    //         if (this.emailIndex.length == 5) {
    //             this.emailQuantIndex = false;
    //         }
    //         //console.log("addPhone contIndex: "+ JSON.stringify(this.contIndex));
    //     }
    // }
    updateIndexes() {
        // Atualiza os índices após a exclusão de um elemento
        this.contIndex.forEach((item, index) => {
            item.index = index + 1;
        });
        this.QuantIndex = true;
    }
    // updateEmailIndexes() {
    //     // Atualiza os índices após a exclusão de um elemento
    //     this.emailIndex.forEach((item, index) => {
    //         item.index = index + 1;
    //     });
    //     this.emailQuantIndex = true;
    // }

    // validateEmail(email) {
    //     // const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    //     const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    //     if (!regex.test(email)) {
    //         this.errorMessage = 'Formato de e-mail inválido';
    //     } else {
    //         this.errorMessage = '';
    //     }
    //     return regex.test(email);
    // }
    confirmDelete(event) {
        console.log("confirmDelete ");
        const index = event.currentTarget.dataset.index;
        const phone = event.currentTarget.dataset.phone;
        // Formata o telefone
        //const formattedPhone = this.formatPhone(phone);
        console.log("beforeUpdateIndexes", this.beforeUpdateIndexes);
        console.log("index ", index);
        console.log("phone ", phone);
        let isNew = false;
        // Itera sobre o array contIndex
        this.contIndex.forEach(item => {
            // Use item.isNew dentro do loop
            isNew = item.isNew;
        });
        // Faça algo com isNew
        this.isNew = isNew;
        this.phoneIndexToDelete = index;
        this.oldPhoneNumber = phone;
        this.showModal = true;
    }
    confirmaAtualiza(event) {
        console.log("confirmaAtualiza ");
        const index = event.currentTarget.dataset.index;
        const Novophone = event.currentTarget.dataset.phone;
        const formattedPhone = this.formatPhone(Novophone);
        console.log("formattedPhone " + formattedPhone);

        const oldformattedPhone = this.formatPhone(this.oldPhone);
        console.log("Telefone antigo:", oldformattedPhone);

        if (formattedPhone.length === 14) {
            this.TipoFone = "celular";
        } else {
            this.TipoFone = "fone";
        }

        this.phoneIndexToDelete = index;
        this.newPhoneNumber = formattedPhone;
        this.oldPhoneNumber = oldformattedPhone;
        this.showModal1 = true;
    }
    confimarnovoPhone(event) {
        console.log("confimarnovoPhone ");
        const index = event.currentTarget.dataset.index;
        const phone = event.currentTarget.dataset.phone;
        console.log("phone " + phone);
        //formata o telefone
        //const formattedPhone = this.formatPhone(phone);

        this.newPhoneNumber = phone;
        this.phoneIndexToDelete = index;
        this.showModal2 = true;
    }
    confirmaAlteraEmail(event) {
        this.showModal3 = true;
    }
    // confirmaAlteraEmail(event) {
    //     console.log("confirmaAlteraEmail ");
    //     const novoEmail = event.currentTarget.dataset.email;
    //     const index = event.currentTarget.dataset.index;
    //     //validação do email
    //     const isValidEmail = this.validateEmail(novoEmail);
    //     console.log('isValidEmail: ' + isValidEmail);
    //     console.log("novoEmail " + novoEmail);
    //     console.log("index " + index);

    //     this.emailAtual = novoEmail;
    //     this.isValidEmail = isValidEmail;
    //     this.showModal3 = true;

    // }
    async updatePhone() {
        console.log("updatePhone ");
        let Type = "Altera";
        const phoneIndex = this.phoneIndexToDelete;
        let oldPhoneNumber = this.oldPhoneNumber;
        let newPhoneNumber = this.newPhoneNumber;
        const currentPhone = this.contIndex[phoneIndex - 1];
        // console.log("oldPhoneNumber: " + this.oldPhoneNumber);
        // console.log("newPhoneNumber: " + this.newPhoneNumber);
        if (newPhoneNumber != oldPhoneNumber && oldPhoneNumber != null) {
            // Realize ações adicionais aqui, se necessário
            // Por exemplo, chamar outra função ou atualizar variáveis
            console.log("Os números de telefone são diferentes!");
            await this.CallIntegrationGeral(this.caseId, Type, phoneIndex, oldPhoneNumber, newPhoneNumber, null)
                .then((data) => {
                    console.log("data " + JSON.stringify(data));
                    if (data?.result?.IPResult?.statuscode == 200) {
                        this.showModal1 = false; // Fecha o modal após a exclusão
                        this.mostrarToast(data.result.IPResult.message, 'success');
                        currentPhone.mensagemPersonalizada = "Telefone inserido com sucesso.";
                        currentPhone.mostrarMensagem = true; // Exibe a mensagem
                        currentPhone.mensagemClasse = "mensagem-suseco";
                    } else if (data?.result?.IPResult?.result?.statuscode == 400) {
                        this.showModal1 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 404) {
                        this.showModal1 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 409) {
                        this.showModal1 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal1 = false;
                        this.mostrarToast('O telefone não teve alteração', 'Error');
                    }
                }).catch((error) => {
                    // Trate erros aqui, se necessário
                    console.error(error);
                });
        } else {
            this.showModal1 = false;
            this.mostrarToast('Esse número de telefone já existe.', 'Error');
            console.log("Os números de telefone são iguais.");
        }

    }
    async deleteConfirmed() {
        console.log("deleteConfirmed ");
        let Type = "deleta";
        const phoneIndex = this.phoneIndexToDelete;
        let oldPhoneNumber = this.oldPhoneNumber;
        let isNewOf = this.isNew;
        console.log("oldPhoneNumber " + oldPhoneNumber);
        if (oldPhoneNumber == null) {
            console.log("entra 1 ");
            this.contIndex.splice(phoneIndex - 1, 1);
            this.showModal = false; // Fecha o modal após a exclusão
            this.updateIndexes();// Remove o elemento no índice fornecido
        } else if (oldPhoneNumber != null && isNewOf == true) {
            console.log("entra 2 ");
            this.contIndex.splice(phoneIndex - 1, 1);
            this.showModal = false; // Fecha o modal após a exclusão
            this.updateIndexes();// Remove o elemento no índice fornecido
        } else {
            console.log("entra 3");
            await this.CallIntegrationGeral(this.caseId, Type, phoneIndex, oldPhoneNumber, null, null)
                .then((data) => {
                    console.log("data " + JSON.stringify(data));
                    if (data?.result?.IPResult?.statuscode == 200) {
                        this.mostrarToast(data.result.IPResult.message, 'success');
                        this.contIndex.splice(phoneIndex - 1, 1);
                        this.showModal = false; // Fecha o modal após a exclusão
                        this.updateIndexes();// Remove o elemento no índice fornecido
                        // Suponha que você tenha o índice do telefone a ser removido
                        const phoneIndexToDelete = phoneIndex; // Substitua isso pelo seu índice real

                        // Certifique-se de que o índice está dentro dos limites da lista phones
                        if (phoneIndexToDelete > 0 && phoneIndexToDelete <= this.phones.length) {
                            // Remove o telefone no índice correspondente
                            const removedPhone = this.phones.splice(phoneIndexToDelete - 1, 1)[0];

                            console.log("Telefone removido com sucesso: ", removedPhone);
                            console.log("Novos phones: ", JSON.stringify(this.phones));
                        } else {
                            console.error("Índice fora dos limites da lista phones");
                        }

                    } else if (data?.result?.IPResult?.result?.statuscode == 400) {
                        console.log("statuscode " + data?.result?.IPResult?.result?.statuscode);
                        this.showModal = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 404) {
                        this.showModal = false;
                        console.log("statuscode " + data?.result?.IPResult?.result?.statuscode);
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 500) {
                        console.log("statuscode " + data?.result?.IPResult?.result?.statuscode);
                        this.showModal = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else {
                        console.log("statuscode " + data?.result?.IPResult?.result?.statuscode);
                        this.showModal = false;
                        this.mostrarToast('O telefone não houve alteração.', 'Error');
                    }
                }).catch((error) => {
                    // Trate erros aqui, se necessário
                    console.error(error);
                });
        }
    }
    async novoPhone() {
        console.log("novoPhone ");
        let Type = "Adiciona";
        let newPhoneNumber = this.newPhoneNumber;
        let nuberIndex = this.phoneIndexToDelete;
        const currentPhone = this.contIndex[nuberIndex - 1];
        // console.log('novoPhone-newPhoneNumber ' + newPhoneNumber);
        // console.log('novoPhone-TipoFone ' + this.TipoFone);

        if (newPhoneNumber == null) {
            this.showModal2 = false;
            this.mostrarToast('Não foi possivel adicionar o novo contato, pois o telefone esta vazio.', 'Error');
        } else {
            console.log("entra 1");
            await this.CallIntegrationGeral(this.caseId, Type, nuberIndex, null, newPhoneNumber, null)
                .then((data) => {
                    console.log("data " + JSON.stringify(data));
                    if (data?.result?.IPResult?.statuscode == 200) {
                        this.showModal2 = false;
                        this.mostrarToast(data.result.IPResult.message, 'success');
                        currentPhone.mensagemPersonalizada = "Telefone adicionado com sucesso.";
                        currentPhone.mostrarMensagem = true; // Exibe a mensagem
                        currentPhone.mensagemClasse = "mensagem-suseco";
                        currentPhone.isNew = false;
                        this.phones.push(newPhoneNumber);
                    } else if (data?.result?.IPResult?.result?.statuscode == 400) {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal2 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 404) {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal2 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else if (data?.result?.IPResult?.result?.statuscode == 500) {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal2 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    } else {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal2 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                    }
                }).catch((error) => {
                    // Trate erros aqui, se necessário
                    console.error(error);
                });
        }

    }
    async alteraEmail() {
        console.log('alteraEmail');
        const Type = "AlteraEmail";
        this.hasChangesemail = false;

        const Formatado = {
            "old_email1": this.copiaOBJ["old_email1"],
            "old_email2": this.copiaOBJ["old_email2"],
            "old_email3": this.copiaOBJ["old_email3"],
            "old_email4": this.copiaOBJ["old_email4"]
        };

        const valoresFiltrados = Object.values(Formatado).filter(val => val !== "");
        // console.log("valoresFiltrados ", valoresFiltrados);
        const stringFormatada = valoresFiltrados.join(', ');
        // console.log("stringFormatada ", stringFormatada);
        const objFormatado = {
            "old_email1": this.copiaOBJ["old_email1"],
            "old_email2": this.copiaOBJ["old_email2"],
            "old_email3": this.copiaOBJ["old_email3"],
            "old_email4": this.copiaOBJ["old_email4"],
            "stringFormatada": stringFormatada
        };
        // console.log("objFormatado ", JSON.stringify(objFormatado));

        await this.CallIntegrationGeral(this.caseId, Type, null, null, null, objFormatado)
            .then((data) => {
                console.log("data " + JSON.stringify(data));
                if (data?.result?.IPResult?.statuscode == 200) {
                    this.showModal3 = false;
                    this.desabilitasbutton = true;
                    this.mostrarToast(data.result.IPResult.message.message, 'success');
                    const changedEmailFields = this.getChangedEmailFields();
                    console.log("changedEmailFields", JSON.stringify(changedEmailFields));
                    this.updateEmailErrors(changedEmailFields);
                    this.obj = { ...this.copiaOBJ};
                }else if (data?.result?.IPResult?.result?.statuscode == 400 ||
                    data?.result?.IPResult?.result?.statuscode == 404 ||
                    data?.result?.IPResult?.result?.statuscode == 409) {
                        console.log("statuscode " + data.result.IPResult.result.statuscode);
                        this.showModal3 = false;
                        this.mostrarToast(data.result.IPResult.result.message, 'Error');
                } else {
                    this.showModal3 = false;
                    this.mostrarToast('O e-mail não houve alteração.', 'Error');
                }
            }).catch((error) => {
                // Trate erros aqui, se necessário
                console.error(error);
            });

    }
    // async alteraEmail() {
    //     console.log("alteraEmail ");
    //     let Type = "AlteraEmail";
    //     let novoEmail = this.emailAtual;
    //     let isValidEmail = this.isValidEmail;
    //     console.log('alteraEmail-Email ' + novoEmail);
    //     console.log('alteraEmail-antEmail ' + this.email);
    //     console.log('alteraEmail-isValidEmail ' + isValidEmail);

    //     if (!isValidEmail) {
    //         console.log("alteraEmail 1 ");
    //         this.showModal3 = false;
    //         this.mostrarToast('O email informado é inválido, necessário revisar.', 'Error');
    //     } else if (isValidEmail == true && novoEmail == this.email) {
    //         console.log("alteraEmail 2 ");
    //         this.showModal3 = false;
    //         this.mostrarToast('O e-mail é igual ao anterior.', 'Error');
    //     } else {
    //         console.log("entra 1");
    //         await this.CallIntegrationGeral(this.caseId, Type, null, null, null, novoEmail)
    //             .then((data) => {
    //                 console.log("data " + JSON.stringify(data));
    //                 if (data?.result?.IPResult?.statuscode == 200) {
    //                     this.showModal3 = false;
    //                     this.mostrarToast(data.result.IPResult.message.message, 'success');
    //                     this.msg = 'Os dados foram atualizados com sucesso.';
    //                     this.emailvisivel = true;
    //                     this.emailestilo = 'mensagem-suseco'; // Substitua pela classe desejada
    //                 } else if (data?.result?.IPResult?.result?.statuscode == 400) {
    //                     console.log("statuscode " + data.result.IPResult.result.statuscode);
    //                     this.showModal3 = false;
    //                     this.mostrarToast(data.result.IPResult.result.message, 'Error');
    //                 } else if (data?.result?.IPResult?.result?.statuscode == 404) {
    //                     console.log("statuscode " + data.result.IPResult.result.statuscode);
    //                     this.showModal3 = false;
    //                     this.mostrarToast(data.result.IPResult.result.message, 'Error');
    //                 } else if (data?.result?.IPResult?.result?.statuscode == 409) {
    //                     console.log("statuscode " + data.result.IPResult.result.statuscode);
    //                     this.showModal3 = false;
    //                     this.mostrarToast(data.result.IPResult.result.message, 'Error');
    //                 } else {
    //                     console.log("statuscode " + data.result.IPResult.result.statuscode);
    //                     this.showModal3 = false;
    //                     this.mostrarToast('O e-mail não houve alteração.', 'Error');
    //                 }
    //             }).catch((error) => {
    //                 // Trate erros aqui, se necessário
    //                 console.error(error);
    //             });
    //     }
    // }
    closeModal() {
        console.log("closeModal ");
        this.showModal = false;
        this.showModal1 = false;
        this.showModal2 = false;
        this.showModal3 = false;
    }
    CallIntegrationGeral(caseId, type, phoneIndexToDelete, oldPhoneNumber, newPhoneNumber, objFormatado) {
        return new Promise((resolve, reject) => {
            console.log("CallIntegrationGeral ");

            let input;
            if (type == "AlteraEmail") {
                input = {
                    Type: "AlteraEmail",
                    caseId: caseId,
                    objFormatado: objFormatado
                };
                console.log("input ", input);
            } else if (type == "deleta") {
                input = {
                    Type: "deleta",
                    oldPhoneNumber: oldPhoneNumber,
                    numberIndex: phoneIndexToDelete,
                    caseId: this.caseId
                };
            }
            else if (type == "Altera") {
                input = {
                    Type: "Altera",
                    newPhoneNumber: newPhoneNumber,
                    oldPhoneNumber: oldPhoneNumber,
                    numberIndex: phoneIndexToDelete,
                    TipoFone: this.TipoFone,
                    caseId: this.caseId
                };
            } else if (type == "Adiciona") {
                input = {
                    Type: "Adiciona",
                    newPhoneNumber: newPhoneNumber,
                    caseId: this.caseId,
                    numberIndex: phoneIndexToDelete
                };
            } else {
                window.console.log("Erro parâmetros invalidos.");
            }

            const params = {
                input: JSON.stringify(input),
                sClassName: "IntegrationProcedureService",
                sMethodName: "Every_CriaAtualizaDeletaContato",
                options: "{}",
            };
            this._actionUtilClass
                .executeAction(params, null, this, null, null)
                .then((response) => {
                    resolve(response);
                }).catch((error) => {
                    reject(error);
                });
        });
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
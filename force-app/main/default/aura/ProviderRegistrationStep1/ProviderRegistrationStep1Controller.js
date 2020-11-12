({    
    loadJquery: function (component, event, helper) {
        jQuery(document).ready(function () {
            $('.cnpj').mask('99.999.999/9999-99');
            $('.cpf').mask('999.999.999-99');
        });
    },
    
    handleCnpj: function (component, event, helper) {
        var cnpj = component.find("cnpj").getElement().value;
        component.set("v.cnpj", cnpj);
        console.log("cnpj " + component.get("v.cnpj"));
    },
    handleCpf: function (component, event, helper) {
        var cpf = component.find("cpf").getElement().value;
        component.set("v.cpf", cpf);
        console.log("cpf " + component.get("v.cpf"));
    },
    changePersonType: function (component, event, helper){
        var person = component.find("person");
        var typePerson = person.get("v.value");
        console.log(typePerson);
        
        if (typePerson == "PF" && typePerson != null) {     
            component.set("v.typePerson", "PF");
        }
        else if(typePerson == "PJ" && typePerson != null){
            component.set("v.typePerson", "PJ");
        }
        else if(typePerson == null || typePerson == ''){
                component.set("v.typePerson", null);
        }
    },
})
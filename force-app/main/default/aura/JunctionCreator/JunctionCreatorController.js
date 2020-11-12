({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        
        component.set("v.object", myPageRef.state.c__object);
        component.set("v.parentField", myPageRef.state.c__parentField);
        component.set("v.childField", myPageRef.state.c__childField);
        component.set("v.parentId", myPageRef.state.c__parentId);
        component.set("v.headerTitle", myPageRef.state.c__headerTitle);
        component.set("v.recordTypeId", myPageRef.state.c__recordTypeId);
        
        var parentValue = component.get("v.parentId")
        component.find("ParentField").set("v.value", parentValue);     
    },

    closeModal: function (component, event, helper) {
        helper.redirectToRecord(component, event, helper);
    },

    clickedButton: function (component, event, helper) {
        var whichOne = event.getSource().getLocalId();
        component.set("v.button", whichOne);
    },
    
    submitError: function (component, event, helper) {
        var parenteField = component.find("ParentField").get("v.value");    
        var childField = component.find("ChildField").get("v.value"); 
        // console.log(childField);
        if (parenteField == null || childField == null || parenteField == '' || childField == '' || parenteField == undefined || childField == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Erro",
                "message": "Selecione os dois registros que deseja vincular.",
                "duration": ' 5000',
                "type": 'error',
            });
            toastEvent.fire();
        }
    },

    success: function (component, event, helper) {
        var whichOne = component.get("v.button");
        console.log(whichOne);
        if (whichOne == 'SaveAndNew'){
            helper.sucessToast(component, event, helper);
            component.find("ChildField").set("v.value", null);

        }
        else{
            helper.sucessToast(component, event, helper);
            helper.redirectToRecord(component, event, helper);
            component.find("ChildField").set("v.value", null);
        }
    },
})
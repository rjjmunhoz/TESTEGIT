({
	changeDateSurvey : function(component, event, helper) {
        var value = event.getSource().get("v.value");
        if(value === 'Não necessario'){
            component.set("v.dateSurvey", false);
        }else{
			component.set("v.dateSurvey", true);
        }
    },
})
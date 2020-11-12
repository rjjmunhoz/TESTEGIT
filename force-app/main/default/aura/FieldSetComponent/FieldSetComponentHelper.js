({
    onInit : function(component, event, helper){
        var self = this;
        var sObjectName = component.get('v.sObjectName');
        var fieldSet = component.get('v.fieldSet');
        console.log('###sObjectName ', component.get('v.sObjectName'));
        console.log('###fieldSet ', component.get('v.fieldSet'));
        
        var FiledSetMember = component.get('c.getFieldSetMember');
        FiledSetMember.setParams({
            "objectName" : sObjectName,
            "fieldSetName" : fieldSet
        });
        FiledSetMember.setCallback(this, function(response){
            var state = response.getState();
            console.log('###state ', state);
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var fieldSetMember = response.getReturnValue();
                console.log('###fieldSetMember ', response.getReturnValue());
                component.set('v.objectFields', fieldSetMember);
                
            }else if(state==='INCOMPLETE'){
                console.log('User is Offline System does not support drafts '
                           + JSON.stringify(response.getError()));
            }else if(state ==='ERROR'){
                console.log('Error ', response.getError()[0].message);
            }else{
                
            }
        });
        FiledSetMember.setStorable();
        $A.enqueueAction(FiledSetMember);
    },    
})
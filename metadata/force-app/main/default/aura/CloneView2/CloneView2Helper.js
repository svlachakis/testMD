({
    handleInit : function(component, event, helper) {
        
    	var cloneAction = component.get("c.clone");

        cloneAction.setParams({
            "recordId": component.get("v.recordId")
        });
       
        cloneAction.setCallback(this, function(response) {
            var cloneRecordId = response.getReturnValue();
                
            if((typeof sforce !== 'undefined') && (sforce !== undefined) && (sforce.one !== undefined)) {
                sforce.one.navigateToURL(cloneRecordId);
            } else {
                    window.location.href = '/' + cloneRecordId;
            }
        });
        $A.enqueueAction(cloneAction);
    }
})
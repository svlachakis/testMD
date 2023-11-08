trigger TestCustomTrigger on testObj__c (after update) {
 Trigger.new.get(0).addError('some error');
}
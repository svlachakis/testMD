trigger TestTrigger on X12_12_regression__c(before insert, before update) {
  for (X12_12_regression__c a : Trigger.new) {
    //a.addError('Blocked by trigger');
  }
}
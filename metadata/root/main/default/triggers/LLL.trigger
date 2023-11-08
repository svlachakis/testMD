trigger LLL on Regression12_12__c (before insert, before update) {
  for (Regression12_12__c a : Trigger.new) {
    //a.addError('Blocked by trigger');
  }
}
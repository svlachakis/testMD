trigger WorkTrigger on agf__ADM_Work__c(before insert) {
  for (agf__ADM_Work__c aaWorkItem : Trigger.new) {
    CreateDOCWorkItemCallout.createDOCWorkItem(aaWorkItem);
  }

}
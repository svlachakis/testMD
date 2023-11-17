trigger ProjectTrigger on agf__PPM_Project__c(after insert) {
    
  for (agf__PPM_Project__c aaProject : Trigger.new) {
    if (aaProject.Is_Development_Project__c) {
      CreateDOCProjectCallout.createDOCProject(aaProject.Id);
    }
  }
}
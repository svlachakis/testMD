public with sharing class CreateDOCWorkItemCallout {
  public static void createDOCWorkItem(agf__ADM_Work__c workItem) {
    ID epicId = workItem.agf__Epic__c;
    if (epicId == null) {
      return;
    }

    // query for connected epic
    agf__ADM_Epic__c epicObject = Database.query(
      'Select Id, agf__Project__c From agf__ADM_Epic__c Where Id = :epicId limit 1'
    );
    ID projectId = (ID) epicObject.agf__Project__c;

    if (projectId == null) {
      return;
    }

    // query for connected project
    agf__PPM_Project__c projectObject = Database.query(
      'Select Id, DevOpsCenter_Project__c, DevOpsCenter_Project_Link__c From agf__PPM_Project__c Where Id = :projectId limit 1'
    );
    ID docProjectId = (ID) projectObject.DevOpsCenter_Project__c;

    if (docProjectId == null) {
      return;
    }

    // check pipeline was activated
    List<sf_devops__Pipeline__c> docPipelines = Database.query(
      'Select Id, sf_devops__Activated__c From sf_devops__Pipeline__c ' +
      'Where sf_devops__Project__c = :docProjectId limit 1'
    );

    if (docPipelines.isEmpty()) {
      String docProjectLink = (String) projectObject.DevOpsCenter_Project_Link__c;
      workItem.addError(
        'Deployment pipeline in the corresponding DevOps Center Project must be activated'
      );
      return;
    }

    sf_devops__Pipeline__c docPipeline = docPipelines.get(0);

    if (!docPipeline.sf_devops__Activated__c) {
      String docProjectLink = (String) projectObject.DevOpsCenter_Project_Link__c;
      workItem.addError(
        'Deployment pipeline in the corresponding DevOps Center Project must be activated'
      );
      return;
    }

    sf_devops__Work_Item__c docWorkItem = new sf_devops__Work_Item__c();
    if (Schema.sObjectType.sf_devops__Work_Item__c.isCreateable()) {
      docWorkItem.sf_devops__Assigned_To__c = workItem.agf__Assignee__c;
      docWorkItem.sf_devops__Project__c = docProjectId;
      docWorkItem.sf_devops__Description__c = workItem.agf__Description__c;
      docWorkItem.sf_devops__Subject__c = workItem.agf__Subject__c;

      insert docWorkItem;

      workItem.DevOpsCenter_Work_Item__c = docWorkItem.Id;
    } else {
      docWorkItem.addError('sf_devops__Work_Item__c is not createable');
      return;
    }
  }
}
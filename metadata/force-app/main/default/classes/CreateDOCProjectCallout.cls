public with sharing class CreateDOCProjectCallout {
  @future(callout=true)
  public static void createDOCProject(ID projectId) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:sf_devops__DevOps_Center_GitHub/user');
    req.setMethod('GET');
    Http http = new Http();
    HTTPResponse res = http.send(req);
    JSONParser parser = JSON.createParser(res.getBody());

    String gitHubUserName = '';
    while (parser.nextToken() != null) {
      if (
        (parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
        (parser.getText() == 'login')
      ) {
        parser.nextToken();
        gitHubUserName = parser.getText();
        break;
      }
    }

    agf__PPM_Project__c projectObject = Database.query(
      'Select Id, Name From agf__PPM_Project__c Where Id = :projectId limit 1'
    );
    String projectName = ((String)projectObject.get('Name')).replaceAll('\\s+', '');


    HttpRequest createDxProjectRequest = new HttpRequest();
    createDxProjectRequest.setEndpoint(
      'callout:sf_devops__DevOps_Center_GitHub/repos/forcedotcom/dx-empty/generate'
    );

    createDxProjectRequest.setMethod('POST');
    createDxProjectRequest.setHeader(
      'Accept',
      'application/vnd.github.v3+json'
    );

    JSONGenerator generator = JSON.createGenerator(false);
    generator.writeStartObject();
    generator.writeStringField('owner', gitHubUserName);
    generator.writeStringField('name', projectName);
    generator.writeStringField('description', projectName);
    generator.writeBooleanField('include_all_branches', false);
    generator.writeBooleanField('private', false);
    generator.writeEndObject();
    createDxProjectRequest.setBody(generator.getAsString());
    HTTPResponse createDxProjectResponse = new Http()
      .send(createDxProjectRequest);
    system.debug(createDxProjectResponse.getBody());

    sf_devops__Repository__c repo = new sf_devops__Repository__c();
    if (Schema.sObjectType.sf_devops__Repository__c.isCreateable()) {
      repo.sf_devops__Named_Credential__c = 'DevOps_Center_GitHub';
      repo.sf_devops__Default_Branch__c = 'main';
      repo.Name = gitHubUserName + '/' + projectName;
      repo.sf_devops__Provider__c = 'GitHub';
      repo.sf_devops__GitHub_Repo__c = projectName;
      repo.sf_devops__GitHub_Owner__c = gitHubUserName;
      insert repo;
    } else {
      projectObject.addError(
        'sf_devops__Repository__c object is not createable'
      );
      return;
    }

    sf_devops__Project__c docProject = new sf_devops__Project__c();
    if (Schema.sObjectType.sf_devops__Project__c.isCreateable()) {
      docProject.Name = projectName;
      docProject.sf_devops__Platform_Repository__c = repo.Id;
      insert docProject;
    } else {
      projectObject.addError('sf_devops__Project__c object is not createable');
      return;
    }

    if (Schema.sObjectType.agf__PPM_Project__c.isUpdateable()) {
      projectObject.DevOpsCenter_Project__c = docProject.Id;
      update projectObject;
    } else {
      projectObject.addError('agf__PPM_Project__c is not updatable');
      return;
    }
  }
}
@isTest
public class TestAAIntegration {
  private class RestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String fullJson = '{"login": "zzzhkbhkbhk11","id": 1,"node_id": "MDQ6VXNlcjE=","avatar_url": "https://github.com/images/error/octocat_happy.gif","gravatar_id": "","url": "https://api.github.com/users/octocat","html_url": "https://github.com/octocat","followers_url": "https://api.github.com/users/octocat/followers","following_url": "https://api.github.com/users/octocat/following{/other_user}","gists_url": "https://api.github.com/users/octocat/gists{/gist_id}","starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}","subscriptions_url": "https://api.github.com/users/octocat/subscriptions","organizations_url": "https://api.github.com/users/octocat/orgs","repos_url": "https://api.github.com/users/octocat/repos","events_url": "https://api.github.com/users/octocat/events{/privacy}","received_events_url": "https://api.github.com/users/octocat/received_events","type": "User","site_admin": false,"name": "monalisa octocat","company": "GitHub","blog": "https://github.com/blog","location": "San Francisco","email": "octocat@github.com","hireable": false,"bio": "There once was...","twitter_username": "monatheoctocat","public_repos": 2,"public_gists": 1,"followers": 20,"following": 0,"created_at": "2008-01-14T04:33:35Z","updated_at": "2008-01-14T04:33:35Z"}';

      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'text/json');
      res.setBody(fullJson);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  public static void testProjectTrigger() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    agf__PPM_Project__c project2 = new agf__PPM_Project__c();
    project2.Name = 'zzz111';
    project2.Is_Development_Project__c = true;

    Boolean exceptionNotOccurred = false;

    try {
      exceptionNotOccurred = true;
      insert project2;
    } catch (DMLException ex) {
      exceptionNotOccurred = false;
    }

    System.assert(exceptionNotOccurred, 'An Exception was thrown');
    Test.stopTest();
  }

  @isTest
  public static void testCreateDOCProjectCallout() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();

    agf__PPM_Project__c project2 = new agf__PPM_Project__c();
    project2.Name = 'zzz111';
    insert project2;
    project2.Is_Development_Project__c = true;
    update project2;

    CreateDOCProjectCallout.createDOCProject(project2.Id);

    agf__ADM_Epic__c epic = new agf__ADM_Epic__c();
    epic.agf__Project__c = project2.Id;
    insert epic;

    agf__ADM_Work__c workItem = new agf__ADM_Work__c();
    workItem.agf__Epic__c = epic.Id;

    insert workItem;

    CreateDOCWorkItemCallout.createDOCWorkItem(workItem);

    Test.stopTest();

    ID projectId = project2.Id;

    agf__PPM_Project__c projectObject = Database.query(
      'Select Id, DevOpsCenter_Project__c, DevOpsCenter_Project_Link__c From agf__PPM_Project__c Where Id = :projectId limit 1'
    );

    System.assertNotEquals(
      projectObject.DevOpsCenter_Project__c,
      null,
      'Something went wrong'
    );
  }

  @isTest
  public static void testCreateDOCWorkItemCalloutWithoutPipeline() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();

    agf__PPM_Project__c project2 = new agf__PPM_Project__c();
    project2.Name = 'zzz111';
    insert project2;
    project2.Is_Development_Project__c = true;
    update project2;

    CreateDOCProjectCallout.createDOCProject(project2.Id);

    Test.stopTest();

    agf__ADM_Epic__c epic = new agf__ADM_Epic__c();
    epic.agf__Project__c = project2.Id;
    insert epic;

    agf__ADM_Work__c workItem = new agf__ADM_Work__c();
    workItem.agf__Epic__c = epic.Id;

    Boolean exceptionOccurred = false;
    try {
      insert workItem;
    } catch (DMLException ex) {
      exceptionOccurred = true;
    }

    System.assert(exceptionOccurred, 'An Exception was not thrown');
  }
}
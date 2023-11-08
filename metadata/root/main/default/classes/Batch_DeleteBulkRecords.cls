global class Batch_DeleteBulkRecords implements Database.Batchable<sObject> {
    

    //Start method of Batch
    global Database.QueryLocator start(Database.BatchableContext bc){
      
        //return query 
        return Database.getQueryLocator('Select Id from Account');
    }

    //'Select Id from B__C where id != \'a6P3D000000Cp77UAC\''
    //Execute method of batch
    global void execute(Database.batchableContext bc, List<Account> listData ) {      
        
        Database.DeleteResult[] deletedResult = Database.delete(listData, false);
    }  
 
   global void finish(Database.BatchableContext bc){
       // execute any post-processing operations
   }
}
public with sharing class ManageSchedulers {
    
  @Auraenabled
  public static void runBatchOnce(String batchClassName){
    Type type = Type.forName(batchClassName);
		Database.executeBatch((Database.Batchable<sObject>)type.newInstance());
  }

  @AuraEnabled
  public static void scheduleBatch(String schedulerClassName, String cronExp){
    Type type = Type.forName(schedulerClassName);
    System.schedule(schedulerClassName + 'Job', cronExp, (Schedulable)type.newInstance());
  }

  @AuraEnabled
  public static void abortBatch(String schedulerClassName){
    CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :schedulerClassName + 'Job'];
    System.abortJob(cronTrigger.Id);
  }

  @AuraEnabled(cacheable=true)
  public static Boolean isRunning(String schedulerClassName){
    List<CronTrigger> cronTrigger = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :schedulerClassName + 'Job' LIMIT 1];
    if(cronTrigger.size() != 0)   
      return true;
    else
      return false;
  }
}

@isTest
public with sharing class ManageSchedulersTest {

    @isTest
    public static void scheduleBatchTest(){
        String schedulerClassName = 'BirthDayEmailScheduler';
        String cronExp = '0 0 7 * * ? *';

        Test.startTest();
        ManageSchedulers.scheduleBatch(schedulerClassName, cronExp);
        Test.stopTest();

        CronTrigger assert = [SELECT Id FROM CronTrigger  WHERE CronJobDetail.Name = 'BirthDayEmailSchedulerJob'];
        System.assertNotEquals(assert.Id, null, 'CronTrigger Id should be not null');
    }

    @isTest
    public static void abortBatchTest(){
        scheduleJob();
        String schedulerClassName = 'BirthDayEmailScheduler';

        Test.startTest();
        ManageSchedulers.abortBatch(schedulerClassName);
        Test.stopTest();

        List<CronTrigger> assert = [SELECT Id FROM CronTrigger  WHERE CronJobDetail.Name = 'BirthDayEmailSchedulerJob' LIMIT 1];
        System.assertEquals(assert.size(), 0, 'Cron trigger should don\'t exist');
    }

    @isTest
    public static void isRunningPositiveTest(){
        scheduleJob();
        String schedulerClassName = 'BirthDayEmailScheduler';

        Test.startTest();
        Boolean result = ManageSchedulers.isRunning(schedulerClassName);
        Test.stopTest();

        System.assert(result, 'Result should be true');
    }

    @isTest
    public static void isRunningNegativeTest(){
        scheduleJob();
        String schedulerClassName = 'BirthDay';

        Test.startTest();
        Boolean result = ManageSchedulers.isRunning(schedulerClassName);
        Test.stopTest();

        System.assert(!result, 'Result should be false');
    }



    public static void scheduleJob(){
        String cronExp = '0 0 7 * * ? *';
        BirthDayEmailScheduler birthDayEmailScheduler = new BirthDayEmailScheduler();
        System.schedule('BirthDayEmailSchedulerJob', cronExp, birthDayEmailScheduler);
    }
}

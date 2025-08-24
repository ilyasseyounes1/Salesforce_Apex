/*
System.schedule('Job Name', 'cron expression', new YourSchedulableClass()) 
You must pass:
    A job name (String)
    A cron expression (String)
    An instance of a class that implements Schedulable 
*/

//------------ Daily at 6 AM — Clean Temp Records
public class CleanTempRecords implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Delete temp records
        delete [SELECT Id FROM Temp__c WHERE CreatedDate < LAST_N_DAYS:7];
    }
}

System.schedule('Clean Temp Records Job', '0 0 6 * * ?', new CleanTempRecords());

//------------Weekly on Monday at 9 AM — Send Summary EmailDaily at 6 AM — Clean Temp Records
public class WeeklySummaryJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'admin@example.com'});
        mail.setSubject('Weekly Summary');
        mail.setPlainTextBody('Here is your weekly summary...');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}

System.schedule('Weekly Summary', '0 0 9 ? * MON', new WeeklySummaryJob());

//--------------------First Day of Every Month at 8 AM — Contract Renewal Check
public class CheckRenewalsJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Check for expiring contracts and notify sales
    }
}

System.schedule('Monthly Renewal Check', '0 0 8 1 * ?', new CheckRenewalsJob());

//----------------------------------------------------------------------------------------------
/* 
String cronExpression = '0 0 2 * * ?';   "Seconds Minutes Hours Day_of_Month Month Day_of_Week [Year]"
String jobName = 'Daily Data Cleanup';
MyScheduledClass scheduledJob = new MyScheduledClass();
System.schedule(jobName, cronExpression, scheduledJob);
 */


/* 

* = Any value
? = No specific value (used for day fields)
- = Range (e.g., 1-5)
, = List (e.g., 1,3,5)
/ = Step values (e.g., 0/15 = every 15 units)

 */

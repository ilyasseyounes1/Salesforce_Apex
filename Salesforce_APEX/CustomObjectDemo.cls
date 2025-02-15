public class CustomObjectDemo {
    public static void createPosition(){
        Position__c pos = new Position__c();
        pos.Name = 'Java developer';
        pos.RecordTypeId = '012Qy000001ZlJdIAK'; // this is not a best practice you to Query ...
        insert pos;
    }
     public static void createCandidate(){
        Condidate__c can = new Condidate__c();
        can.First_Name__c = 'Candidate';
        can.Last_Name__c = 'toe';
        insert can;
    }
     public static void creatJobApplication(){
         Position__c pos = new Position__c();
        pos.Name = 'salesforce developer';
        pos.RecordTypeId = '012Qy000001ZlJdIAK'; // this is not a best practice you to Query ...
        insert pos;
        
        Condidate__c can = new Condidate__c();
        can.First_Name__c = 'moracami';
        can.Last_Name__c = 'toe';
        insert can;
        
        Job_Applicaton__c job = new Job_Applicaton__c();
        job.Position__c = pos.Id;
        job.Condidate__c = can.Id;
        job.Status__c = 'New';
        insert job;
    }
}
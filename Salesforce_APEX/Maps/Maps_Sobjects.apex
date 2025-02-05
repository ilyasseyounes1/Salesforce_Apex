public class Maps_Sobject {
    public static void demo (){
       List<Account> accList = new List<Account>();
       Map<Id,Account> accMap = new Map<Id,Account>();

       accList = [SELECT Id, Name, Phone FROM Account LIMIT 5];
       accMap.putAll(acclist);
       System.debug('Map contain :'+ accMap);

       for (Account acc : accList ){
        accMap.put(acc.id, acc);
       }

    }
    List <Position__c> posMap = new Map<position__c>();
    posList = [SELECT Name, createDate FROM Positoin__c LIMIT 5];
    posMap.putAll(posMap);
    System.debug('Map contain'+ posMap);

    for (position__c pos : posList){
        posMap.put(pos.createDate,name);
    }
}
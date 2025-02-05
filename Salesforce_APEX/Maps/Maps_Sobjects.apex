public class Maps_Sobject {
    public static void demo (){
       List<Account> accList = new List<Account>();
       Map<Id,Account> accMap = new Map<Id,Account>();

       accList = [SELECT Id, Name, Phone FROM Account LIMIT 5];
       accMap.putAll(acclist);
       System.debug('Map contain :'+ accMap);
       

    }
}
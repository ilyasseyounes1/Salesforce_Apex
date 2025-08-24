public class Loops_sObj{
    List<Account> accList = new List<Account>();
    accList = [SELECT Id, Name FROM Account Limit 5];
    if (!accList.isEmpty()) {
        for (Account acc: accList){ //acc and accLit should be same data type 
            System.debug(acc.Id + '-' + acc.Name);

        }
    }
    List<Account> accList2 = [SELECT Id, Name,Industry FROM Account];
    for (Account acc: accList2) {
        System.debug('Account Name : ' + acc.Name + 'Industry: ' + acc.Industry);
    }

    // Eterate Map based on values: 
    Map <Id,Account> accMap = [SELECT Id, Name FROM Account];
        if (!accMap.isEmpty()){
            for (Account acc: accMap.values){
                System.debug(acc);
            }
        }

     // Display data through List :    
    if (accList.size() > 0){
        for (Account acc : accList){
            System.debug(acc.Id + '-' + acc.Name);
            accIds.add(acc.Id);
            accMap.put(acc.Id, acc);
        }
    }

    
}
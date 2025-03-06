public class SOQL_query{
    public static void queryDemo(){
        List<Account> accList  =
        [SELECT Id,Name,Industry
        FROM Account
        WHERE Industry
        IN ('Media','Energy')] ;

        for (Account acc: accList ){
        System.debug(acc);
        }
    }
    // String :
    List<Account> accList1  = [SELECT Id, Name , Industy FROM Account WHERE AnnualRevenue >=: idus];
    for (Account acc : acclist ){
    System.debug(acc);
    }
}

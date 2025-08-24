
public class ExceptionHandlingDemo {

    // 1. General try-catch-finally
    public static void generalTryCatch() {
        try {
            Integer x = 10 / 0;
        } catch (Exception e) {
            System.debug('General Exception: ' + e.getMessage());
        } finally {
            System.debug('Finally block executed');
        }
    }

    // 2. DMLException handling
    public static void dmlExceptionDemo() {
        try {
            Account acc = new Account(); // Missing required field 'Name'
            insert acc;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }
    }

    // 3. NullPointerException handling
    public static void nullPointerDemo() {
        try {
            Account acc = null;
            String name = acc.Name; // Will throw NullPointerException
        } catch (NullPointerException e) {
            System.debug('NullPointerException: ' + e.getMessage());
        }
    }

    // 4. QueryException: SOQL returns more than one row
    public static void queryExceptionDemo() {
        try {
            Account acc = [SELECT Id FROM Account]; // May return >1 record
        } catch (QueryException e) {
            System.debug('QueryException: ' + e.getMessage());
        }
    }

    // 5. ListException: accessing out-of-bounds index
    public static void listExceptionDemo() {
        try {
            List<Account> accList = new List<Account>();
            Account acc = accList[0]; // Empty list
        } catch (ListException e) {
            System.debug('ListException: ' + e.getMessage());
        }
    }

    // 6. CalloutException: simulate web service call failure
    @future(callout=true)
    public static void calloutExceptionDemo() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://invalid.endpoint'); // Bad endpoint
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
        } catch (CalloutException e) {
            System.debug('CalloutException: ' + e.getMessage());
        }
    }

    // 7. Custom exception class + throw + catch
    public class MyCustomException extends Exception {}

    public static void customExceptionDemo() {
        try {
            throw new MyCustomException('This is a custom exception');
        } catch (MyCustomException e) {
            System.debug('Custom Exception: ' + e.getMessage());
        }
    }

    // 8. Multiple catch blocks
    public static void multipleCatchBlocks() {
        try {
            Integer i = 1 / 0;
        } catch (NullPointerException npe) {
            System.debug('Null Pointer');
        } catch (ArithmeticException ae) {
            System.debug('Arithmetic Error: ' + ae.getMessage());
        } catch (Exception e) {
            System.debug('General Exception: ' + e.getMessage());
        }
    }
}
/*ExceptionHandlingDemo.generalTryCatch();
ExceptionHandlingDemo.dmlExceptionDemo();
ExceptionHandlingDemo.nullPointerDemo();
ExceptionHandlingDemo.queryExceptionDemo();
ExceptionHandlingDemo.listExceptionDemo();
ExceptionHandlingDemo.calloutExceptionDemo(); // Asynchronous
ExceptionHandlingDemo.customExceptionDemo();
ExceptionHandlingDemo.multipleCatchBlocks(); */
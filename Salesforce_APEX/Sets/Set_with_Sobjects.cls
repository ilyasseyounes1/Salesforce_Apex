public class SetExamples {
    public static void runSetOperations() {
        // Creating a Set with Account IDs
        Set<Id> accIds = new Set<Id>();
        List<Account> accList = [SELECT Id FROM Account LIMIT 5];
        for (Account acc : accList) {
            accIds.add(acc.Id);
        }
        System.debug('Account ID Set: ' + accIds);

        // Creating a Set with Position__c IDs
        Set<Id> posIds = new Set<Id>();
        List<Position__c> posList = [SELECT Id FROM Position__c LIMIT 5];
        for (Position__c pos : posList) {
            posIds.add(pos.Id);
        }
        System.debug('Position__c ID Set: ' + posIds);

        // Merging two Sets (Union operation)
        Set<Id> mergedIds = new Set<Id>(accIds);
        mergedIds.addAll(posIds);
        System.debug('Merged ID Set: ' + mergedIds);

        // Removing elements from a Set
        if (!accIds.isEmpty()) {
            accIds.remove(accList[0].Id);
            System.debug('After removing an Account ID: ' + accIds);
        }

        // Checking if a Set contains a specific ID
        Boolean containsId = posIds.contains(posList[0].Id);
        System.debug('Does Position__c ID Set contain first Position__c ID? ' + containsId);

        // Finding common elements (Intersection operation)
        Set<Id> commonIds = new Set<Id>(accIds);
        commonIds.retainAll(posIds);
        System.debug('Common IDs between Account and Position__c Sets: ' + commonIds);

        // Clearing all elements from a Set
        accIds.clear();
        posIds.clear();
        System.debug('After clearing Sets: Account IDs -> ' + accIds + ', Position__c IDs -> ' + posIds);
    }
}

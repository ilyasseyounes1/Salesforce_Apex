public class Maps_Methods {
    public static void runMapOperations() {
        // 1. Creating a Map (Key: String, Value: Integer)
        Map<String, Integer> scoreMap = new Map<String, Integer>();

        // 2. Adding elements to the Map
        scoreMap.put('Alice', 90);
        scoreMap.put('Bob', 85);
        scoreMap.put('Charlie', 95);

        // 3 . Retrieving a  value using a key
        Integer aliceScore = scoreMap.get('Alice'); // Returns 90
        System.debug('Alice Score: ' + aliceScore );

        //  4. Checking if a key exists
        Boolean hasBob = scoreMap.containsKey('Bob'); // Returns true
        System.debug('Has Bob: ' + hasBob);

        // 5. Checking if a value exists : 
        Boolean hasValue = scoreMap.containsValue(85 ); // Returns true
        System.debug('Has value 85: ' + hasValue);

        // 6 . Removing a key-value pair
        scoreMap.remove('Charlie'); // Removes Charlie from the Map
        System.debug('After removing Charlie: ' + scoreMap);

        // 7.  Getting all keys: 
        Set<String> keys = scoreMap.keySet();
        System.debug('Keys: ' + keys);
  
        // 8. Getting all values
        List<Integer> values = scoreMap.values( );
        System.debug('Values: ' + values );

        // 9. Getting the size of the Map
        Integer size = scoreMap.size();
        System.debug('Size of Map: ' + size);

        // 10. Iterating over the Map using a loop
        for (String key : scoreMap.keySet()) {
            System.debug(key + ' -> ' + scoreMap.get(key));
        }

        // 11. Cloning a Map
        Map<String, Integer> clonedMap = new Map<String, Integer>(scoreMap);
        System.debug('Cloned Map: ' + clonedMap);

        // 12. Clearing the Map
        scoreMap.clear();
        System.debug('After clearing: ' + scoreMap);

        // 13. Checking if Map is empty
        Boolean isEmpty = scoreMap.isEmpty(); // Returns true
        System.debug('Is Map empty: ' + isEmpty);
}
}
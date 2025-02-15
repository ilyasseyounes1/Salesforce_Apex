public class SetExample {
    public static void runSetOperations() {
        // Creating a Set
        Set<String> sports = new Set<String>{'Football', 'Basketball', 'Tennis'};
        System.debug('Initial Set: ' + sports);

        // Adding elements to a Set
        sports.add('Cricket'); // Adds a new element
        sports.add('Football'); // No duplicate is added
        System.debug('After adding elements: ' + sports);

        // Removing elements from a Set
        sports.remove('Basketball'); // Removes element
        System.debug('After removing Basketball: ' + sports);

        // Checking if a Set contains an element
        Boolean hasTennis = sports.contains('Tennis');
        System.debug('Contains Tennis? ' + hasTennis);

        // Getting the size of the Set
        Integer size = sports.size();
        System.debug('Size of the Set: ' + size);

        // Checking if a Set is empty
        Boolean isEmpty = sports.isEmpty();
        System.debug('Is the Set empty? ' + isEmpty);

        // Iterating over a Set
        System.debug('Iterating over Set:');
        for (String sport : sports) {
            System.debug(sport);
        }

        // Converting a Set to a List
        List<String> sportsList = new List<String>(sports);
        System.debug('Set converted to List: ' + sportsList);

        // Merging two Sets (Union operation)
        Set<String> moreSports = new Set<String>{'Hockey', 'Golf', 'Tennis'};
        sports.addAll(moreSports);
        System.debug('After merging with another Set: ' + sports);

        // Removing multiple elements (Difference operation)
        Set<String> removeSports = new Set<String>{'Football', 'Tennis'};
        sports.removeAll(removeSports);
        System.debug('After removing Football and Tennis: ' + sports);

        // Finding common elements (Intersection operation)
        Set<String> commonSports = new Set<String>{'Cricket', 'Hockey'};
        sports.retainAll(commonSports);
        System.debug('Common elements in both Sets: ' + sports);

        // Clearing all elements from a Set
        sports.clear();
        System.debug('After clearing Set: ' + sports);
    }
}

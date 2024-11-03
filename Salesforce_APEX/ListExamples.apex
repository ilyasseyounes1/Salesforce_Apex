public class ListExamples {
    public static void demonstrateListMethods() {
        // 1. Initialize a List
        List<String> colors = new List<String>();
        System.debug('1. Initialized List: ' + colors);
        
        // 2. Add Elements to a List
        colors.add('Red');
        colors.add('Blue');
        System.debug('2. List After Adding Elements: ' + colors);
        
        // 3. Add All Elements from Another List
        List<String> moreColors = new List<String>{'Green', 'Yellow'};
        colors.addAll(moreColors);
        System.debug('3. List After Adding More Colors: ' + colors);
        
        // 4. Access Elements by Index
        String firstColor = colors[0];
        System.debug('4. First Element in List: ' + firstColor);
        
        // 5. Check if a List Contains an Element
        Boolean hasRed = colors.contains('Red');
        System.debug('5. List Contains "Red": ' + hasRed);
        
        // 6. Remove an Element
        colors.remove('Blue');
        System.debug('6. List After Removing "Blue": ' + colors);
        
        // 7. Clear All Elements
        colors.clear();
        System.debug('7. List After Clear: ' + colors);
        
        // Re-adding elements to demonstrate cloning
        colors.add('Purple');
        colors.add('Orange');
        
        // 8. Clone a List
        List<String> cloneList = colors.clone();
        System.debug('8. Cloned List: ' + cloneList);
        
        // 9. Get the Size of the List
        Integer size = colors.size();
        System.debug('9. Size of the List: ' + size);
    }
}

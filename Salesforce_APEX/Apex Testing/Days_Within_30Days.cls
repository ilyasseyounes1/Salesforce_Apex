@isTest
private class TestVerifyDate {
    
    @isTest
    static void testDateWithin30DaysTrue() {
        // date2 is 10 days after date1 → within range
        Date date1 = Date.today();
        Date date2 = date1.addDays(10);

        Date result = VerifyDate.CheckDates(date1, date2);

        System.assertEquals(date2, result, 'Should return date2 if within 30 days');
    }
    
    @isTest
    static void testDateInPast() {
        // date2 is before date1 → should return end of month
        Date date1 = Date.newInstance(2025, 8, 10);
        Date date2 = date1.addDays(-5); // in the past

        Date result = VerifyDate.CheckDates(date1, date2);
        
        Date expectedEndOfMonth = Date.newInstance(2025, 8, 31);
        System.assertEquals(expectedEndOfMonth, result, 'Should return end of month when date2 is in the past');
    }
    
    @isTest
    static void testDateBeyond30Days() {
        // date2 is exactly 30 days after date1 → should return end of month
        Date date1 = Date.newInstance(2025, 8, 1);
        Date date2 = date1.addDays(30); // not within next 30 days

        Date result = VerifyDate.CheckDates(date1, date2);
        
        Date expectedEndOfMonth = Date.newInstance(2025, 8, 31);
        System.assertEquals(expectedEndOfMonth, result, 'Should return end of month when date2 is >= 30 days away');
    }
}

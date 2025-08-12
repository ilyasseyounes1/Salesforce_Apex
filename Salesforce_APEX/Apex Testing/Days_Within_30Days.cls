@isTest
private class TestVerifyDate {

    @isTest
    static void testWithin30Days() {
        Date date1 = Date.newInstance(2025, 8, 1);
        Date date2 = date1.addDays(10); // within 30 days
        Test.startTest();
            Date result = VerifyDate.CheckDates(date1, date2);
        Test.stopTest();
        System.assertEquals(date2, result, 'Should return date2 when within 30 days');
    }

    @isTest
    static void testDateInPastReturnsEndOfMonth_February() {
        // Use February (28 days in 2025) to ensure SetEndOfMonthDate works for 28-day month
        Date date1 = Date.newInstance(2025, 2, 15);
        Date date2 = date1.addDays(-5); // in the past
        Date expected = Date.newInstance(2025, 2, 28);

        Test.startTest();
            Date result = VerifyDate.CheckDates(date1, date2);
        Test.stopTest();
        System.assertEquals(expected, result, 'Past date2 should return end-of-month for date1');
    }

    @isTest
    static void testExactly30DaysReturnsEndOfMonth() {
        Date date1 = Date.newInstance(2025, 8, 1);
        Date date2 = date1.addDays(30); // exactly 30 days away -> should NOT be considered within 30 days
        Date expected = Date.newInstance(2025, 8, 31);

        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(expected, result, 'date2 exactly 30 days after date1 should return end-of-month');
    }

    @isTest
    static void testDateEqualsDate1ReturnsDate2() {
        Date date1 = Date.newInstance(2025, 8, 10);
        Date date2 = date1; // same day -> within 30 days
        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(date2, result, 'When date2 equals date1, CheckDates should return date2');
    }
}

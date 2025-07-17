public class DiscountManager {
    
    @TestVisible private static Decimal internalDiscountRate = 0.10;

    public static Decimal calculatePrice(Decimal price) {
        return price - (price * internalDiscountRate);
    }

    @TestVisible private static void setDiscountRate(Decimal rate) {
        internalDiscountRate = rate;
    }
}
//---------------------
@isTest
private class DiscountManagerTest {
    static testMethod void testCalculatePrice() {
        DiscountManager.setDiscountRate(0.20);  // Accessible due to @TestVisible
        Decimal price = DiscountManager.calculatePrice(100);
        System.assertEquals(80, price);
    }
}

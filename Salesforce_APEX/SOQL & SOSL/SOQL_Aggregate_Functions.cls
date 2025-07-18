public class SOQLAggregateExample {

    // Method to demonstrate COUNT function
    // This counts the total number of Account records in the database
    public static void countAccounts() {
        AggregateResult[] results = [SELECT COUNT(Id) totalAccounts FROM Account];
        System.debug('Total Accounts: ' + results[0].get('totalAccounts'));
    }

    // Method to demonstrate COUNT_DISTINCT function
    // This counts the number of unique Account Owners in the database
    public static void countUniqueOwners() {
        AggregateResult[] results = [SELECT COUNT_DISTINCT(OwnerId) uniqueOwners FROM Account];
        System.debug('Unique Owners: ' + results[0].get('uniqueOwners'));
    }

    // Method to demonstrate SUM function
    // This calculates the total revenue from opportunities that are closed won
    public static void sumOpportunities() {
        AggregateResult[] results = [SELECT SUM(Amount) totalAmount FROM Opportunity WHERE StageName = 'Closed Won'];
        System.debug('Total Revenue: ' + results[0].get('totalAmount'));
    }

    // Method to demonstrate AVG function
    // This calculates the average deal size across all opportunities
    public static void averageDealSize() {
        AggregateResult[] results = [SELECT AVG(Amount) averageDeal FROM Opportunity];
        System.debug('Average Deal Size: ' + results[0].get('averageDeal'));
    }

    // Method to demonstrate MIN & MAX functions
    // This finds the smallest and largest opportunity amounts
    public static void minMaxOpportunityAmount() {
        AggregateResult[] results = [SELECT MIN(Amount) minAmount, MAX(Amount) maxAmount FROM Opportunity];
        System.debug('Smallest Deal: ' + results[0].get('minAmount'));
        System.debug('Largest Deal: ' + results[0].get('maxAmount'));
    }

    // Method to demonstrate GROUP BY with SUM function
    // This groups opportunities by stage and calculates the total revenue per stage
    public static void groupByStageRevenue() {
        AggregateResult[] groupedResults = [SELECT StageName, SUM(Amount) totalRevenue FROM Opportunity GROUP BY StageName];
        for (AggregateResult ar : groupedResults) {
            System.debug('Stage: ' + ar.get('StageName') + ', Revenue: ' + ar.get('totalRevenue'));
        }
    }

    // Method to demonstrate HAVING clause with GROUP BY
    // This filters out opportunity stages where total revenue is below 1 million
    public static void filterByRevenue() {
        AggregateResult[] results = [SELECT StageName, SUM(Amount) totalRevenue FROM Opportunity GROUP BY StageName HAVING SUM(Amount) > 1000000];
        for (AggregateResult ar : results) {
            System.debug('Stage: ' + ar.get('StageName') + ', Revenue: ' + ar.get('totalRevenue'));
        }
    }

    // Method to demonstrate multiple aggregate functions in one query
    // This calculates total opportunities, total revenue, and average deal size in one query
    public static void multipleAggregates() {
        AggregateResult[] results = [SELECT COUNT(Id) totalOpportunities, SUM(Amount) totalRevenue, AVG(Amount) avgDealSize FROM Opportunity];
        System.debug('Total Opportunities: ' + results[0].get('totalOpportunities'));
        System.debug('Total Revenue: ' + results[0].get('totalRevenue'));
        System.debug('Average Deal Size: ' + results[0].get('avgDealSize'));
    }

    // Main method to call all implementations
    // This runs all the above queries in sequence
    public static void runAllQueries() {
        countAccounts();
        countUniqueOwners();
        sumOpportunities();
        averageDealSize();
        minMaxOpportunityAmount();
        groupByStageRevenue();
        filterByRevenue();
        multipleAggregates();
    }
}

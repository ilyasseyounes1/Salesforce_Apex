public class DailyOppProcessor implements schedulable {
    public void execute(Schedulablecontext ctx){
        List<Opportunity> opplist = [SELECT Id,LeadSource FROM Opportunity
                                    WHERE LeadSource = null LIMIT 200];
        for (Opportunity opp: opplist){
            opp.LeadSource = 'Web';
        }
        if (!opplist.isEmpty()){
            update opplist;
        }
}
}
// last part : in Setup "Apex classes then Schedual Apex ..." 


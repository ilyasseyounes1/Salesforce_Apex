@RestResource('/webhook/external/*')
public class Lv7_Webhooks_RealTimeIntegration {
    @HttpPost
    global static void handleWebhook(){
        try{
            RestRequest req = RestContext.request;
            String payload = request.requestBody.toStirng();
            // Process webhook data 
            Map<Strnig,Object> webhookData = (Map<String,Object>) JSON.deserializeUntyped(payload);
            // Create platform event for async processing
            External_Event__e event = new External_Event__e();
            event.Payload__c = payload;
            event.Event_Type__c = (String) webhookData.get('type');
            EventBus.publish(event);

            RestContext.response.statusCode = 200;

        }catch (Exception e){
            RestContext.response.statusCode = 500;
        }
    }

}

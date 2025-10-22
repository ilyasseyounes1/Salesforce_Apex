public class SimpleEmailService {

    public class EmailInput {
        @InvocableVariable(required=true label='To Email')
        public String toEmail;

        @InvocableVariable(required=true label='Subject')
        public String subject;

        @InvocableVariable(required=true label='Body')
        public String body;
    }

    public class EmailOutput {
        @InvocableVariable(label='Success')
        public Boolean success;
        
        @InvocableVariable(label='Error')
        public String error;
    }

    @InvocableMethod(label='Send Simple Email' description='Send basic email from Flow')
    public static List<EmailOutput> sendEmail(List<EmailInput> inputs) {
        List<EmailOutput> results = new List<EmailOutput>();

        for (EmailInput i : inputs) {
            EmailOutput r = new EmailOutput();
            try {
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setToAddresses(new String[]{ i.toEmail });
                msg.setSubject(i.subject);
                msg.setPlainTextBody(i.body);

                Messaging.SendEmailResult[] sendResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ msg });

                r.success = sendResult[0].isSuccess();
                r.error = r.success ? null : sendResult[0].getErrors()[0].getMessage();
            } catch (Exception e) {
                r.success = false;
                r.error = e.getMessage();
            }
            results.add(r);
        }
        return results;
    }
}

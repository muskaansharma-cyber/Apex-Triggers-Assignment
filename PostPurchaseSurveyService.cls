public class PostPurchaseSurveyService {

    @future(callout=true)
    public static void sendSurvey(List<Id> orderIds) {
        List<Order> orders = [SELECT Id, Name, AccountId FROM Order WHERE Id IN :orderIds];

        for (Order ord : orders) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://jsonplaceholder.typicode.com/posts'); // Mock API
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            String body = JSON.serialize(new Map<String, Object>{
                'orderId' => ord.Id,
                'orderName' => ord.Name,
                'accountId' => ord.AccountId,
                'surveyLink' => 'https://example.com/survey?orderId=' + ord.Id
            });

            req.setBody(body);

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
            } catch (CalloutException e) {
                System.debug('Callout error: ' + e.getMessage());
            }
        }
    }
}

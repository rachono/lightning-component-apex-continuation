global with sharing class ContinuationController {

    public ContinuationController() {
        String hostname = URL.getSalesforceBaseUrl().getHost();
        String mydomain = hostname.substring(0, hostname.indexOf('--c'));
        String lcBaseURL = 'https://' + mydomain + '.lightning.force.com';
        Apexpages.currentPage().getHeaders().put('X-Frame-Options', 'ALLOW-FROM ' + lcBaseURL);
        Apexpages.currentPage().getHeaders().put('Content-Security-Policy', 'frame-ancestors ' + lcBaseURL);
    }

    @AuraEnabled
    public static String getVFBaseURL() {
        List<String> fragments = URL.getSalesforceBaseUrl().getHost().split('\\.');
        return 'https://' + fragments[0] + '--c.' + fragments[1] + '.visual.force.com';
    }

    // Called via JavaScript Remoting
    @RemoteAction
    global static Object invoke(String methodName, String[] params) {

        if (methodName == 'count') {
            // Make an HTTPRequest as we normally would
            // Remember to configure a Remote Site Setting for the service!
            String url = 'https://node-count.herokuapp.com/' + params[0];
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);

            // Create a Continuation for the HTTPRequest        
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(req);
            con.continuationMethod = 'callback';        

            // Return it to the system for processing
            return con;
        } else {
            return null;
        }
    }

    global static Object callback(Object state) {
        HttpResponse response = Continuation.getResponse((String)state);

        Integer statusCode = response.getStatusCode();
        if (statusCode >= 2000) {
            return 'Continuation error: ' + statusCode;
        }

        return response.getBody();
    }

}
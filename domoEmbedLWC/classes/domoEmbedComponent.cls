public with sharing class domoEmbedComponent {

    @AuraEnabled(cacheable=true)
    public static String fetchToken(String embed_type, String embed_id, String filter_column, String filter_value){
        // these would ideally not be hard-coded but stored in custom settings or metadata
        // or I like to store them in two encrypted fields on the user who generated them
        final String client_id = 'client_id';
        final String client_secret = 'client_secret';

        // response
        String embedToken = '';

        /////////////////////////////////////////////////////////////
        //   STEP 1: Authorize using client ID and secret
        /////////////////////////////////////////////////////////////
        
        // don't forget to add api.domo.com to your remote site settings
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.domo.com/oauth/token?grant_type=client_credentials&scope=data%20audit%20user%20dashboard');
        req.setMethod('POST');

        // basic authorization header
        Blob headerValue = Blob.valueOf(client_id + ':' + client_secret);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        // send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // strip out our access_token
        Map<String, Object> resMap =(Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String token = String.valueOf(resMap.get('access_token'));

        // you may wish to do some error handling with the status
        system.debug(res.getStatusCode() + ': ' + res.getStatus());

        /////////////////////////////////////////////////////////////
        //   STEP 2: Embed authentication and possible filtering
        /////////////////////////////////////////////////////////////

        HttpRequest req2 = new HttpRequest();
        if(embed_type!='card')
            req2.setEndpoint('https://api.domo.com/v1/stories/embed/auth');
        else
            req2.setEndpoint('https://api.domo.com/v1/cards/embed/auth');
        req2.setMethod('POST');

        // this time we send our token from above for authorization
        req2.setHeader('Authorization', 'bearer ' + token);
        req2.setHeader('Content-Type', 'application/json');

        // the body will be JSON, this is a super simple example. For more on this including how to filter
        // visit: https://developer.domo.com/docs/embed-token-api-reference/embed-token-api-reference
        // also, Apex has a JSON class that is helpful if you want to store filters in apex objects and
        // convert to JSON easily: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm
        
        // Build the JSON payload with optional filters (matching Visualforce example structure)
        // Structure: { sessionLength: 1440, authorizations: [{ token, permissions, filters: [] or [{column, operator, values}] }] }
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeNumberField('sessionLength', 1440);
        gen.writeFieldName('authorizations');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('token', embed_id);
        gen.writeFieldName('permissions');
        gen.writeStartArray();
        gen.writeString('READ');
        gen.writeString('FILTER');
        gen.writeString('EXPORT');
        gen.writeEndArray();
        gen.writeFieldName('filters');
        gen.writeStartArray();
        // Add filter if filter_column and filter_value are provided (matching Visualforce: recordId ? [{...}] : [])
        if (String.isNotBlank(filter_column) && String.isNotBlank(filter_value)) {
            gen.writeStartObject();
            gen.writeStringField('column', filter_column);
            gen.writeStringField('operator', 'IN');
            gen.writeFieldName('values');
            gen.writeStartArray();
            gen.writeString(filter_value);
            gen.writeEndArray();
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        String payload = gen.getAsString();
        system.debug('Domo Embed Payload: ' + payload);
        req2.setBody(payload);

        // make the call
        http = new Http();
        HttpResponse res2 = http.send(req2);
        
        // again, may want to check the status and handle failure
        system.debug(res2.getStatusCode() + ': ' + res2.getStatus());
        system.debug(res2.getBody());

        // we pull out our token (yay)
        resMap = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());
        embedToken = String.valueOf(resMap.get('authentication'));

        return embedToken;
    }
}


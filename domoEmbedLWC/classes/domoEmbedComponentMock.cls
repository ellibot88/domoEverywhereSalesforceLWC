@isTest
global class domoEmbedComponentMock implements HttpCalloutMock {
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        
        // Mock response for OAuth token request
        if (req.getEndpoint().contains('oauth/token')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "mock_access_token_12345", "token_type": "Bearer", "expires_in": 3600}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        // Mock response for card embed auth
        else if (req.getEndpoint().contains('v1/cards/embed/auth')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"authentication": "mock_embed_token_card_67890"}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        // Mock response for story/dashboard embed auth
        else if (req.getEndpoint().contains('v1/stories/embed/auth')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"authentication": "mock_embed_token_story_67890"}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        // Default error response
        else {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "Unknown endpoint"}');
            res.setStatusCode(404);
            res.setStatus('Not Found');
        }
        
        return res;
    }
}


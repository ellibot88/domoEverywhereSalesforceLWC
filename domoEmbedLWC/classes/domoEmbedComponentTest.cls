@isTest
private class domoEmbedComponentTest {
    
    @isTest
    static void testFetchTokenForCard() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data
        String embedType = 'card';
        String embedId = 'test-card-id-123';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, null, null);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_card_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenForDashboard() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data
        String embedType = 'dashboard';
        String embedId = 'test-dashboard-id-456';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, null, null);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_story_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenForStory() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data - any type other than 'card' should use stories endpoint
        String embedType = 'story';
        String embedId = 'test-story-id-789';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, null, null);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_story_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenWithFilter() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data with filter
        String embedType = 'dashboard';
        String embedId = 'test-dashboard-id-456';
        String filterColumn = 'Account.Id';
        String filterValue = '001000000000001AAA';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, filterColumn, filterValue);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_story_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenWithFilterForCard() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data with filter for card
        String embedType = 'card';
        String embedId = 'test-card-id-123';
        String filterColumn = 'Contact.Email';
        String filterValue = 'test@example.com';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, filterColumn, filterValue);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_card_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenWithNullFilterValues() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data with null filter values (should work without filters)
        String embedType = 'dashboard';
        String embedId = 'test-dashboard-id-456';
        String filterColumn = null;
        String filterValue = null;
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, filterColumn, filterValue);
        Test.stopTest();
        
        // Assertions - should work without filters
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_story_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenWithEmptyFilterValues() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data with empty filter values (should work without filters)
        String embedType = 'card';
        String embedId = 'test-card-id-123';
        String filterColumn = '';
        String filterValue = '';
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, filterColumn, filterValue);
        Test.stopTest();
        
        // Assertions - should work without filters when values are empty
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_card_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenWithPartialFilterValues() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        // Test data with only filter column (no value) - should not apply filter
        String embedType = 'dashboard';
        String embedId = 'test-dashboard-id-456';
        String filterColumn = 'Account.Id';
        String filterValue = null;
        
        // Call the method
        Test.startTest();
        String embedToken = domoEmbedComponent.fetchToken(embedType, embedId, filterColumn, filterValue);
        Test.stopTest();
        
        // Assertions - should work without filter when value is null
        System.assertNotEquals(null, embedToken, 'Embed token should not be null');
        System.assertEquals('mock_embed_token_story_67890', embedToken, 'Embed token should match mock response');
    }
    
    @isTest
    static void testFetchTokenCacheable() {
        // Verify the method is cacheable by checking it can be called multiple times
        Test.setMock(HttpCalloutMock.class, new domoEmbedComponentMock());
        
        String embedType = 'card';
        String embedId = 'test-card-id-123';
        
        Test.startTest();
        String token1 = domoEmbedComponent.fetchToken(embedType, embedId, null, null);
        String token2 = domoEmbedComponent.fetchToken(embedType, embedId, null, null);
        Test.stopTest();
        
        // Both calls should return the same token
        System.assertEquals(token1, token2, 'Cacheable method should return consistent results');
    }
}


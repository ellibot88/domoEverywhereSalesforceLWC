import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchToken from '@salesforce/apex/domoEmbedComponent.fetchToken';

export default class DomoEverywhere extends LightningElement {

    @api embedType;
    @api embedId;
    @api frameHeight;
    @api filterColumn; // Domo column to filter on (e.g., 'Id', 'Account.Id')
    @api filterValueField; // Salesforce field API name to get filter value from (e.g., 'Id', 'AccountId')

    // recordId is automatically available on record pages
    @api recordId;

    filterValue;
    recordDataLoaded = false;

    get actionURL() {
        var ret = "https://public.domo.com/";
        if(this.embedType=="card"){
            ret+= "cards";
        }
        else{
            ret+= "embed/pages";
        }
        ret+= "/" + this.embedId;
        return ret;
    }

    // Build the field path for getRecord
    // If filterValueField includes '.', use it as-is (e.g., "Account.Id")
    // Otherwise, construct it with the current object API name
    get recordFields() {
        if (!this.filterValueField || !this.recordId) {
            return [];
        }
        
        // If field already includes object (e.g., "Account.Id"), use as-is
        if (this.filterValueField.includes('.')) {
            return [this.filterValueField];
        }
        
        // For fields on the current record, try to get object API name from URL
        // This works when the component is on a record page
        if (this.recordId && window.location) {
            const pathMatch = window.location.pathname.match(/\/lightning\/r\/([^\/]+)\//);
            if (pathMatch && pathMatch[1]) {
                const objectApiName = pathMatch[1];
                return [objectApiName + '.' + this.filterValueField];
            }
        }
        
        // Fallback: return just the field name (will work if it's a direct field on the record)
        // User should provide full field path like "Account.Id" for relationship fields
        return [this.filterValueField];
    }

    // Wire adapter to get record field value
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: '$recordFields'
    })
    wiredRecord({ error, data }) {
        if (data && this.filterValueField) {
            try {
                // Determine the field path
                const fieldPath = this.filterValueField.includes('.') 
                    ? this.filterValueField 
                    : this.filterValueField;
                
                const fieldParts = fieldPath.split('.');
                let fieldData = data.fields;
                
                // Navigate through the field path
                for (let i = 0; i < fieldParts.length; i++) {
                    if (fieldData && fieldData[fieldParts[i]]) {
                        fieldData = fieldData[fieldParts[i]];
                    } else {
                        fieldData = null;
                        break;
                    }
                }
                
                // Extract the value
                if (fieldData) {
                    this.filterValue = fieldData.value !== undefined ? String(fieldData.value) : String(fieldData);
                    this.recordDataLoaded = true;
                } else {
                    this.filterValue = null;
                    this.recordDataLoaded = true; // Mark as loaded even if value is null
                }
            } catch (e) {
                console.error('Error extracting field value:', e);
                this.filterValue = null;
                this.recordDataLoaded = true;
            }
        } else if (error) {
            console.error('Error loading record:', error);
            this.filterValue = null;
            this.recordDataLoaded = true;
        } else if (!this.filterValueField) {
            // No filter configured, mark as loaded so we can proceed
            this.recordDataLoaded = true;
        }
    }

    // Computed property to determine if we should fetch the token
    // Only fetch if:
    // 1. We have embedId
    // 2. If filterColumn is configured, we must have filterValue ready
    // 3. Record data must be loaded (if filtering is configured)
    get shouldFetchToken() {
        const hasEmbedId = !!this.embedId;
        const hasFilterColumn = !!this.filterColumn;
        const hasFilterValue = this.filterValue !== null && this.filterValue !== undefined && this.filterValue !== '';
        
        // If filtering is configured, wait for record data to load and filterValue to be ready
        if (hasFilterColumn) {
            return hasEmbedId && this.recordDataLoaded && hasFilterValue;
        }
        
        // If no filtering, just need embedId
        return hasEmbedId;
    }

    // Get the filter value to pass to Apex - only return it if we're ready
    // This ensures the wire service doesn't run with null filterValue when filtering is configured
    get readyFilterValue() {
        // If filtering is configured, wait for record data to load
        if (this.filterColumn) {
            // If record data hasn't loaded yet, return undefined to prevent wire from running
            if (!this.recordDataLoaded) {
                return undefined;
            }
            // Once loaded, return the filterValue (empty string if null, so Apex knows no filter)
            return this.filterValue || '';
        }
        // If no filtering configured, return empty string immediately
        return '';
    }

    // Wire adapter for fetching token with filter parameters
    // The wire service will only run when readyFilterValue is defined (not undefined)
    // This ensures filterValue is ready before the API call is made
    @wire(fetchToken, { 
        embed_type: '$embedType', 
        embed_id: '$embedId',
        filter_column: '$filterColumn',
        filter_value: '$readyFilterValue'
    })
    embedToken;

    get isLoading() {
        return !this.embedToken || (!this.embedToken.data && !this.embedToken.error);
    }

    get hasError() {
        return this.embedToken && this.embedToken.error;
    }

    get errorMessage() {
        if (this.embedToken && this.embedToken.error) {
            return this.embedToken.error.body ? this.embedToken.error.body.message : 'An error occurred while loading the content.';
        }
        return '';
    }

    renderedCallback() {
        // Submit form whenever embedId is available (similar to original behavior)
        // This allows the form to resubmit when record changes
        if (this.embedId != null) {
            const form = this.template.querySelector('form');
            if (form) {
                form.submit();
            }
        }
    }

}


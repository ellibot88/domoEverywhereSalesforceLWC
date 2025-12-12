# Domo Everywhere LWC with Filtering

This Lightning Web Component embeds a Domo dashboard or card with dynamic filtering support based on the current Salesforce record.

## Features

- Embed Domo dashboards or cards
- Dynamic filtering based on the current record
- Configurable filter column (from Domo) and filter value field (from Salesforce)
- Automatically extracts filter value from the record the component is placed on

## Setup

1. **Update the Apex Class** (`domoEmbedComponent.cls`):
   - Replace `ENTER YOUR CLIENT ID HERE` with your Domo client ID
   - Replace `ENTER YOUR CLIENT SECRET HERE` with your Domo client secret

2. **Add Remote Site Settings**:
   - Go to Setup → Remote Site Settings
   - Add `https://api.domo.com` as a new remote site

3. **Deploy the Component**:
   ```bash
   sf project deploy start --source-dir force-app --target-org your-org-alias
   ```

## Usage

1. **Add the Component to a Record Page**:
   - Edit the record page (e.g., Account, Contact, etc.)
   - Add the "Domo Everywhere" component
   - Configure the component properties:
     - **Content**: Select "card" or "dashboard"
     - **Embed Id**: Enter your 5-character Domo embed ID
     - **Height in pixels**: Set the iframe height (e.g., 600)
     - **Filter Column**: Enter the Domo column to filter on (e.g., "Id", "Account.Id")
     - **Filter Value Field**: Enter the Salesforce field API name to get the filter value from (e.g., "Id", "AccountId", "Account.Id")

2. **Example Configuration**:
   - **Filter Column**: `Id` (the Domo column name)
   - **Filter Value Field**: `Id` (if on Account page, gets the Account.Id value)
   - Or for related records:
   - **Filter Column**: `Account.Id` (the Domo column name)
   - **Filter Value Field**: `AccountId` (if on Contact page, gets the Contact's AccountId)

## How It Works

1. The component automatically gets the `recordId` from the Lightning Record Page context
2. It uses the Lightning Record API to fetch the field value specified in `filterValueField`
3. The filter value is passed to the Apex class along with the `filterColumn`
4. The Apex class builds a JSON payload with filters (matching the Visualforce example structure)
5. The filtered embed token is generated and used to load the Domo dashboard

## Filter Payload Structure

The component generates a filter payload matching the Visualforce example:
```json
{
  "sessionLength": 1440,
  "authorizations": [{
    "token": "embed_id",
    "permissions": ["READ", "FILTER", "EXPORT"],
    "filters": [{
      "column": "Id",
      "operator": "IN",
      "values": ["record_id_value"]
    }]
  }]
}
```

## Notes

- The component automatically resubmits the form when the record changes
- If no filter is configured, the dashboard loads without filtering
- For relationship fields, provide the full field path (e.g., "Account.Id")
- The filter operator is always "IN" (matching the Visualforce example)

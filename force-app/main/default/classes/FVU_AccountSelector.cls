/**
 * The FVU_AccountSelector class provides methods to retrieve account data from Salesforce.
 */
public with sharing class FVU_AccountSelector {

    public FVU_AccountSelector() { }

    // Retrieves account information for the Id Claro application based on the provided Account Id.
    public Account getAccountIdClaroData(String accountId) {
        List<Account> accountList = [
            SELECT Name, LastName, Id, FVU_DocumentNumber__c, FVU_DocumentType__c, FVU_AccountExternalID__c, FVU_SecondLastName__c, Phone, FVU_Email__c, vlocity_cmt__PrimaryContactId__r.FirstName, vlocity_cmt__PrimaryContactId__r.LastName, vlocity_cmt__PrimaryContactId__r.FVU_SecondLastName__c, vlocity_cmt__PrimaryContactId__r.FVU_Antiquity__c, vlocity_cmt__PrimaryContactId__r.FVU_ExpeditionDate__c, vlocity_cmt__PrimaryContactId__r.FVU_ExpeditionSite__c
            FROM Account 
            WHERE Id = :accountId 
            LIMIT 1
        ];
        
        

        return (accountList.isEmpty()) ? null : accountList[0];

    }
}
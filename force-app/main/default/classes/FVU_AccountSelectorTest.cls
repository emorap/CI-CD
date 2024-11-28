/**
 * This is a test class for the FVU_AccountSelector class.
 */
@IsTest
public with sharing class FVU_AccountSelectorTest {

    @IsTest
    private static void getAccountIdClaroDataTest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.FVU_DocumentType__c = 'CC';
        acc.FVU_DocumentNumber__c = '123456789';
        insert acc;

        // Call the getAccountIdClaroData method to retrieve the Account
        Account account = new FVU_AccountSelector().getAccountIdClaroData(acc.Id);

        // Verify that the retrieved Account is not null
        System.assertNotEquals(account, null, 'Account is null');

        // Verify that the FVU_DocumentNumber__c field of the retrieved Account matches the expected value
        System.assertEquals(account.FVU_DocumentNumber__c, '123456789', 'Account FVU_DocumentNumber__c is wrong');
    }
}
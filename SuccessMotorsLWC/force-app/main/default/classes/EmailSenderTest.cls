@isTest
public class EmailSenderTest {
    @TestSetup
    public static void createData(){
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = date.today() + 3);
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@email.com', Phone = '80219119911');
        insert opportunity;
        insert contact;
        OpportunityContactRole oppContRole = new OpportunityContactRole(OpportunityId = opportunity.Id,
         ContactId = contact.Id, IsPrimary = true);
        insert oppContRole;
    }

    @isTest
    public static void opportunityDBTest(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];

        Test.startTest();
        Opportunity result = EmailSender.opportunityDB(opportunity.Id);
        Test.stopTest();

        System.assertEquals(opportunity.Invoice_Number__c, result.Invoice_Number__c, 'Incorrect Invoice Number');
    }

    @isTest
    public static void contactDBTest(){
        Opportunity opportunity = [SELECT Name, Id FROM Opportunity WHERE Name = 'Test Opportunity'];
        OpportunityContactRole opportunityContact = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id AND IsPrimary = true LIMIT 1];

        Test.startTest();
        Contact result = EmailSender.contactDB(opportunity.Id);
        Test.stopTest();

        System.assertEquals(result.Id, opportunityContact.ContactId, 'Incorrect Contact Id');
    }

    @isTest
    public static void getMessageBodyTest(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];

        Test.startTest();
        String result = EmailSender.getMessageBody(opportunity.Id);
        Test.stopTest();

        Pattern pattern = Pattern.compile(opportunity.Invoice_Number__c);
        System.assert(pattern.matcher(result).find(), 'Incorrect message body');
    }

    
    @isTest
    public static void sendEmailTest(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];

        Test.startTest();
        Boolean result = EmailSender.sendEmail(opportunity.Id, 'Body');
        Test.stopTest();

        System.assert(result, 'Message send error');
    }

    @isTest
    public static void createMessageTestPositive(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        Contact contact = [SELECT Email, Name, Id FROM Contact WHERE Name = 'Test Contact'];
        ContentVersion contVers = new ContentVersion(ContentLocation = 'S', PathOnClient = opportunity.Invoice_Number__c + '.pdf',
         Title = opportunity.Invoice_Number__c, VersionData = Blob.valueOf('Data'));
        insert contVers;

        Test.startTest();
        Messaging.SingleEmailMessage result = EmailSender.createMessage(opportunity, contact, 'Body');
        Test.stopTest();

        System.assertEquals(contact.Email, result.getToAddresses()[0], 'Incorrect to Adress');
        System.assertEquals(opportunity.Invoice_Number__c, result.getSubject(), 'Incorrect subject');
        System.assertEquals('Invoice Confirmation', result.getSenderDisplayName(), 'Incorrect sender name');
        System.assertEquals('Body', result.getPlainTextBody(), 'Incorrect body');
        System.assertNotEquals(null, result.getFileAttachments(), 'Incorrect attachment');
    }

    @isTest
    public static void createMessageTestNegative(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        Contact contact = [SELECT Email, Name, Id FROM Contact WHERE Name = 'Test Contact'];

        Test.startTest();
        Messaging.SingleEmailMessage result = EmailSender.createMessage(opportunity, contact, 'Body');
        Test.stopTest();

        System.assertEquals(contact.Email, result.getToAddresses()[0], 'Incorrect to Adress');
        System.assertEquals(opportunity.Invoice_Number__c, result.getSubject(), 'Incorrect subject');
        System.assertEquals('Invoice Confirmation', result.getSenderDisplayName(), 'Incorrect sender name');
        System.assertEquals('Body', result.getPlainTextBody(), 'Incorrect body');
    }

    @isTest
    public static void createAttachmentTest(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        ContentVersion contVers = new ContentVersion(ContentLocation = 'S', PathOnClient = opportunity.Invoice_Number__c + '.pdf',
         Title = opportunity.Invoice_Number__c, VersionData = Blob.valueOf('Data'));
        insert contVers;

        Test.startTest();
        Messaging.EmailFileAttachment result = EmailSender.createAttachment(opportunity);
        Test.stopTest();

        System.assertEquals(result.filename, opportunity.Invoice_Number__c + '.pdf', 'Incorrect filename');
    }

    @isTest
    public static void invoiceDBTest(){
        Opportunity opportunity = [SELECT Name, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opportunity'];
        ContentVersion contVers = new ContentVersion(ContentLocation = 'S', PathOnClient = opportunity.Invoice_Number__c + '.pdf',
         Title = opportunity.Invoice_Number__c, VersionData = Blob.valueOf('Data'));
        insert contVers;
        Id objId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVers.Id].ContentDocumentId;
        ContentDocumentLink contDocLink = new ContentDocumentLink(ContentDocumentId = objId, LinkedEntityId = opportunity.Id, shareType = 'V');
        insert contDocLink;

        Test.startTest();
        String result = EmailSender.invoiceDB(opportunity.Id);
        Test.stopTest();

        System.assertEquals(result, objId, 'Incorrect content document Id');
    }

    @isTest
    public static void updateOpportunityPositiveTest(){
        Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity'];

        Test.startTest();
        Database.SaveResult result = EmailSender.updateOpportunity(opportunity.Id);
        Test.stopTest();

        Opportunity opportunityResult = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunity.Id];
        System.assert(result.isSuccess(), 'Opportunity update error');
        System.assertEquals('Qualification', opportunityResult.StageName, 'Incorrect Stage Name');
    }

    @isTest
    public static void updateOpportunityNegativeTest(){
        Opportunity opportunity = new Opportunity(Name = 'Negative Test Opportunity', StageName = 'Closed Won', CloseDate = date.today() + 3);
        insert opportunity;

        Test.startTest();
        Database.SaveResult result = EmailSender.updateOpportunity(opportunity.Id);
        Test.stopTest();

        Opportunity opportunityResult = [SELECT Id, StageName FROM Opportunity WHERE Id = : opportunity.Id];
        System.assert(result.isSuccess(), 'Opportunity update error');
        System.assertEquals('Closed Won', opportunityResult.StageName, 'Incorrect Stage Name');
    }
}

@isTest
public class CreatePDFInvoiceTest {
    
    @TestSetup
    public static void createData(){
        Opportunity opportunity = new Opportunity(Name = 'Test', StageName = 'Prospecting', CloseDate = date.today() + 3);
        insert opportunity;
    }

    @isTest
    public static void generatePdfBodyTest(){
        Opportunity opportunity = [SELECT Name, CloseDate, Id FROM Opportunity WHERE Name = 'Test'];

        Test.startTest();
        Blob pdf = CreatePDFInvoice.generatePdfBody(opportunity);
        Test.stopTest();

        System.assertNotEquals(null, pdf, 'Document wasn\'t created');
    }

    @isTest
    public static void createContentVersionTest(){
        Opportunity opportunity = [SELECT Name, CloseDate, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test'];

        Test.startTest();
        ContentVersion contentVersion = CreatePDFInvoice.createContentVersion(opportunity, CreatePDFInvoice.generatePdfBody(opportunity));
        Test.stopTest();

        System.assertEquals(opportunity.Invoice_Number__c + '.pdf', contentVersion.PathOnClient, 'Incorrect path on client');
        System.assertEquals(opportunity.Invoice_Number__c , contentVersion.Title, 'Incorrect title');
        System.assertEquals(CreatePDFInvoice.generatePdfBody(opportunity), contentVersion.VersionData, 'Incorrect data');
    }
    
    @isTest
    public static void createContentDocumentLinkTest(){
        Opportunity opportunity = [SELECT Name, CloseDate, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test'];

        Test.startTest();
        ContentDocumentLink contentLink = CreatePDFInvoice.createContentDocumentLink(opportunity, null);
        Test.stopTest();

        System.assertEquals(opportunity.Id, contentLink.LinkedEntityId, 'Incorrect linked entity Id');
        System.assertEquals('V', contentLink.shareType, 'Incorrect share type');
        System.assertEquals(null, contentLink.ContentDocumentId, 'Incorrect content document Id');
    }

    @isTest
    public static void generatePdfTestCreatePdfVersion(){
        Opportunity opportunity = [SELECT Name, CloseDate, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test'];

        Test.startTest();
        Id resultId = CreatePDFInvoice.generatePdf(opportunity.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultId, 'Incorrect result Id');
    }

    
    @isTest
    public static void generatePdfTestUpdatePdfVersion(){
        Opportunity opportunity = [SELECT Name, CloseDate, Id, Invoice_Number__c FROM Opportunity WHERE Name = 'Test'];
        ContentVersion contentVersion = new ContentVersion(Title = opportunity.Invoice_Number__c, PathOnClient = opportunity.Invoice_Number__c + '.pdf', VersionData = CreatePDFInvoice.generatePdfBody(opportunity));
        insert contentVersion;

        Test.startTest();
        Id resultId = CreatePDFInvoice.generatePdf(opportunity.Id);
        Test.stopTest();

        System.assertNotEquals(contentVersion.ContentDocumentId, resultId, 'Incorrect result Id');
    }
}

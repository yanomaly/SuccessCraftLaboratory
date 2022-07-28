public with sharing class CreatePDFInvoice {
    
    @AuraEnabled
    public static Id generatePdf(String idOpportunity){
        Blob strPdfBody = null;
        Attachment objAttach = new Attachment();
        Opportunity objOpportunity = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :idOpportunity LIMIT 1];
        PageReference objPagePdf = Page.invoiceTemplate;
        objPagePdf.getParameters().put('Id', idOpportunity);
        strPdfBody = objPagePdf.getContent();

        ContentVersion objVersion = new ContentVersion();
        objVersion.ContentLocation = 'S';
        objVersion.PathOnClient = objOpportunity.Invoice_Number__c +'.pdf';
        objVersion.Title = objOpportunity.Invoice_Number__c;
        objVersion.VersionData = strPdfBody;
        insert objVersion;

        Id objDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objVersion.Id].ContentDocumentId;
        ContentDocumentLink objDocumentLink = New ContentDocumentLink();
        objDocumentLink.LinkedEntityId = objOpportunity.Id;
        objDocumentLink.ContentDocumentId = objDocId;
        objDocumentLink.shareType = 'V';
        insert objDocumentLink;
        return objDocumentLink.Id;
    }
}
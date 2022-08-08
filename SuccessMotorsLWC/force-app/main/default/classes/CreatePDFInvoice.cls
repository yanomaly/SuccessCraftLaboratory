public with sharing class CreatePDFInvoice {
    
    @AuraEnabled
    public static Id generatePdf(String idOpportunity){
        Opportunity objOpportunity = [SELECT Invoice_Number__c, Id FROM Opportunity WHERE Id = :idOpportunity LIMIT 1];
        Id objDocId;
        ContentVersion objVersion = createContentVersion(objOpportunity, generatePdfBody(objOpportunity));
        List<ContentVersion> objVersionList = [SELECT VersionData FROM ContentVersion WHERE Title = :objOpportunity.Invoice_Number__c AND IsMajorVersion = true];
        if(objVersionList.isEmpty()){
        insert objVersion;
        objDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objVersion.Id].ContentDocumentId;
        insert createContentDocumentLink(objOpportunity, objDocId);
        }
        else{
            objDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title =:objOpportunity.Invoice_Number__c AND IsMajorVersion = true].ContentDocumentId;
            objVersion.ContentDocumentId = objDocId;
            insert objVersion;
        }
        return objDocId;
    }

    public static ContentVersion createContentVersion(Opportunity objOpportunity, Blob content){
        ContentVersion objVersion = new ContentVersion();
        objVersion.ContentLocation = 'S';
        objVersion.PathOnClient = objOpportunity.Invoice_Number__c +'.pdf';
        objVersion.Title = objOpportunity.Invoice_Number__c;
        objVersion.VersionData = content;
        return objVersion;
    }

    public static Blob generatePdfBody(Opportunity objOpportunity){
        PageReference objPagePdf = Page.invoiceTemplate;
        objPagePdf.getParameters().put('Id', objOpportunity.Id);
        Blob pdfBody;
        if(Test.isRunningTest())
            pdfBody = Blob.valueOf('Unit.Test');
        else 
            pdfBody = objPagePdf.getContent();
        return pdfBody;
    }

    public static ContentDocumentLink createContentDocumentLink(Opportunity objOpportunity, Id objDocId){
        ContentDocumentLink objDocumentLink = New ContentDocumentLink();
        objDocumentLink.LinkedEntityId = objOpportunity.Id;
        objDocumentLink.ContentDocumentId = objDocId;
        objDocumentLink.shareType = 'V';
        return objDocumentLink;
    }
}
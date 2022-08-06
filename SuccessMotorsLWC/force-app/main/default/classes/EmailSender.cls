public with sharing class EmailSender {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity opportunityDB(String opportunityId){
        Opportunity opportunity = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        return opportunity;
    }

    @AuraEnabled(cacheable=true)
    public static Contact contactDB(String opportunityId){
        OpportunityContactRole opportunityContact = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunityId AND IsPrimary = true LIMIT 1];
        Contact contact = [SELECT Email, Name, Id FROM Contact WHERE Id = :opportunityContact.ContactId];

        return contact;
    }

    @AuraEnabled(cacheable=true)
    public static String getMessageBody(String opportunityId){
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate('00X5i000000MUOkEAO', contactDB(opportunityId).Id, opportunityId);

        return email.getHtmlBody();
    }

    @AuraEnabled
    public static Boolean sendEmail(String opportunityId, String body){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {createMessage(opportunityDB(opportunityId), contactDB(opportunityId), body)}); 
        return true;
    }

    
    public static Messaging.SingleEmailMessage createMessage(Opportunity opportunity, Contact contact, String body){
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{contact.Email}; 
        semail.setToAddresses(sendingTo); 
        semail.setSubject(opportunity.Invoice_Number__c); 
        semail.setPlainTextBody(body);
        semail.setReplyTo('invoiceconfirmation@f-1rk7dvztvq4q9uxx96occd147nvayv2h7o2mkl1j58wxds4jdf.5i-5oorbeay.ap26.apex.salesforce.com');
        semail.setSenderDisplayName('Invoice Confirmation');
        semail.setFileAttachments(new Messaging.EmailFileattachment[]{createAttachment(opportunity)});
        return semail;
    }

    
    public static Messaging.EmailFileAttachment createAttachment(Opportunity opportunity){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(opportunity.Invoice_Number__c + '.pdf');
        Blob pdfBody = [SELECT VersionData FROM ContentVersion WHERE PathOnClient =:opportunity.Invoice_Number__c + '.pdf' AND IsMajorVersion = true].VersionData;
        attachment.setBody(pdfBody); 
        return attachment;
    }

    @AuraEnabled
    public static String invoiceDB(String opportunityId){
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId];
        List<Id> fileIDs = new List<Id>();
        for (ContentDocumentLink docLink : files)
            fileIDs.add(docLink.ContentDocumentId);
        List<ContentVersion> res = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :fileIDs AND PathOnClient = :opportunityDB(opportunityId).Invoice_Number__c + '.pdf' LIMIT 1];
        return res[0].ContentDocumentId;
    }
}

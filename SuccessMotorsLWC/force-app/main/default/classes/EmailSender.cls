public with sharing class EmailSender {

    private static String REPLY_TO_ADRESS = 'invoiceconfirmation@f-1rk7dvztvq4q9uxx96occd147nvayv2h7o2mkl1j58wxds4jdf.5i-5oorbeay.ap26.apex.salesforce.com';
    private static String SENDER_DISPLAY_NAME = 'Invoice Confirmation';
    private static String EMAIL_TEMPLATE_NAME = 'Invoice Email';
    
    @AuraEnabled
    public static Boolean sendEmail(String opportunityId, String body){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {createMessage(opportunityDB(opportunityId), contactDB(opportunityId), body)}); 
        updateOpportunity(opportunityId);
        return true;
    }

    public static Messaging.SingleEmailMessage createMessage(Opportunity opportunity, Contact contact, String body){
        List<ContentVersion> verDat = [SELECT VersionData FROM ContentVersion WHERE PathOnClient =:opportunity.Invoice_Number__c + '.pdf' AND IsMajorVersion = true];
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{contact.Email}; 
        semail.setToAddresses(sendingTo); 
        semail.setSubject(opportunity.Invoice_Number__c); 
        semail.setPlainTextBody(body);
        semail.setReplyTo(REPLY_TO_ADRESS);
        semail.setSenderDisplayName(SENDER_DISPLAY_NAME);
        if(verDat.size() != 0)
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

    @AuraEnabled(cacheable=true)
    public static Opportunity opportunityDB(String opportunityId){
        Opportunity opportunity = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :opportunityId];
        return opportunity;
    }

    @AuraEnabled(cacheable=true)
    public static Contact contactDB(String opportunityId){
        OpportunityContactRole opportunityContact = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunityId AND IsPrimary = true];
        Contact contact = [SELECT Email, Name, Id FROM Contact WHERE Id = :opportunityContact.ContactId];
        return contact;
    }

    @AuraEnabled(cacheable=true)
    public static String getMessageBody(String opportunityId){
        EmailTemplate template = [SELECT Name, Id FROM EmailTemplate WHERE IsActive = true AND Name =: EMAIL_TEMPLATE_NAME LIMIT 1];
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id, contactDB(opportunityId).Id, opportunityId);
        return email.getHtmlBody();
    }

    public static Database.SaveResult updateOpportunity(String opportunityId){
        Opportunity opportunity = [SELECT StageName FROM Opportunity WHERE Id = :opportunityId];
        DescribeFieldResult optyDescribe = Schema.Opportunity.StageName.getDescribe(); 
        List<Schema.PicklistEntry> optyPickListEntry = optyDescribe.getPicklistValues();
        if(!opportunity.StageName.equals('Closed Won') && !opportunity.StageName.equals('Closed Lost'))
            for(Integer i = 0; i < optyPickListEntry.size() - 3; i++)
                if(optyPickListEntry[i].getLabel().equals(opportunity.StageName)){
                    opportunity.StageName = optyPickListEntry[i + 1].getLabel();
                    break;
                }
        return Database.update(opportunity);
    }

    @AuraEnabled
    public static String invoiceDB(String opportunityId){
        List<Id> fileIDs = new List<Id>();
        for (ContentDocumentLink docLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId])
            fileIDs.add(docLink.ContentDocumentId);
        ContentVersion res = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :fileIDs AND PathOnClient = :opportunityDB(opportunityId).Invoice_Number__c + '.pdf' LIMIT 1];
        return res.ContentDocumentId;
    }
}

import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';
import {NavigationMixin} from 'lightning/navigation'
import opportunityDB from '@salesforce/apex/EmailSender.opportunityDB';
import contactDB from '@salesforce/apex/EmailSender.contactDB';
import getMessageBody from '@salesforce/apex/EmailSender.getMessageBody';
import sendEmail from '@salesforce/apex/EmailSender.sendEmail';
import invoiceDB from '@salesforce/apex/EmailSender.invoiceDB';

export default class SendInvoice extends NavigationMixin (LightningElement) {
  @api recordId = '';
  @track invoiceId = ' ';
  @track emailBody = ' '
  @track contact = [];
  @track opportunity = [];

  @wire(contactDB, { opportunityId: '$recordId' })
  wiredContact(result) {
    if (result.data) {
  this.contact = result.data;
  console.log(this.contact);
    }else if (result.error) {
      this.errorHandler(result.error);
    }
  }

  @wire(opportunityDB, { opportunityId: '$recordId' })
  wiredOpportunity(result) {
    if (result.data) {
  this.opportunity = result.data;
  console.log(this.opportunity);
}else if (result.error) {
    this.errorHandler(result.error);
  }
}

  @wire(getMessageBody, { opportunityId: '$recordId' })
  wiredBody(result) {
    if (result.data) {
    this.emailBody = result.data.replace(/<[^>]+>/g, '').replace(/\n{2,}/, '');
    console.log(this.emailBody);
  }else if (result.error) {
    this.errorHandler(result.error);
  }
  }
  
  sendHandle(){
    this.emailBody = this.template.querySelector("lightning-textarea").value;

    let params = {
      "opportunityId": this.recordId, "body": this.emailBody
    };

    sendEmail(params)
        .then(() => {const event = new ShowToastEvent({
          title : "Email Sending",
          message : "Email was sent successfully",
          variant : 'success'
      }); 
      this.dispatchEvent(event); this.dispatchEvent(new CloseActionScreenEvent());})
        .catch(error => {
          this.errorHandler(error);
      })
  }

  previewHandle(){
    let param = {
      "opportunityId": this.recordId
    };

    invoiceDB(param)
    .then(result => {this.invoiceId = result;})
    .catch(error => {
      this.errorHandler(error)
  })

    this[NavigationMixin.Navigate]({ 
      type:'standard__namedPage',
      attributes:{ 
          pageName:'filePreview'
      },
      state:{ 
        selectedRecordId: this.invoiceId
      }
  })
  }

  errorHandler(error){
    if(error.body){
      console.log(error.body.message);
      const event = new ShowToastEvent({
        title: "Error on generation",
        message: error.body.message,
        variant: "error",
        mode: 'sticky',
    });
    this.dispatchEvent(event);
  }
  }
}
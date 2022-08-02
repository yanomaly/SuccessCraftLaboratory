import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';
import {NavigationMixin} from 'lightning/navigation'
import opportunityDB from '@salesforce/apex/EmailSender.opportunityDB';
import contactDB from '@salesforce/apex/EmailSender.contactDB';
import getMessageBody from '@salesforce/apex/EmailSender.getMessageBody';
import sendEmail from '@salesforce/apex/EmailSender.sendEmail';
import invoiceDB from '@salesforce/apex/EmailSender.invoiceDB';

export default class SendInvoice extends NavigationMixin (LightningElement) {
  @api recordId;
  opportunity = ' ';
  contact = ' ';
  invoiceId = ' ';
  @track emailBody = ' '
  error;

  renderedCallback() {

    if(this.recordId !== undefined){
    
    let param = {
       "opportunityId": this.recordId
    };
      
    contactDB(param)
            .then(result => {this.contact = result;})
            .catch(error => {
              const event = new ShowToastEvent({
                  title: "Error on generation",
                  message: error.body.message,
                  variant: "error",
                  mode: 'sticky',
              });
              this.dispatchEvent(event);
          });

    
    opportunityDB(param)
            .then(result => {this.opportunity = result;})
            .catch(error => {
              const event = new ShowToastEvent({
                  title: "Error on generation",
                  message: error.body.message,
                  variant: "error",
                  mode: 'sticky',
              });
              this.dispatchEvent(event);
          })

    
    getMessageBody(param)
            .then(result => {this.emailBody = result.replace(/<[^>]+>/g, '').replace(/\n{2,}/, '');})
            .catch(error => {
              const event = new ShowToastEvent({
                  title: "Error on generation",
                  message: error.body.message,
                  variant: "error",
                  mode: 'sticky',
              });
              this.dispatchEvent(event);
          })
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
          const event = new ShowToastEvent({
              title: "Error on generation",
              message: error.body.message,
              variant: "error",
              mode: 'sticky',
          });
          this.dispatchEvent(event);
      })
  }

  previewHandle(){
    let param = {
      "opportunityId": this.recordId
    };

    console.log(this.recordId);

    invoiceDB(param)
    .then(result => {this.invoiceId = result;})
    .catch(error => {
      const event = new ShowToastEvent({
          title: "Error on generation",
          message: error.body.message,
          variant: "error",
          mode: 'sticky',
      });
      this.dispatchEvent(event);
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

}
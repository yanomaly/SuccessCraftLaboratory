import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import generatePdf from '@salesforce/apex/CreatePDFInvoice.generatePdf';

export default class HeadlessQuickAction extends LightningElement {
    @api recordId;

    @api invoke() {
        let params = {
            "idOpportunity": this.recordId
        };
        
        console.log(this.recordId);

        generatePdf(params)
        .then(result => {
            const event = new ShowToastEvent({
                title : "Invoice Generation",
                message : "Invoice was generated successfully",
                variant : 'success'
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: "Error on generation",
                message: error.body.message,
                variant: "error",
                mode: 'sticky',
            });
            this.dispatchEvent(event);
        });
    }
}
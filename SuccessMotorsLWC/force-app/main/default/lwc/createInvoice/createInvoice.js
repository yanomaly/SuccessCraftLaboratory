import { LightningElement, api, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import generatePdf from '@salesforce/apex/CreatePDFInvoice.generatePdf';

export default class HeadlessQuickAction extends LightningElement {
    @api recordId;

    @api invoke() {
        let params = {
            "idOpportunity": this.recordId
        };

        generatePdf(params)
        .then(id => {
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
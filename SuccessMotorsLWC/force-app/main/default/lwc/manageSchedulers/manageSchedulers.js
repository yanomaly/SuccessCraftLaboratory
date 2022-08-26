import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runBatchOnce from '@salesforce/apex/ManageSchedulers.runBatchOnce';
import scheduleBatch from '@salesforce/apex/ManageSchedulers.scheduleBatch';
import abortBatch from '@salesforce/apex/ManageSchedulers.abortBatch';
import isRunning from '@salesforce/apex/ManageSchedulers.isRunning';

export default class ManageSchedulers extends LightningElement {
  @api batchName;
  @api schedName;
  @track cronExp = '';
  @track scheduleStatement = false;

  @wire(isRunning, { schedulerClassName: '$schedName' })
    statement(result) {
      console.log(result);
        if (result.data) {
          this.scheduleStatement = result.data;
        } else if (result.error) {
          this.errorHandler(result.error);
        }
    }

  runHandle(){
    let param = {
      "batchClassName": this.batchName
    };
  
    runBatchOnce(param)
      .then(result => {
        const event = new ShowToastEvent({
          title: "Success",
          message: 'Batch ran successfully',
          variant: "success",
          mode: 'sticky',
      })
      this.dispatchEvent(event);
      })
      .catch(error => {
        this.errorHandler(error);
      })
  }  
  
  scheduleHandle(){
    this.cronExp = this.template.querySelectorAll("lightning-input")[0].value;

    let params = {
      "schedulerClassName": this.schedName, "cronExp": this.cronExp
    };

    scheduleBatch(params)
      .then(result => {
          const event = new ShowToastEvent({
          title: "Success",
          message: 'Scheduled successfully',
          variant: "success",
          mode: 'sticky',
      })
      this.scheduleStatement = true;
      this.dispatchEvent(event);
      })
      .catch(error => {
        this.errorHandler(error);
      })
  }

  abortHandle(){
    let param = {
      "schedulerClassName": this.schedName
    };

    abortBatch(param)
      .then(result => {
        const event = new ShowToastEvent({
          title: "Success",
          message: 'Aborted successfully',
          variant: "success",
          mode: 'sticky',
      })
      this.scheduleStatement = false;
      this.dispatchEvent(event);
      })
      .catch(error => {
        this.errorHandler(error);
      })
  }

  errorHandler(error){
    if(error.body){
      console.log(error.body.message);
      const event = new ShowToastEvent({
        title: "Error",
        message: error.body.message,
        variant: "error",
        mode: 'sticky',
    });
    this.dispatchEvent(event);
  }
  }
}

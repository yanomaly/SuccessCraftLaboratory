import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/CustomerStatistics.getAccounts';
import sortAccounts from '@salesforce/apex/CustomerStatistics.sortAccounts';
import getProducts from '@salesforce/apex/CustomerStatistics.getProducts';

export default class CustomerStatistics extends LightningElement {
  @api recordId = '';
  @track isModalOpen = false;
  @track accountName;
  @track opportunitySum;
  @track products;
  @track accountOpportunity = [];
  @track pageNumber = 0;
  @track pageData = [];
  @track pageSize = 10;

  @wire(getAccounts, { accountId: '$recordId' })
    wiredAccounts(result) {
        if (result.data) {
          for(let temp in result.data){
            if(result.data[temp].length !== 0)
              this.accountOpportunity.push({value: result.data[temp], key: temp});
            else
              this.accountOpportunity.push({value: undefined, key: temp});
          }
          console.log('accOpp ' + this.accountOpportunity);
          this.updatePage();
        } else if (result.error) {
          this.errorHandler(result.error);
        }
    }

    searchHandle(){
      this.accountName = this.template.querySelectorAll("lightning-input")[0].value;
      this.opportunitySum = this.template.querySelectorAll("lightning-input")[1].value.length === 0
      ? undefined 
      : this.template.querySelectorAll("lightning-input")[1].value;

      let params = {
        "amount": this.opportunitySum, "name": this.accountName
      };

      this.pageNumber = 0;
      this.accountOpportunity = [];

      sortAccounts(params)
      .then(result => {
        if (result) {
        for(let temp in result){
          if(result[temp].length !== 0)
            this.accountOpportunity.push({value: result[temp], key: temp});
          else
            this.accountOpportunity.push({value: undefined, key: temp});
        }
        console.log('accOpp ' + this.accountOpportunity);
        this.updatePage();
      }})
      .catch(error => {
        if(error)
          this.errorHandler(error);
    });

    }

    productsHandle(event){
      this.isModalOpen = true;

      let param = {
        "opportunityId": event.target.value
      };

      getProducts(param)
        .then(result => {
          this.products = result;
        })
        .catch(error => {
          this.errorHandler(error);
      })
      
    }

    closeModal() {
        this.products = [];
        this.isModalOpen = false;
    }

    handleNext(){
      this.pageNumber = Math.min(Math.floor(this.accountOpportunity.length/this.pageSize), this.pageNumber + 1);
      this.updatePage();
    }

    handlePrev(){
      this.pageNumber = Math.max(0, this.pageNumber - 1);
      this.updatePage();
    }

    updatePage(){
      this.pageData = this.accountOpportunity.slice(this.pageNumber * this.pageSize, Math.min(this.accountOpportunity.length, this.pageNumber * this.pageSize + this.pageSize));
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
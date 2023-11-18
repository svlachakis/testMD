import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';


export default class ProjectComponent extends LightningElement {
     @api recordId;
     docProjectId;
     projectUrl;


    @wire(getRecord, { recordId: '$recordId', fields: ['agf__PPM_Project__c.DevOpsCenter_Project__c']})
project({ data, error }) {
        if(data && data.fields) {
            this.docProjectId = data.fields.DevOpsCenter_Project__c.value
            this.projectUrl = `${window.location.origin}/sf_devops/DevOpsCenter.app?projectId=${this.docProjectId}`
        }
    }
}
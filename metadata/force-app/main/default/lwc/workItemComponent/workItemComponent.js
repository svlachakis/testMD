import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
    const FIELDS = [
        'agf__ADM_Work__c.DevOpsCenter_Work_Item__c',
        'agf__ADM_Work__c.agf__Epic__c'
    ]

export default class WorkItemComponent extends LightningElement {
     @api recordId;
    workItemId;
    epicId;
    aaProjectId;
    docProjectId;
    workItemUrl;


        @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
workItem({ data, error }) {
        if(data && data.fields) {
            this.workItemId = data.fields.DevOpsCenter_Work_Item__c.value
            this.epicId = data.fields.agf__Epic__c.value
        }
    }

        @wire(getRecord, { recordId: '$epicId', fields: 'agf__ADM_Epic__c.agf__Project__c'})
epic({ data, error }) {
        if(data && data.fields) {
            this.aaProjectId = data.fields.agf__Project__c.value

        }
    }

        @wire(getRecord, { recordId: '$aaProjectId', fields: 'agf__PPM_Project__c.DevOpsCenter_Project__c'})
project({ data, error }) {
        if(data && data.fields) {
            this.docProjectId = data.fields.DevOpsCenter_Project__c.value
            this.workItemUrl = `${window.location.origin}/sf_devops/DevOpsCenter.app?projectId=${this.docProjectId}&workItemId=${this.workItemId}`

        }
    }

}
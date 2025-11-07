public without sharing class ExamplesOfVanillaVsNebulaCore {
    //example of addTo
    public void extractConvertedLeadData(List<Lead> leads){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        //vanilla apex
        for(Lead l : leads){
            if(l.IsConverted == true){
                accountIds.add(l.ConvertedAccountId);
                contactIds.add(l.ConvertedContactId);
                opportunityIds.add(l.ConvertedOpportunityId);   
            }
        }
        //nebula-core
        new nebc.LazySObjectIterator(leads)
            .filterOnField(Lead.IsConverted, true)
            .addTo(Lead.ConvertedAccountId, accountIds)
            .addTo(Lead.ConvertedContactId, contactIds)
            .addTo(Lead.ConvertedOpportunityId, opportunityIds)
            .forEach();
    }
    //example of put and putField
    public void createReminderTask(List<Account> accounts){
        String taskSubject = 'Reminder Task';
        //vanilla apex
        List<Task> reminderTasks = new List<Task>(); 
        for(Account acc : accounts){
            Task t = new Task();
            t.Subject = taskSubject;
            t.WhatId = acc.Id;
            t.OwnerId = acc.OwnerId;
            reminderTasks.add(t);
        }
        insert reminderTasks;
        
        //nebula-core
        new nebc.LazySObjectIterator(accounts)
            .mapValuesT(
                new nebc.SObjectFromPrototype(new Task())
                .put(Task.Subject, taskSubject)
                .putField(Task.WhatId, Account.Id)
                .putField(Task.OwnerId, Account.OwnerId)
            )
            .doInsert();
    }
}

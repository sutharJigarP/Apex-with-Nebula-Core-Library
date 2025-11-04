global without sharing class ContactTotalContactRollupToAccount implements nebc.AfterInsert, nebc.AfterUpdate, nebc.AfterDelete, nebc.AfterUndelete{
    public void handleAfterInsert(List<Contact> newList){
        handle(newList);
    }
    public void handleAfterDelete(List<Contact> oldList){
        handle(oldList);
    }
    public void handleAfterUndelete(List<Contact> newList){
        handle(newList);
    }
    public void handleAfterUpdate(List<Contact> oldList, List<Contact> newList){
        handle(
        	new nebc.LazyTriggerContextPairIterator(oldList, newList)
            .filterT(new nebc.IsFieldChangedInTrigger(Contact.AccountId))
            .bothRecords()
            .toList()
        );
        //instead of bothRecords(), we can use the .expand(new nebc.TriggerContextPairExpandToBoth()); as well
    }
    private void handle(List<Contact> contacts){
        handleRollup(
            new nebc.LazySObjectIterator(contacts)
            .filterOnField(Contact.AccountId, new nebc.IsNotNull())
            .mapValuesT(new nebc.FieldFromSObject(Contact.AccountId))
            .toSet(new Set<Id>())
        );
    }
    private void handleRollup(Set<Id> accountIds){
        new nebc.LazySObjectIterator(
        	[SELECT Id, (Select Id FROM Contacts) FROM Account WHERE Id IN :accountIds]
        )
            .mapValuesT(new countContact())
            .doUpdate();
    }
    private class countContact implements nebc.Function {
        public Object call(Object o){
            Account acc = (Account) o;
            acc.NumberOfEmployees = acc?.Contacts?.Size() ?? 0;
            return acc;
        }
    }
}
/*
* description: set the initial status of account when lead is converted into new account
*/
@JsonAccess(deserializable='always')
global class LeadConvertedSetAccountStatus implements nebc.AfterUpdate {
    //this will come from the trigger metadata
    public String initialStatus;
    public void handleAfterUpdate(List<Lead> oldList, List<Lead> newList){
        Set<Id> leadIds = new Set<Id>(); 
        List<Account> accountToUpdate = new List<Account>();
        newList = new nebc.LazyTriggerContextPairIterator(oldList, newList)
            .filterT(new nebc.IsFieldChangedInTrigger(Lead.IsConverted))
            .newRecords()
            .filterOnField(Lead.IsConverted, true)
            .addTo(Lead.Id, leadIds)
            .toList();
        
        if(newList.size()==0){
            return;
        }
        
        new nebc.LazySObjectIterator(newList)
            .filterT(new IsNewAccount(getLeadDetails(leadIds)))
            .mapValuesT(
                new nebc.SObjectFromPrototype(new Account())
                .putField(Account.Id, Lead.ConvertedAccountId)
                .put(Account.Status__c, initialStatus)
            )
            .doUpdate();
    }
    
    public Map<Id, Lead> getLeadDetails(Set<Id> leadIds){
        return new Map<Id, Lead>(
            [SELECT Id, ConvertedAccount.CreatedDate FROM Lead WHERE Id IN :leadIds AND ConvertedAccountId != null]
        );
    }
    
    public class IsNewAccount implements nebc.BooleanFunction {
        public Map<Id, Lead> leadMap;
        public IsNewAccount(Map<Id, lead> leadMap){
            this.leadMap = leadMap;
        }
        public Boolean isTrueFor(Object o){
            Lead l = (Lead) o;
            DateTime dt = System.now();
            return (
                leadMap.get(l.Id).ConvertedAccount.CreatedDate.date() == dt.date() 
                && leadMap.get(l.Id).ConvertedAccount.CreatedDate.hour() == dt.hour()
                && leadMap.get(l.Id).ConvertedAccount.CreatedDate.minute() == dt.minute()
            );
        }
    }
}
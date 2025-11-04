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
}

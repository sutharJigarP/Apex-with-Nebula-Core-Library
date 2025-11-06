/*
* description: stop the user from deleting the opportunity if in the important stage
*/
@JsonAccess(deserializable='always')
global class OpportunityPreventDeleting implements nebc.BeforeDelete {
    public List<String> importantStages;
    public String errorMessage;
    public void handleBeforeDelete(List<Opportunity> oldList){
        if(FeatureManagement.checkPermission('System_Data_Admin')){
            return;
        }
        new nebc.LazySObjectIterator(oldList)
            .filterT(new IsOpportunityInImportantStage(this.importantStages))
            .forEach(new nebc.SObjectAddError(this.errorMessage));
    }
    public class IsOpportunityInImportantStage implements nebc.BooleanFunction {
        public List<String> importantStages;
        public IsOpportunityInImportantStage(List<String> importantStages){
            this.importantStages = importantStages;
        }
        public Boolean isTrueFor(Object o){
            Opportunity opp = (Opportunity) o;
            return this.importantStages.contains(opp.StageName);
        }
    }
}
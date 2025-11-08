/*
* description: when order got cancel, cancel all related order item and if shipped then start the return process
*/
global without sharing class OrderCancelItems implements nebc.AfterUpdate {
    public void handleAfterUpdate(List<Order> oldList, List<Order> newList){
        Set<Id> orderId = new nebc.LazyTriggerContextPairIterator(oldList, newList)
            .filterT(new nebc.IsFieldChangedInTrigger(Order.Status))
            .newRecords()
            .filterOnField(Order.Status, 'Cancel')
            .get(Order.Id)
            .toSet(new Set<Id>());
        if(orderId.size()==0){
            return;
        }
        new nebc.LazySObjectIterator(
        	[SELECT Id, Status__c FROM OrderItem WHERE OrderId IN :orderId AND Status__c != 'Cancel' AND Status__c != 'Start Return Process']
        )
            .mapValuesT(new SetItemStatus())
            .doUpdate();
    }
    public class SetItemStatus implements nebc.Function {
        public Object call(Object o){
            OrderItem item = (OrderItem) o;
            item.Status__c = (item.Status__c != 'Shipped' ? 'Cancel' : 'Start Return Process');
            return item;
        }
    }
}
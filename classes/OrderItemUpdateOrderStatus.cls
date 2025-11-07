/*
* description: set the order status to shipped when all child order item are shipped
*/
@JsonAccess(Deserializable='always')
global without sharing class OrderItemUpdateOrderStatus implements nebc.AfterUpdate {
    public String shippedStatusValue;
    public void handleAfterUpdate(List<OrderItem> oldList, List<OrderItem> newList){
        List<SObjectField> changeFields = new List<SObjectField>{OrderItem.Status__c};
            Set<Id> orderIds = new nebc.LazyTriggerContextPairIterator(oldList, newList)
            .filterT(new nebc.IsAnyFieldChangedInTrigger(changeFields))
            .newRecords()
            .filterOnField(OrderItem.OrderId, new nebc.IsNotNull())
            .filterOnField(OrderItem.Status__c, shippedStatusValue)
            .get(OrderItem.OrderId)
            .toSet(new Set<Id>());
        
        if(orderIds.size()==0){
            return;
        }
        
        new nebc.LazySObjectIterator(
        	[SELECT Id, Status, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :orderIds]
        )
            .filterT(new IsAllItemShipped(shippedStatusValue))
            .put(Order.Status, shippedStatusValue)
            .doUpdate();
    }
    public class IsAllItemShipped implements nebc.BooleanFunction {
        public String shippedStatusValue;
        public IsAllItemShipped (String shippedStatusValue){
            this.shippedStatusValue = shippedStatusValue;
        }
        public Boolean isTrueFor(Object o){
            Order odr = (Order) o;
            List<OrderItem> shippedItems = new nebc.LazySObjectIterator(odr.OrderItems)
                .filterOnField(OrderItem.Status__c, shippedStatusValue)
                .toList();
            return (shippedItems.size() == odr.OrderItems.size());
        }
    }
}
trigger FVU_OrderTrigger on Order (after update) {
 
    if (Trigger.isUpdate && Trigger.isAfter) {
        FVU_OrderTriggerHandler.afterUpdate(Trigger.new, Trigger.OldMap);
    }
}
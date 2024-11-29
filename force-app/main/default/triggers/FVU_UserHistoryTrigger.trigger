trigger FVU_UserHistoryTrigger on FVU_User_History__c (before delete, before update) {
    if(Trigger.isDelete){
        for (FVU_User_History__c userDelete : Trigger.old) {
            userDelete.addError('El registro no se puede eliminar.');
        }
    }
    if(Trigger.isUpdate){
        for (FVU_User_History__c userUpdate : Trigger.new) {
            userUpdate.addError('El registro no se puede modificar.');
        }
    }
}
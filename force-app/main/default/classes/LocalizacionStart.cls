public with sharing class LocalizacionStart {
    public static void LocalizacionStart() {
        Integer accountCount = [SELECT COUNT() FROM Account];
       System.debug('There are ' + accountCount + 'ccounts in the system.');
     
    }
}
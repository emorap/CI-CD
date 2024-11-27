public with sharing class Claseinicial {
    public static void Claseinicial() {
        Integer accountCount = [SELECT COUNT() FROM Account];
       System.debug('There are ' + accountCount + 'ccounts in the system.');
     

    }


   }
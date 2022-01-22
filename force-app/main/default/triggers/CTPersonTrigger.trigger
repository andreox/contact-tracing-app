trigger CTPersonTrigger on Person__c ( before insert, before update, after update ) {

    

        //String health_status = ''+person.Health_Status__c ;
        //String mobile = ''+person.Mobile__c ;

        //Two different approaches : Static external method ( cleaner ), and inner for loop 
    switch on Trigger.operationType {

        when BEFORE_INSERT {

            for ( Person__c person : Trigger.new ) {
                person.Health_Status__c = 'Green' ;
                person.Token__c = CTPersonController.getToken(person.Mobile__c) ;
            }
        
        }

        when BEFORE_UPDATE {
            CTPersonTriggerController.beforeUpdate( Trigger.new, Trigger.oldMap) ;
        }

        when AFTER_UPDATE {

            CTPersonTriggerController.afterUpdate(Trigger.new, Trigger.oldMap ) ;
        }
    }
    
}
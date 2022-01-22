public with sharing class CTPersonController {

    public static String getToken( String mobile ) {
        
        Blob target_blob = Blob.valueOf(mobile) ;
        Blob hash = Crypto.generateDigest('MD5', target_blob) ;

        return EncodingUtil.base64Encode(hash) ;

    }

    public static List<Person__c> getRecentHealthChanges() {

        List<Person__c> recentHealthChanges = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                                 FROM Person__c 
                                                 ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100] ;
        return recentHealthChanges ;

        //return [QUERY] would reduce Heap Size usage 
    }

    public static List<Person__c> searchPeople( String searchTerm ) {

        searchTerm += '%' ;
        List<Person__c> peopleFound = [ SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                         FROM Person__c
                                          WHERE Name LIKE :searchTerm
                                           OR Token__c LIKE :searchTerm
                                            OR Mobile__c LIKE :searchTerm
                                             ORDER BY Status_Update_Date__c DESC NULLS LAST] ;
        return peopleFound ;

    }

    public static Person__c getPersonById( String personId ) {
        Person__c personMatching = [ SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                     FROM Person__c
                                      WHERE Id = :personId ] ;
        return personMatching ;

    }

    public static Map<String, Integer> getHealthStatusCount() {

        AggregateResult[] groupedResult = [SELECT Health_Status__c, COUNT(Id) statusCount FROM Person__c GROUP BY Health_Status__c] ;

        Map<String,Integer> healthStatusMap = new Map<String,Integer>() ;

        for ( AggregateResult ar : groupedResult) {
            healthStatusMap.put( String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('statusCount'))) ;
        }

        return healthStatusMap ;
    }

    public static Set<Id> getCohabitants( Set<Id> personIds, Set<Id> alreadyProcessed ) {

        List<String> healthStatuses = new List<String>{'Green','Yellow'} ;
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                FROM People_Tracing__c
                                                 WHERE ( Person_1__c IN :personIds OR Person_2__c IN :personIds )
                                                  AND Contact_Type__c = 'Cohabitant'
                                                  AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)] ;
        
        Set<Id> cohabitants = new Set<Id>() ;
        for ( People_Tracing__c pt : peopleTraces ) {

            if ( !alreadyProcessed.contains(pt.Person_1__c)) {
                cohabitants.add(pt.Person_1__c) ;
                alreadyProcessed.add(pt.Person_1__c);
            }

            if( !personIds.contains(pt.Person_2__c) ) {
                cohabitants.add(pt.Person_2__c) ; //Refers to the Id 
            }
        }

        return cohabitants ;

    }

    public static Set<Id> getNeighbours ( Set<Id> personIds, Set<Id> alreadyProcessed ) {

        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                FROM People_Tracing__c
                                                 WHERE ( Person_1__c IN :personIds OR Person_2__c IN :personIds )
                                                  AND Contact_Type__c = 'Neighbour'
                                                  AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')] ;
        
        Set<Id> neighbours = new Set<Id>() ;
        for ( People_Tracing__c pt : peopleTraces ) {

            if ( !alreadyProcessed.contains(pt.Person_1__c)) {
                neighbours.add(pt.Person_1__c) ;
                alreadyProcessed.add(pt.Person_1__c);
            }

            if ( !alreadyProcessed.contains(pt.Person_2__c)) {
                neighbours.add(pt.Person_2__c) ;
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return neighbours ;

    }

    public static Set<Id> getPrimaryContacts( Set<Id> personIds, Set<Id> alreadyProcessed ) {

        List<String> healthStatuses = new List<String>{'Green','Yellow'} ;
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                FROM People_Tracing__c
                                                 WHERE ( Person_1__c IN :personIds OR Person_2__c IN :personIds )
                                                  AND Contact_Type__c = 'Other'
                                                  AND Contact_Date__c = LAST_N_DAYS:10 
                                                  AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)] ;
        
        Set<Id> primaryContacts = new Set<Id>() ;
        for ( People_Tracing__c pt : peopleTraces ) {

            if ( !alreadyProcessed.contains(pt.Person_1__c)) {
                primaryContacts.add(pt.Person_1__c) ;
                alreadyProcessed.add(pt.Person_1__c);
            }

            if ( !alreadyProcessed.contains(pt.Person_2__c)) {
                primaryContacts.add(pt.Person_2__c) ;
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return primaryContacts ;

    }

    public static Set<Id> getSecondaryContacts( Set<Id> primaryContactsIds, Set<Id> alreadyProcessed ) {

        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                FROM People_Tracing__c
                                                 WHERE ( Person_1__c IN :primaryContactsIds OR Person_2__c IN :primaryContactsIds )
                                                  AND Contact_Type__c = 'Other'
                                                  AND Contact_Date__c = LAST_N_DAYS:10 
                                                  AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')] ;
        
        Set<Id> secondaryContacts = new Set<Id>() ;
        for ( People_Tracing__c pt : peopleTraces ) {

            if ( !alreadyProcessed.contains(pt.Person_1__c)) {
                secondaryContacts.add(pt.Person_1__c) ;
                alreadyProcessed.add(pt.Person_1__c);
            }

            if ( !alreadyProcessed.contains(pt.Person_2__c)) {
                secondaryContacts.add(pt.Person_2__c) ;
                alreadyProcessed.add(pt.Person_2__c);
            }
        }

        return secondaryContacts ;

    }


}

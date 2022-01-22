public with sharing class CTLocationController {

    public static List<Location__c> getRecentStatusChanges() {

        List<Location__c> recentLocationStatusChanged = [ SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c
                                                        FROM Location__c
                                                        ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100] ;
        return recentLocationStatusChanged ;
    }

    public static List<Location__c> searchLocations(String searchText) {

        List<Location__c> foundLoc = [SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c
                                    FROM Location__c
                                    WHERE Name LIKE :searchText
                                    OR Pincode__c LIKE :searchText
                                    OR Address__c LIKE :searchText
                                    ORDER BY Status_Update_Date__c DESC NULLS LAST ] ;
        return foundLoc ;
    }

    public static Location__c getLocationById( String locationId) {
        Location__c location = [SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c
                                FROM Location__c
                                WHERE Id = :locationId] ;
        return location ; 
    }

    public static Map<String, Integer> getStatusCount() {

        AggregateResult[] groupedResult = [SELECT Status__c, COUNT(Id) statusCount FROM Location__c GROUP BY Status__c] ;

        Map<String,Integer> healthStatusMap = new Map<String,Integer>() ;

        for ( AggregateResult ar : groupedResult) {
            healthStatusMap.put( String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('statusCount'))) ;
        }

        return healthStatusMap ;
    }

    public static void updateRedScore( Set<Id> locationIds ) {

        List<Location__c> locationToUpdate = new List<Location__c>() ;
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red'
            AND Visit_Date__c = LAST_N_DAYS:10
            AND Location__c IN: locationIds
            GROUP BY Location__c ] ;

            for ( AggregateResult ar : redPeoplePerLocation ) {

                String locationId = String.valueOf(ar.get('Location__c')) ;
                Integer redScore = Integer.valueOf(ar.get('total')) ;
                String status = getStatus(redScore) ;
                locationToUpdate.add(new Location__c(Id=locationId, Red_Score__c = redScore, Status__c = status )) ;

            }

            if ( locationToUpdate != null && locationToUpdate.size() > 0 ) {
                update locationToUpdate ;
            }
    }

    public static String getStatus(Integer redScore) {
        if ( redScore == 0 ) { return 'Green' ;}
        else if ( redScore <= 5 ) {
            return 'Yellow' ;
        }
        else if ( redScore <= 10 ) {
            return 'Orange' ;
        }

        return 'Red' ;

    }
    
}

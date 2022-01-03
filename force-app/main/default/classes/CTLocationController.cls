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
    
}

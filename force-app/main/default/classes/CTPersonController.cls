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

}

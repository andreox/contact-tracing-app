public with sharing class CTPeopleTracingController {

    CTPeopleController person1 ;
    CTPeopleController person2 ;
    ContactType contactType ;
    Date contactDate ;
    public CTPeopleTracingController(CTPeopleController p1, CTPeopleController p2, ContactType ct, Date cd) {
        this.person1 = p1 ;
        this.person2 = p2 ;
        this.contactType = ct ;
        this.contactDate = cd ; 

    }

    //Implement get and set 
}

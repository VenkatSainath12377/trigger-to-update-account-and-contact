trigger DonorStatusUpdate on Opportunity (after insert, after update) {
    //trigger to update donor status on account and contact from opportunity based on opportunity close date
    set<Id> Accountid = new set<Id>();
    for(Opportunity opp: trigger.new){
        Accountid.add(opp.AccountId);
    }
    Map<Id,Account> accountsmap = new map<Id,Account>([select ID,Name,npo02__NumberOfClosedOpps__c from Account where Id IN: Accountid]);
    List<Account> AccountUpdate = new List<Account>();
    for(Opportunity opp : trigger.new){
        Account acc = accountsmap.get(opp.AccountId);
        Date startDate = opp.CloseDate;
        Date endDate = system.today();
        Integer noOfDays = startDate.daysBetween(endDate);
        system.debug('No. of Days are:'+ noOfDays);
        if(noOfDays >= 0 && noOfDays <= 365 && acc.npo02__NumberOfClosedOpps__c != 0){
              acc.Donor_Status__c = 'Active';
        }
        else if (noOfDays > 365 && noOfDays <= 1095 && acc.npo02__NumberOfClosedOpps__c != 0){
              acc.Donor_Status__c = 'Lapsed';
        }
        else if(noOfDays > 1095 && acc.npo02__NumberOfClosedOpps__c != 0){
              acc.Donor_Status__c = 'In Active';
        }
        else if(acc.npo02__NumberOfClosedOpps__c == 0){
            acc.Donor_Status__c = 'Prospect';
        }
        AccountUpdate.add(acc);
    }
    update AccountUpdate;
    Map<Id,Account> updatedAccount = new map<Id,Account>();
    for(Account acc: AccountUpdate){
        updatedAccount.put(acc.Id,acc);
    }
    List<Contact> contacts = [select Id, AccountId from Contact where AccountId IN: Accountid];
    for(Contact con: contacts){
       Account acc = updatedAccount.get(con.AccountId);
        con.Donor_Status__c = acc.Donor_Status__c;
    }
    update contacts;
}

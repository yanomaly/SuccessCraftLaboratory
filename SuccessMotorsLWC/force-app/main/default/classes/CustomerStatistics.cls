public with sharing class CustomerStatistics {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> getAccounts(String accountId){
        List<Account> accounts;
        if(String.isBlank(accountId))
            accounts = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];
        else 
            accounts = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account WHERE Id =: accountId];
        return createMap(sortEmptyAccounts(accounts));
    }

    public static Map<String, List<Opportunity>> createMap(List<Account> accounts){
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();
        for(Account temp: accounts)
            result.put('Name: ' + temp.Name + '. Total amount: ' + countTotal(temp.Opportunities) + '$', temp.Opportunities);
        return result;
    }

    public static Decimal countTotal(List<Opportunity> opps){
        Decimal total = 0.0;
        for(Opportunity temp: opps){
            total += temp.Amount;
        }
        return total.setScale(2);
    }

    public static List<Account> sortEmptyAccounts(List<Account> accounts){
        List<Account> result = new List<Account>();
        for(Account temp: accounts)
            if(countTotal(temp.Opportunities) != 0)
                result.add(temp);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> sortAccounts(String amount, String name){
        List<Account> findByNameList = findAccountsByName(name);
        List<Account> findByAmountList = findAccountsByTotalAmount(amount);
        List<Account> resultList = new List<Account>();
        for(Account temp: findByNameList){
            if(findByAmountList.contains(temp))
                resultList.add(temp);
        }
        return createMap(resultList);
    }
    
    public static List<Account> findAccountsByName(String name){
        List<Account> preResult = new List<Account>();
        if(String.isBlank(name))
            preResult = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];
        else 
            preResult = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account WHERE Name =: name];
        return sortEmptyAccounts(preResult);   
    }

    public static List<Account> findAccountsByTotalAmount(String amountStr){
        List<Account> preResult = new List<Account>();
        if(String.isBlank(amountStr))
            preResult = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];
        else {
            Decimal amount = decimal.valueOf(amountStr);
            List<Account> accounts = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];
            for(Account temp: accounts)
                if(amount == countTotal(temp.Opportunities))
                    preResult.add(temp);
        }
        return sortEmptyAccounts(preResult);        
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getProducts(String opportunityId){
        return [SELECT Name, UnitPrice, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
    }
}

public with sharing class CustomerStatistics {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> getAccounts(String accountId){
        List<Account> accounts;
        if(String.isBlank(accountId))
            accounts = [SELECT Name, Id FROM Account];
        else 
            accounts = [SELECT Name, Id FROM Account WHERE Id =: accountId];
        return createMap(accounts);
    }

    public static Map<String, List<Opportunity>> createMap(List<Account> accounts){
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();
        for(Account temp: accounts){
            List<Opportunity> tempOpportunity = [SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunity WHERE AccountId =: temp.Id AND (StageName = 'Closed Won' OR StageName = 'Closed Lost')];
            if(!tempOpportunity.isEmpty())
                result.put(temp.Name + ' Total amount: ' + countTotal(tempOpportunity) + '$', tempOpportunity);
            else 
                result.put(temp.Name + ' No closed Opportunities', new List<Opportunity>()); 
        }
        return result;
    }

    public static Decimal countTotal(List<Opportunity> opps){
        Decimal total = 0.0;
        for(Opportunity temp: opps){
            total += temp.Amount;
        }
        return total;
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
        if(String.isBlank(name))
            return [SELECT Name, Id FROM Account];
        else 
            return [SELECT Name, Id FROM Account WHERE Name =: name];
    }

    public static List<Account> findAccountsByTotalAmount(String amountStr){
        if(String.isBlank(amountStr))
            return [SELECT Name, Id FROM Account];
        else {
            Decimal amount = decimal.valueOf(amountStr);
            List<Account> result = new List<Account>();
            List<Account> accounts = [SELECT Name, Id FROM Account];
            for(Account temp: accounts){
                List<Opportunity> tempOpportunity = [SELECT Amount FROM Opportunity WHERE AccountId =: temp.Id AND (StageName = 'Closed Won' OR StageName = 'Closed Lost')];
                if(amount == countTotal(tempOpportunity))
                    result.add(temp);
            }
            return result;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getProducts(String opportunityId){
        return [SELECT Name, UnitPrice, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
    }
}

@isTest
public class CustomerStatisticsTest {
   @TestSetup
   static void createData(){
      Account accountV1 = new Account(Name = 'AV1');
      insert accountV1;
      Account accountV2 = new Account(Name = 'AV2');
      insert accountV2;
      Account accountV3 = new Account(Name = 'AV3');
      insert accountV3;
      Opportunity opportunityV1 = new Opportunity(Name = 'OV1', StageName = 'Closed Won', CloseDate = date.today(), Amount = 1000.0, AccountId = accountV1.Id);
      insert opportunityV1;
      Opportunity opportunityV2 = new Opportunity(Name = 'OV2', StageName = 'Closed Lost', CloseDate = date.today(), Amount = 900.0, AccountId = accountV1.Id);
      insert opportunityV2;
      Opportunity opportunityV3 = new Opportunity(Name = 'OV3', StageName = 'Closed Won', CloseDate = date.today(), Amount = 10000.0, AccountId = accountV3.Id);
      insert opportunityV3;
    }

    @isTest
    public static void getProductsTest(){
        Product2 product = new Product2(Name = 'Test product');
        insert product;
        Opportunity opportunity = new Opportunity(Name = 'Test', StageName = 'Prospecting', Pricebook2Id = Test.getStandardPricebookId(), CloseDate = date.today() + 3);
        insert opportunity;
        PriceBookEntry prEntry = new PriceBookEntry(Product2Id = product.Id, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true, UnitPrice = 1919.0);
        insert prEntry;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id = product.Id, Quantity = 10.0, TotalPrice = 19190.0, PriceBookEntryId = prEntry.Id);
        insert opportunityLineItem;
        
        Test.startTest();
        List<OpportunityLineItem> result = CustomerStatistics.getProducts(opportunity.Id);
        Test.stopTest();

        System.assertEquals(1, result.Size(), 'Incorrect result size');
        System.assertEquals('Test Test product', result[0].Name, 'Incorrect product name');
        System.assertEquals(10, result[0].Quantity, 'Incorrect product quantity');
    }

    @isTest
    public static void findAccountsByTotalAmountPositiveTest(){
        String amount = '1000.00';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByTotalAmount(amount);
        Test.stopTest();

        System.assertEquals(2, result.Size(), 'Incorrect result size');
    }

    @isTest
    public static void findAccountsByTotalAmountNegativeTest(){
        String amount = '';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByTotalAmount(amount);
        Test.stopTest();

        System.assertEquals(2, result.Size(), 'Incorrect result size');
    }

    @isTest
    public static void findAccountsByNamePositiveTest(){
        String name = 'AV';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByName(name);
        Test.stopTest();

        System.assertEquals(2, result.Size(), 'Incorrect result size');
    }

    @isTest
    public static void findAccountsByNameNegativeTest(){
        String name = '';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByName(name);
        Test.stopTest();

        System.assertEquals(2, result.Size(), 'Incorrect result size');
    }

    @isTest
    public static void sortAccountsTest(){
        String name = 'AV2';
        String amount = '';

        Test.startTest();
        Map<String, List<Opportunity>> result = CustomerStatistics.sortAccounts(amount, name);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Incorrect result size');
    }

    @isTest
    public static void countTotalTest(){
        Account account = [SELECT Name, Id, (SELECT Amount FROM Opportunities WHERE StageName = 'Closed Won') FROM Account WHERE Name = 'AV1'];

        Test.startTest();
        Decimal result = CustomerStatistics.countTotal(account.Opportunities);
        Test.stopTest();

        System.assertEquals(1000.00, result, 'Incorrect total amount');
    }

    @isTest
    public static void createMapTest(){
        Account account1 = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account WHERE Name = 'AV1'];
        Account account3 = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account WHERE Name = 'AV3'];
        List<Account> accountList = new List<Account>{account1, account3};

        Test.startTest();
        Map<String, List<Opportunity>> result = CustomerStatistics.createMap(accountList);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Incorrect result size');
    }

    @isTest
    public static void getAccountsPositiveTest(){
        Account account1 = [SELECT Name, Id FROM Account WHERE Name = 'AV1'];

        Test.startTest();
        Map<String, List<Opportunity>> result = CustomerStatistics.getAccounts(account1.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Incorrect result size');
    }

    @isTest
    public static void getAccountsNegativeTest(){
        String accountId = '';

        Test.startTest();
        Map<String, List<Opportunity>> result = CustomerStatistics.getAccounts(accountId);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Incorrect result size');
    }
    
    @isTest
    public static void sortEmptyAccountsTest(){
        List<Account> accounts = [SELECT Name, Id, (SELECT Name, CloseDate, CreatedDate, Amount, Id FROM Opportunities WHERE StageName = 'Closed Won') FROM Account];

        Test.startTest();
        List<Account> result = CustomerStatistics.sortEmptyAccounts(accounts);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Incorrect result size');
    }

    @isTest
    public static void amountComparatorPositiveTest(){
        Decimal amount1 = 10.1;
        Decimal amount2 = 10.19;


        Test.startTest();
        Boolean result = CustomerStatistics.amountComparator(amount1, amount2);
        Test.stopTest();

        System.assert(result, 'Incorrect result');
    }

    @isTest
    public static void amountComparatorNegativeTest(){
        Decimal amount1 = 9.00;
        Decimal amount2 = 10.19;


        Test.startTest();
        Boolean result = CustomerStatistics.amountComparator(amount1, amount2);
        Test.stopTest();

        System.assert(!result, 'Incorrect result');
    }
}

@isTest
public class CustomerStatisticsTest {
   @TestSetup
   static void createData(){
      Account accountV1 = new Account(Name = 'AV1');
      insert accountV1;
      Account accountV2 = new Account(Name = 'AV2');
      insert accountV2;
      Opportunity opportunityV1 = new Opportunity(Name = 'OV1', StageName = 'Closed Won', CloseDate = date.today(), Amount = 1000.0, AccountId = accountV1.Id);
      insert opportunityV1;
      Opportunity opportunityV2 = new Opportunity(Name = 'OV2', StageName = 'Closed Lost', CloseDate = date.today(), Amount = 900.0, AccountId = accountV1.Id);
      insert opportunityV2;
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
        String amount = '1900.00';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByTotalAmount(amount);
        Test.stopTest();

        System.assertEquals(1, result.Size(), 'Incorrect result size');
        System.assertEquals('AV1', result[0].Name, 'Incorrect account name');
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
        String name = 'AV2';

        Test.startTest();
        List<Account> result = CustomerStatistics.findAccountsByName(name);
        Test.stopTest();

        System.assertEquals(1, result.Size(), 'Incorrect result size');
        System.assertEquals('AV2', result[0].Name, 'Incorrect account name');
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

        System.assertEquals(1, result.size(), 'Incorrect result size');
    }

    @isTest
    public static void countTotalTest(){
        Account account = [SELECT Name, Id FROM Account WHERE Name = 'AV1'];
        List<Opportunity> testData = [SELECT Amount FROM Opportunity WHERE AccountId =: account.Id];

        Test.startTest();
        Decimal result = CustomerStatistics.countTotal(testData);
        Test.stopTest();

        System.assertEquals(1900.00, result, 'Incorrect total amount');
    }

    @isTest
    public static void createMapTest(){
        Account account1 = [SELECT Name, Id FROM Account WHERE Name = 'AV1'];
        Account account2 = [SELECT Name, Id FROM Account WHERE Name = 'AV2'];
        List<Account> accountList = new List<Account>{account1, account2};

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
}

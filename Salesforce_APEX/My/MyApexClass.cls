public class MyApexClass {
Account newAcc = new Account(
    Name = 'Tech Corp',
    Industry = 'Technology',
    Phone = '123-456-7890'
);
insert newAcc;
System.debug('New Account Created: ' + newAcc.Id);
}

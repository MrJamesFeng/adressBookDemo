//
//  ViewController.m
//  adressBookDemo
//
//  Created by LDY on 17/3/30.
//  Copyright © 2017年 LDY. All rights reserved.
//

#import "ViewController.h"

@import AddressBook;
@import AddressBookUI;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate>

@property(nonatomic,assign)ABAddressBookRef addressBook;

@property(nonatomic,strong)NSArray *addressBookEntryArray;


@property(nonatomic,strong)UITableView *addressView;

@end
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kCellReuseIdentifier @"addressCell"
#define kWeakSelf __weak typeof(self)weakSelf = self
@implementation ViewController{
    ABAddressBookRef _addressBook;
    NSArray *_addressBookEntryArray;
}

@synthesize addressBook = _addressBook;
@synthesize addressBookEntryArray = _addressBookEntryArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"通讯录";
    [self.view addSubview:self.addressView];
    
    CFErrorRef error;
    //创建通讯录
    _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (_addressBook == NULL) {
        NSLog(@"%@",CFErrorCopyDescription(error));
        CFRelease(error);//error有值才需要释放
    }
    kWeakSelf;
    //请求权限
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
//        NSLog(@"%d %@",granted,error);
        
        if (granted) {
//            NSLog(@"%ld",ABAddressBookGetGroupCount(_addressBook));
            
//            NSLog(@"%ld",ABAddressBookGetPersonCount(_addressBook));
            _addressBookEntryArray = (__bridge_transfer  NSArray*)ABAddressBookCopyArrayOfAllPeople(_addressBook);
//            NSLog(@"%@",_addressBookEntryArray);
            [weakSelf.addressView reloadData];
//            CFRelease(_addressBook);//_addressBook不能在block外部释放//这个需要在后面使用的话也不能释放
        }
    });
    
//    CFRelease(error);//手动释放error为null时报错
//    CFRelease(_addressBook);//移步操作不能在这里释放
    
    //查看联系人
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(choseContact)];
    //新增联系人
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(addNewContact)];
    
    
}
-(void)choseContact{
    
    //1、显示整个通讯录所有信息
    ABPeoplePickerNavigationController *pickerNavigationController = [[ABPeoplePickerNavigationController alloc]init];
    //设置筛选条件：只展示关注的信息
//    pickerNavigationController.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    pickerNavigationController.peoplePickerDelegate = self;
    [self presentViewController:pickerNavigationController animated:YES completion:nil];
     
    
    /*
    //2、显示某个人的通讯录信息
    ABPersonViewController *personViewController = [[ABPersonViewController alloc]init];
    personViewController.personViewDelegate = self;
    ABRecordRef record = ABPersonCreate();
    CFStringRef lastName = (CFStringRef)@"james";
    CFStringRef phoneNum = (CFStringRef)@"13222222222";
    ABRecordSetValue(record, kABPersonLastNameProperty, lastName, NULL);
    ABRecordSetValue(record,kABPersonDepartmentProperty, phoneNum, NULL);
    
    personViewController.displayedPerson = record;
    //允许编辑
    personViewController.allowsEditing = YES;
    //激活视频、邮件
    personViewController.allowsActions = YES;
    [self.navigationController pushViewController:personViewController animated:YES];
    CFRelease(lastName);
    CFRelease(phoneNum);
    CFRelease(record);
     */
    
    
    
}
-(void)addNewContact{
    /*
    //1、系统方法
    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc]init];
    
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:newPersonViewController];
    newPersonViewController.newPersonViewDelegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
     */
    
    //2、手动创建
    //基本信息
    ABRecordRef recordRef = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, @"test", &error);
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, @"1111", &error);
    ABRecordSetValue(recordRef, kABPersonOrganizationProperty, @"liandongyuan", &error);
   
   //电话
    ABMutableMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneMultiValue, @"1-800-555-5555", kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(phoneMultiValue, @"1-203-426-1234",kABPersonParentLabel, NULL);
    ABMultiValueAddValueAndLabel(phoneMultiValue, @"1-555-555-0123", kABPersonPhoneIPhoneLabel, NULL);
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, phoneMultiValue, NULL);
    //邮箱
    ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *mtDict = [NSMutableDictionary dictionary];
    [mtDict setObject:@"152" forKey:(NSString *)kABPersonAddressStateKey];
    [mtDict setObject:@"shenzhen" forKey:(NSString *)kABPersonAddressCityKey];
    [mtDict setObject:@"nanshan" forKey:(NSString *)kABPersonAddressStateKey];
    [mtDict setObject:@"19663" forKey:(NSString *)kABPersonAddressZIPKey];
    ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)(mtDict), kABWorkLabel, NULL);
    ABRecordSetValue(recordRef, kABPersonAddressProperty, emailMultiValue, &error);
    
    ABAddressBookAddRecord(_addressBook, recordRef, &error);
    ABAddressBookSave(_addressBook, &error);
    if (error) {
        NSLog(@"error:%@",error);
        CFRelease(error);
    }
    CFRelease(emailMultiValue);
    CFRelease(phoneMultiValue);
    CFRelease(recordRef);
   
}
#pragma UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _addressBookEntryArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kCellReuseIdentifier];
    }
    ABRecordRef recordRef = (__bridge ABRecordRef)(_addressBookEntryArray[indexPath.row]);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    cell.textLabel.text = firstName;
    cell.detailTextLabel.text = lastName;
    //获取多值数据
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(recordRef,kABPersonPhoneProperty);
//    NSLog(@"phoneNumbers=%d",phoneNumbers);
    if (ABMultiValueGetCount(phoneNumbers)>0) {
        CFStringRef phoneString = ABMultiValueCopyLabelAtIndex(phoneNumbers, 0);
        CFStringRef phoneTyleRawString = ABMultiValueCopyLabelAtIndex(phoneNumbers, 0);
        NSString *localizedPhoneTypeString = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(phoneTyleRawString);
        NSLog(@"%@ %@",phoneString,localizedPhoneTypeString);
        CFRelease(phoneString);
        CFRelease(phoneTyleRawString);
        CFRelease(phoneNumbers);
    }
    
    //获取地址信息
    ABMultiValueRef streetAddress = ABRecordCopyValue(recordRef, kABPersonAddressProperty);
    if (ABMultiValueGetCount(streetAddress)>0) {
        NSDictionary *streetAddressDict = (__bridge_transfer NSDictionary *)ABMultiValueCopyLabelAtIndex(streetAddress, 0);
        NSLog(@"streetAddress=%@",streetAddress);
        CFRelease(streetAddress);
    }
    
    CFRelease(recordRef);
    return cell;
}
#pragma ABPeoplePickerNavigationControllerDelegate
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
//    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    NSLog(@"person=%@",person);
    return NO;
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
     NSLog(@"person=%@",person);
    return NO;
}

#pragma ABPersonViewControllerDelegate
-(BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    return YES;
}

#pragma ABNewPersonViewControllerDelegate
-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    
    CFErrorRef error;
    if (person) {
        ABAddressBookAddRecord(_addressBook, person,&error);
        ABAddressBookSave(_addressBook, &error);
        if (error) {
            NSLog(@"%@",error);
        }
    }
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableView *)addressView{
    if (!_addressView) {
        _addressView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _addressView.delegate = self;
        _addressView.dataSource = self;
        [_addressView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    }
    return _addressView;
}


@end

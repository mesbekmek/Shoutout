//
//  Contact.m
//  Shoutout
//
//  Created by Jason Wang on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "Contact.h"

#import <Parse/Parse.h>
#import <Contacts/Contacts.h>

@implementation Contact

-(instancetype)initWithPhoneNumberArray{
    if (self = [super init]) {
        self.phoneNumber = [NSMutableArray new];
        return self;
    }
    return nil;
}


-(void)contactsQueryParseBaseOnPhoneBook:(NSArray <APContact *> *)phoneBook withBlock:(void (^)(NSMutableDictionary *namesForNumbers, NSArray <User *>*users))onCompletion{
    
    NSMutableDictionary *namesForNumbers = [NSMutableDictionary new];
    
    NSMutableArray *allPhoneNumber = [[NSMutableArray alloc]init];
    for (APContact *contact in phoneBook) {
        NSString *phoneNumber = contact.phones[0].number;
        NSString *formatedPhoneNumber = [self formatePhoneNumberTo10Digit:phoneNumber];
        NSLog(@"%@",formatedPhoneNumber);
        if ([formatedPhoneNumber length] == 10) {
            
            [allPhoneNumber addObject:formatedPhoneNumber];
            NSString *first_name = contact.name.firstName? contact.name.firstName : @"";
            NSString *last_name = contact.name.lastName? contact.name.lastName : @"";
            [namesForNumbers setObject:[NSString stringWithFormat:@"%@ %@",first_name, last_name] forKey:formatedPhoneNumber];
        } else {
            continue;
        }

        
        }
    
    PFQuery *query = [User query];
    [query whereKey:@"phoneNumber" containedIn:allPhoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count == 0) {
            NSLog(@"Object count is == 0 for phoneNumber query");
        }
        if (!error) {
            NSLog(@"phoneBook Query Object %ld", objects.count);
            NSMutableArray <User *> *allUser = [NSMutableArray new];
            allUser =[NSMutableArray arrayWithArray: objects];
            
            onCompletion(namesForNumbers,allUser);
            
        } else {
            NSLog(@"ERROR!!! contact Model === %@",error);
        }
    }];
}

-(NSString *)formatePhoneNumberTo10Digit:(NSString *)phoneNumber{
        NSString *formatedPhoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                         componentsJoinedByString:@""];
        if ([formatedPhoneNumber length] == 10) {
            
            NSLog(@"Number selected %@",formatedPhoneNumber);
            return formatedPhoneNumber;
    
        } else if ([formatedPhoneNumber length] == 11 && [formatedPhoneNumber hasPrefix:@"1"]) {
    
            NSLog(@"Number selected %@",[formatedPhoneNumber substringFromIndex:1]);
            return [formatedPhoneNumber substringFromIndex:1];
        } else {
            NSLog(@"Phone Number ----- %@",phoneNumber);
            return nil;
            
        }
}

- (void)contactsQuery:(void (^)(NSMutableArray<Contact *> *, BOOL))onCompletion{
    
    CNContactStore *store = [[CNContactStore alloc]init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            NSArray *keys = @[CNContactGivenNameKey, CNContactPhoneNumbersKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContact = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                
                NSLog(@"Error fetching contacts %@",error);
                onCompletion(nil, NO);
                
            } else {
                
                NSMutableArray <Contact *> *contactsFromPhoneBook = [NSMutableArray new];
                
                for (CNContact *contact in cnContact) {
                    Contact *newContact = [[Contact alloc]initWithPhoneNumberArray];
                    newContact.firstName = contact.givenName;
                    NSLog(@"first name %@",newContact.firstName);
                    //                    newContact.lastName = contact.familyName;
                    
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        NSString *phoneNumber = [label.value stringValue];
                        if (phoneNumber != nil) {
                            [newContact.phoneNumber addObject:[label.value stringValue]];
                            NSLog(@"phone number %@", newContact.phoneNumber);
                        } else {
                            [newContact.phoneNumber addObject:@"N/A"];
                        }
                    }
                    
                    [contactsFromPhoneBook addObject:newContact];
                    NSLog(@"adding to contacts from phone book array");
                    
                }
             
                onCompletion(contactsFromPhoneBook, YES);
            }
        }
    }];
}

#pragma mark Convenience method for doing set subtraction on APContacts

-(void)queryParseContactsBasedOnPhoneBook:(NSArray <APContact *> *)phoneBook withBlock:(void (^)(NSMutableDictionary *apContactsForNumbers, NSMutableDictionary *usernameForNumbers))onCompletion{
    
    NSMutableDictionary *namesForNumbers = [NSMutableDictionary new];
    
    NSMutableArray *allPhoneNumber = [[NSMutableArray alloc]init];
    NSMutableDictionary *apContactForNumber = [[NSMutableDictionary alloc] init];
    for (APContact *contact in phoneBook) {
        NSString *phoneNumber = contact.phones[0].number;
        NSString *formatedPhoneNumber = [self formatePhoneNumberTo10Digit:phoneNumber];
        
        [apContactForNumber setObject:contact forKey:formatedPhoneNumber];
        NSLog(@"%@",formatedPhoneNumber);
        if ([formatedPhoneNumber length] == 10) {
            
            [allPhoneNumber addObject:formatedPhoneNumber];
            NSString *first_name = contact.name.firstName? contact.name.firstName : @"";
            NSString *last_name = contact.name.lastName? contact.name.lastName : @"";
            
            [namesForNumbers setObject:[NSString stringWithFormat:@"%@ %@",first_name, last_name] forKey:formatedPhoneNumber];
        } else {
            continue;
        }
        
        
    }
    NSMutableArray<APContact *> *contactsWithShoutout = [[NSMutableArray alloc] init];
    PFQuery *query = [User query];
    [query whereKey:@"phoneNumber" containedIn:allPhoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count == 0) {
            NSLog(@"Object count is == 0 for phoneNumber query");
        }
        if (!error) {
            NSLog(@"phoneBook Query Object %lu", objects.count);
            NSMutableArray <User *> *allUsers = [NSMutableArray new];
            allUsers =[NSMutableArray arrayWithArray: objects];
            
            NSMutableDictionary *usernamesForNumbers = [NSMutableDictionary new];
            for(User *user in allUsers )
            {
                [usernamesForNumbers setObject:user.username forKey:user.phoneNumber];
            
               
//                APContact *contact = [[APContact alloc] init];
//                
//                //Get Contacts Name
//                APName *contactName = [[APName alloc] init];
//                NSString *phoneNumberForName = allPhoneNumber[i];
//                NSString *firstNameAndLastName = [namesForNumbers objectForKey:phoneNumberForName];
//                
//                NSArray *array = [firstNameAndLastName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                contactName.firstName = array[0];
//                contactName.lastName = array[1];
//                contact.name = contactName;
//                
//                //Get Contacts Phone
//                APPhone *contactPhone = [[APPhone alloc] init];
//                contactPhone.number = phoneNumberForName;
//                contact.phones = @[contactPhone];
//                
//                [contactsWithShoutout addObject:contact];
            }
            
            
            onCompletion(apContactForNumber,usernamesForNumbers);
            
        } else {
            NSLog(@"ERROR!!! contact Model === %@",error);
        }
    }];
}

@end

//
//  Contact.m
//  Shoutout
//
//  Created by Jason Wang on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "Contact.h"
#import <Contacts/Contacts.h>

@implementation Contact

-(instancetype)initWithPhoneNumberArray{
    if (self = [super init]) {
        self.phoneNumber = [NSMutableArray new];
        return self;
    }
    return nil;
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

@end

//
//  Contact.h
//  Shoutout
//
//  Created by Jason Wang on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APContact.h"
#import "APPhone.h"
#import "SOModel.h"

@interface Contact : NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSMutableArray *phoneNumber;

-(instancetype)initWithPhoneNumberArray;
- (void)contactsQuery:(void (^) (NSMutableArray <Contact *> *allContacts, BOOL didComplete))onCompletion;
-(void)contactsQueryParseBaseOnPhoneBook:(NSArray <APContact *> *)phoneBook withBlock:(void (^)(NSMutableDictionary *namesForNumbers, NSArray <User *>*users))onCompletion;

-(void)queryParseContactsBasedOnPhoneBook:(NSArray <APContact *> *)phoneBook withBlock:(void (^)(NSMutableDictionary *apContactsForNumbers, NSMutableDictionary *usernameForNumbers))onCompletion;
@end

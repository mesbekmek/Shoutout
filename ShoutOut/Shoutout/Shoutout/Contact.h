//
//  Contact.h
//  Shoutout
//
//  Created by Jason Wang on 11/22/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSMutableArray *phoneNumber;

-(instancetype)initWithPhoneNumberArray;
- (void)contactsQuery:(void (^) (NSMutableArray <Contact *> *allContacts, BOOL didComplete))onCompletion;
@end

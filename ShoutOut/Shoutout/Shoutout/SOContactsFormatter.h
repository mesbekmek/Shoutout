//
//  SOContactsFormatter.h
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOContactsFormatter : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *phoneNumber;

+(NSArray<SOContactsFormatter *>*)getNameAndPhoneNumberForDictionary:(NSMutableDictionary*)apContactsDict andKeys:(NSArray *)allKeys;

+(NSArray<SOContactsFormatter *>*)getNameAndUsernameForDictionary:(NSMutableDictionary*)apContactsDict andDictionary:(NSMutableDictionary *)usernameDict;

@end

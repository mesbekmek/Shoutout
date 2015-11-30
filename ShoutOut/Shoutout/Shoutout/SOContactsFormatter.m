//
//  SOContactsFormatter.m
//  Shoutout
//
//  Created by Mesfin Bekele Mekonnen on 11/29/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "SOContactsFormatter.h"
#import "APContact.h"


@implementation SOContactsFormatter

+(NSArray<SOContactsFormatter *>*)getNameAndPhoneNumberForDictionary:(NSMutableDictionary*)apContactsDict andKeys:(NSArray *)allKeys
{
    NSMutableArray<SOContactsFormatter *>* soContactsArray = [NSMutableArray new];
    for(NSString *key in allKeys)
    {
        APContact *apContact = apContactsDict[key];
        
        SOContactsFormatter *contact = [[SOContactsFormatter alloc] init];
        NSString *firstName =  apContact.name.firstName;
        NSString *lastName =  apContact.name.lastName;
        
        contact.name = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        
        contact.phoneNumber = key;
        
        [soContactsArray addObject:contact];
    }
    
    [soContactsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    return soContactsArray;
}

+(NSArray<SOContactsFormatter *>*)getNameAndUsernameForDictionary:(NSMutableDictionary*)apContactsDict andDictionary:(NSMutableDictionary *)usernameDict
{
    NSArray *allKeysInUserNameDict = [usernameDict allKeys];
    
    //Using an NSSet for constant time lookup, but increases space complexity
    //http://stackoverflow.com/questions/7396919/how-might-i-check-if-a-particular-nsstring-is-present-in-an-nsarray
    
    NSSet *set = [NSSet setWithArray:[apContactsDict allKeys]];
    
    NSMutableArray<SOContactsFormatter *>* soContactsArray = [NSMutableArray new];
    
    
    for(NSString *key in allKeysInUserNameDict)
    {
        if([set containsObject:key])
        {
            SOContactsFormatter *contact = [[SOContactsFormatter alloc] init];
            contact.username = usernameDict[key];
            
            APContact *apContact = apContactsDict[key];
            NSString *firstName =  apContact.name.firstName;
            NSString *lastName =  apContact.name.lastName ? apContact.name.lastName : @"";
            
            contact.name = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
            
            [soContactsArray addObject:contact];
        }
        else
        {
            continue;
        }
        
    }
    [soContactsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    return soContactsArray;
}

@end

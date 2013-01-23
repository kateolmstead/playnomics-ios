//
//  Util.h
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PNConstants.h"

#import "PlaynomicsSession.h"

@interface PNUtil : NSObject

+ (NSString *) getDeviceUniqueIdentifier;

+ (UIInterfaceOrientation) getCurrentOrientation;

+(PNEventType) PNEventTypeValueOf: (NSString *) text;
+(NSString *) PNEventTypeDescription:  (PNEventType) value;

+(PNResponseType) PNResponseTypeValueOf: (NSString *) text;
+(NSString *) PNResponseTypeDescription: (PNResponseType) value;

+(PNTransactionType) PNTransactionTypeValueOf: (NSString *) text;
+(NSString *) PNTransactionTypeDescription: (PNTransactionType) value;

+(PNCurrencyCategory) PNCurrencyCategoryValueOf: (NSString *) text;
+(NSString *) PNCurrencyCategoryDescription: (PNCurrencyCategory) value;

+(PNCurrencyType) PNCurrencyTypeValueOf:(NSString *) text;
+ (NSString *) PNCurrencyTypeDescription:(PNCurrencyType) value;

+(PNUserInfoType) PNUserInfoTypeValueOf: (NSString *) text;
+(NSString *) PNUserInfoTypeDescription: (PNUserInfoType) value;

+(PNUserInfoSex) PNUserInfoSexValueOf: (NSString *) text;
+(NSString *) PNUserInfoSexDescription: (PNUserInfoSex) value;

+(PNUserInfoSource) PNUserInfoSourceValueOf: (NSString *) text;
+(NSString *) PNUserInfoSourceDescription: (PNUserInfoSource) value;


@end


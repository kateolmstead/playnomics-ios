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

typedef enum{
    AdTargetUrl,
    AdTargetData,
    AdTargetUnknown
} AdTarget;

typedef enum {
    AdActionHTTP,           // Standard HTTP/HTTPS page to open in a browser
    AdActionDefinedAction,  // Defined selector to execute on a registered delegate
    AdActionExecuteCode,    // Submit the action on the delegate
    AdActionUnknown,        // Unknown ad action specified
    AdActionNullTarget,     // No target was specified
} AdAction;

@interface PNUtil : NSObject

+ (NSString *) getDeviceUniqueIdentifier;
+ (NSString *) getVendorIdentifier;
+ (NSDictionary *) getAdvertisingInfo;

+ (UIInterfaceOrientation) getCurrentOrientation;

+(PNEventType) PNEventTypeValueOf: (NSString *) text;
+(NSString *) PNEventTypeDescription:  (PNEventType) value;

+(PNTransactionType) PNTransactionTypeValueOf: (NSString *) text;
+(NSString *) PNTransactionTypeDescription: (PNTransactionType) value;

+(PNCurrencyCategory) PNCurrencyCategoryValueOf: (NSString *) text;
+(NSString *) PNCurrencyCategoryDescription: (PNCurrencyCategory) value;

+(PNCurrencyType) PNCurrencyTypeValueOf:(NSString *) text;
+ (NSString *) PNCurrencyTypeDescription:(PNCurrencyType) value;

+(NSString *) urlEncodeValue: (NSString *) unescapedValue;

+ (BOOL) isUrl:(NSString*) url;
+ (id) deserializeJsonData: (NSData*) jsonData ;
+ (id) deserializeJsonDataWithOptions: (NSData*) jsonData readOptions: (NSJSONReadingOptions) readOptions ;
+ (id) deserializeJsonString:(NSString *)jsonString;
@end


//
//  Util.h
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c 2012 Grio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    PNErrorTypeUndefined,
    PNErrorTypeInvalidJson
}PNErrorType;


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
+ (UIInterfaceOrientation) getCurrentOrientation;
+ (NSString *) urlEncodeValue: (NSString*) unescapedValue;
+ (BOOL) isUrl:(NSString *) url;
+ (NSString *) boolAsString: (BOOL) value;
+ (BOOL) stringAsBool : (NSString *) value;
+ (id) deserializeJsonData: (NSData *) jsonData ;
+ (id) deserializeJsonDataWithOptions: (NSData *) jsonData readOptions: (NSJSONReadingOptions) readOptions ;
+ (id) deserializeJsonString:(NSString *)jsonString;
+ (int) timezoneOffet;
+ (unsigned long long) generateRandomLongLong;
+ (CGRect) getScreenDimensions;
+ (NSString *) getLanguage;
@end
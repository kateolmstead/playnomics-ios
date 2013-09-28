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
+ (CGRect) getScreenDimensionsInView;
+ (NSString *) getLanguage;
@end
//
//  Util.m
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "PNUtil.h"


@implementation PNUtil

+ (UIInterfaceOrientation)getCurrentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (NSString *) urlEncodeValue: (NSString *) unescapedValued {
    if([unescapedValued length] ==  0){
        return nil;
    }
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes( NULL, (CFStringRef)unescapedValued, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    return [result autorelease];
}

+ (BOOL) isUrl:(NSString *) url {
    if(!url || [url length] == 0){
        return NO;
    }
    return [url hasPrefix:@"https://"] || [url hasPrefix: @"http://"];
}

+(id) deserializeJsonString:(NSString *)jsonString{
    NSData* encodedData = [jsonString  dataUsingEncoding:NSUTF8StringEncoding];
    return [self deserializeJsonData: encodedData];
}

+(id) deserializeJsonData: (NSData *) jsonData {
    return [self deserializeJsonDataWithOptions: jsonData readOptions: kNilOptions];
}

+(id) deserializeJsonDataWithOptions: (NSData *) jsonData readOptions: (NSJSONReadingOptions) readOptions {
    NSError *error = nil;
    id data = [NSJSONSerialization JSONObjectWithData:jsonData options: readOptions error:&error];
    if(error){
        NSLog(@"Could not parse JSON string. Received error: %@", [error localizedDescription]);
    }
    return data;
}

+(NSString *) boolAsString: (BOOL) value {
    return value ? @"true" : @"false";
}

+(BOOL) stringAsBool : (NSString *) value {
    return (value && [[value lowercaseString] isEqualToString:@"true"]) ? YES : NO;
}

+(int) timezoneOffet{
    return [[NSTimeZone localTimeZone] secondsFromGMT] / -60;
}

+ (unsigned long long) generateRandomLongLong{
    uint8_t buffer[8];
    arc4random_buf(buffer, sizeof buffer);
    uint64_t* value_ptr = (uint64_t*) buffer;
    return abs(*value_ptr);
}

+ (CGRect) getScreenDimensions{
    return [[UIScreen mainScreen] applicationFrame];
}

@end

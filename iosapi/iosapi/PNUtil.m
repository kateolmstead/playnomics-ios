//
//  Util.m
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "PNUtil.h"


@implementation PNUtil

/*  The Pasteboard is kept in memory even if the app is deleted.
 *  This provides a suitable means for having a unique device ID
 */
+ (UIInterfaceOrientation)getCurrentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (NSString*) PNEventTypeDescription: (PNEventType) value {
    switch (value) {
        case PNEventAppStart:
            return @"appStart";
        case PNEventAppPage:
            return @"appPage";
        case PNEventAppRunning:
            return @"appRunning";
        case PNEventAppPause:
            return @"appPause";
        case PNEventAppResume:
            return @"appResume";
        case PNEventAppStop:
            return @"appStop";
        case PNEventUserInfo:
            return @"userInfo";
        case PNEventTransaction:
            return @"transaction";
        case PNEventMilestone:
            return @"milestone";
        case PNEventError:
            return @"jslog";
        case PNEventPushNotificationToken:
            return @"userInfo";
        case PNEventPushNotificationPayload:
            return @"userInfo";
    }
    return nil;
}
 
+ (NSString *) urlEncodeValue: (NSString*) unescapedValued {
    if([unescapedValued length] ==  0){
        return NULL;
    }
    NSString* result = (NSString *)CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (CFStringRef)unescapedValued,
        NULL,
        CFSTR("!*'();:@&=+$,/?%#[]"),
        kCFStringEncodingUTF8);
    return [result autorelease];
}

+ (BOOL) isUrl:(NSString*) url {
    if([url length] == 0){
        return NO;
    }
    return [url hasPrefix:@"https://"] || [url hasPrefix: @"http://"];
}

+(id) deserializeJsonString:(NSString *)jsonString{
    NSData* encodedData = [jsonString  dataUsingEncoding:NSUTF8StringEncoding];
    return [self deserializeJsonData: encodedData];
}


+ (id) deserializeJsonData: (NSData*) jsonData {
    return [self deserializeJsonDataWithOptions: jsonData readOptions: kNilOptions];
}

+ (id) deserializeJsonDataWithOptions: (NSData*) jsonData readOptions: (NSJSONReadingOptions) readOptions {
    NSError* error = nil;
    id data = [NSJSONSerialization JSONObjectWithData:jsonData options: readOptions error:&error];
    if(error != nil){
        NSLog(@"Could not parse JSON string. Received error: %@", [error localizedDescription]);
    }
    return data;
}
@end

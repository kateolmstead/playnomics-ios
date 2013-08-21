//
//  Util.m
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "PlaynomicsSession+Exposed.h"
#import "PNUtil.h"
#import <AdSupport/AdSupport.h>


@implementation PNUtil

/*  The Pasteboard is kept in memory even if the app is deleted.
 *  This provides a suitable means for having a unique device ID
 */
+ (NSString *) getDeviceUniqueIdentifier {
    // First check the old pasteboard (pre v8.2) to see if the Playnomics breadcrumbId exists
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:PNUserDefaultsLastDeviceID create:NO];
    NSString *storedUUID = [pasteBoard string];
    
    // If it doesn't exist, create a new Playnomics breadcrumbId, but don't save it anywhere
    // The calling method will save it
    if ([storedUUID length] == 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        storedUUID = [(NSString *)CFUUIDCreateString(NULL,uuidRef) autorelease];
        CFRelease(uuidRef);
    }
    
    return storedUUID;
}

// Unique to an app group, which is tied by the organization deploying the apps to the AppStore
+ (NSString *) getVendorIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSLog(@"Latest IDFV is:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        NSLog(@"No IDFV so this must be a pre-iOS 6 device");
        return @"";
    }
}

+ (NSDictionary *) getAdvertisingInfo {
    NSMutableDictionary *advertisingInfo = [NSMutableDictionary dictionary];
    
    if (NSClassFromString(@"ASIdentifierManager")) {
        ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
        
        [advertisingInfo setValue:(manager.isAdvertisingTrackingEnabled ? @"false" : @"true") forKey:PNPasteboardLastLimitAdvertising];
        [advertisingInfo setValue:[manager.advertisingIdentifier UUIDString] forKey:PNPasteboardLastIDFA];
        
        NSLog(@"Latest Advertising Information is:%@", advertisingInfo);
    } else {
        NSLog(@"No Advertising Information available so this must be a pre-iOS 6 device");
    }
    
    return advertisingInfo;
}

+ (UIInterfaceOrientation)getCurrentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

+(PNEventType) PNEventTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"appStart"])
            return PNEventAppStart;
        else if ([text isEqualToString:@"appPage"])
            return PNEventAppPage;
        else if ([text isEqualToString:@"appRunning"])
            return PNEventAppRunning;
        else if ([text isEqualToString:@"appPause"])
            return PNEventAppPause;
        else if ([text isEqualToString:@"appResume"])
            return PNEventAppResume;
        else if ([text isEqualToString:@"appStop"])
            return PNEventAppStop;
        else if ([text isEqualToString:@"userInfo"])
            return PNEventUserInfo;
        else if ([text isEqualToString:@"sessionStart"])
            return PNEventSessionStart;
        else if ([text isEqualToString:@"sessionEnd"])
            return PNEventSessionEnd;
        else if ([text isEqualToString:@"gameStart"])
            return PNEventGameStart;
        else if ([text isEqualToString:@"gameEnd"])
            return PNEventGameEnd;
        else if ([text isEqualToString:@"transaction"])
            return PNEventTransaction;
        else if ([text isEqualToString:@"invitationSent"])
            return PNEventInvitationSent;
        else if ([text isEqualToString:@"invitationResponse"])
            return PNEventInvitationResponse;
        else if ([text isEqualToString:@"milestone"])
            return PNEventMilestone;
        else if ([text isEqualToString:@"jslog"])
            return PNEventError;
        else if ([text isEqualToString:@"pushNotificationToken"])
            return PNEventPushNotificationToken;
        else if ([text isEqualToString:@"pushNotificationPayload"])
            return PNEventPushNotificationPayload;
    }
    return -1;
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
        case PNEventSessionStart:
            return @"sessionStart";
        case PNEventSessionEnd:
            return @"sessionEnd";
        case PNEventGameStart:
            return @"gameStart";
        case PNEventGameEnd:
            return @"gameEnd";
        case PNEventTransaction:
            return @"transaction";
        case PNEventInvitationSent:
            return @"invitationSent";
        case PNEventInvitationResponse:
            return @"invitationResponse";
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

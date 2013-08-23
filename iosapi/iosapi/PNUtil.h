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

typedef enum {
    PNEventAppStart,
    PNEventAppPage,
    PNEventAppRunning,
    PNEventAppPause,
    PNEventAppResume,
    PNEventAppStop,
    PNEventUserInfo,
    PNEventSessionStart,
    PNEventSessionEnd,
    PNEventGameStart,
    PNEventGameEnd,
    PNEventTransaction,
    PNEventInvitationSent,
    PNEventInvitationResponse,
    PNEventMilestone,
    PNEventError,
    PNEventPushNotificationToken,
    PNEventPushNotificationPayload,
} PNEventType;

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
+ (PNEventType) PNEventTypeValueOf: (NSString*) text;
+ (NSString*) PNEventTypeDescription:  (PNEventType) value;
+ (NSString*) urlEncodeValue: (NSString*) unescapedValue;

+ (BOOL) isUrl:(NSString*) url;
+ (id) deserializeJsonData: (NSData*) jsonData ;
+ (id) deserializeJsonDataWithOptions: (NSData*) jsonData readOptions: (NSJSONReadingOptions) readOptions ;
+ (id) deserializeJsonString:(NSString *)jsonString;
@end


//
//  PlaynomicsSession+Exposed.h
//  iosapi
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#ifndef iosapi_PlaynomicsSession_Exposed_h
#define iosapi_PlaynomicsSession_Exposed_h
#import "PNDeviceInfo.h"
#import "PNErrorEvent.h"

/**
 *  Only use this within the Static Lib.
 */

@interface PlaynomicsSession()

@property (nonatomic, readonly) NSString * cookieId;
@property (nonatomic, readonly) NSString * sessionId;
@property (nonatomic, readonly) PNSessionState sessionState;

- (void) errorReport:(PNErrorDetail*)errorDetails;
- (void) onKeyPressed: (NSNotification *) notification;
- (void) onApplicationWillResignActive: (NSNotification *) notification;
- (void) onApplicationDidBecomeActive: (NSNotification *) notification;
- (void) onApplicationWillTerminate: (NSNotification *) notification;

- (NSString*) getMessagingUrl;
- (NSString*) getEventsUrl;
@end

#endif

//
//  PlaynomicsSession.h
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    SENT,
    QUEUED,
    SWITCHED,
    STOPPED,
    ALREADY_STARTED,
    ALREADY_SWITCHED,
    ALREADY_STOPPED,
    SESSION_RESUMED,
    START_NOT_CALLED,
    NO_INTERNET_PERMISSION,
    MISSING_REQ_PARAM,
    FAIL_UNKNOWN
} APIResult;

@interface PlaynomicsSession : NSObject

+ (APIResult) start: (UIViewController*) controller applicationId:(long) applicationId;
+ (APIResult) stop;
+ (APIResult) userInfo;

@end

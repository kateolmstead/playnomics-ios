//
//  PlaynomicsSession.h
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PLConstants.h"

@protocol PlaynomicsApiDelegate <NSObject>

@end

@interface PlaynomicsSession : NSObject {
    PLSessionState _sessionState;
}

+ (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId;
+ (PLAPIResult) stop;
+ (PLAPIResult) userInfo;

@end

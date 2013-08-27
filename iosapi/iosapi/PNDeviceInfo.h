//
//  PNUserInfo.h
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import <Foundation/Foundation.h>
#import "PNCache.h"
@interface PNDeviceInfo : NSObject
- (id) initWithCache: (PNCache *) cache;
- (BOOL) syncDeviceSettingsWithCache;
@end

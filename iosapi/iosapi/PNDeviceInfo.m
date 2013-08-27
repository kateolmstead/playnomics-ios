//
//  PNUserInfo.m
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import "PNDeviceInfo.h"
#import "PNCache.h"
#import <AdSupport/AdSupport.h>

@implementation PNDeviceInfo{
    PNCache *_cache;
}

- (id) initWithCache: (PNCache *) cache {
    if ((self = [super init])) {
        _cache = cache;
    }
    return self;
}

- (BOOL) syncDeviceSettingsWithCache {    
    if(![_cache getBreadcrumbID]){
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        [_cache setBreadcrumbID:[(NSString *)CFUUIDCreateString(NULL,uuidRef) autorelease]];
        CFRelease(uuidRef);
    }

    
    if (NSClassFromString(@"ASIdentifierManager")) {
        ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
        [_cache setLimitAdvertising: !manager.isAdvertisingTrackingEnabled];
        [_cache setIdfa:[manager.advertisingIdentifier UUIDString]];
    } else {
        NSLog(@"No Advertising Information available so this must be a pre-iOS 6 device");
    }

    UIDevice* currentDevice = [UIDevice currentDevice];
                                        
    if ([currentDevice respondsToSelector:@selector(identifierForVendor)]) {
        [_cache setIdfv: [[currentDevice identifierForVendor] UUIDString]];
    }
                                        
    return _cache.breadcrumbIDChanged || _cache.idfaChanged || _cache.idfvChanged || _cache.limitAdvertisingChanged;
}
@end
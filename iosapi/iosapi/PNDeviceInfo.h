//
//  PNUserInfo.h
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import <Foundation/Foundation.h>
@interface PNDeviceInfo : NSObject

@property(nonatomic, readonly) NSString* breadcrumbId;
@property(nonatomic, readonly) NSString* limitAdvertising;
@property(nonatomic, readonly) NSString* idfa;
@property(nonatomic, readonly) NSString* idfv;
@property(nonatomic, readonly) bool infoChanged;
- (id) init;
@end

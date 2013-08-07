//
//  PNUserInfo.h
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import <Foundation/Foundation.h>

/**
 * Protocol describing the methods called when any user information changes
 */
@protocol PNUserInfoChangeActionHandler

// Called on the delegate to perform some action when any user information changes
- (void)performActionOnIdsChangedWithBreadcrumbId: (NSString*) breadcrumbId
                              andLimitAdvertising: (NSString*) limitAdvertising
                                          andIDFA: (NSString*) idfa
                                          andIDFV: (NSString*) idfv;

@end

@interface PNUserInfo : NSObject

@property(nonatomic, retain) NSString* breadcrumbId;
@property(nonatomic, retain) NSString* limitAdvertising;
@property(nonatomic, retain) NSString* idfa;
@property(nonatomic, retain) NSString* idfv;

- (id) init: (id<PNUserInfoChangeActionHandler>) actionHandler;

@end

//  Playnomics PlayRM SDK
//  PlaynomicsSession.h
//  Copyright (c) 2012 Playnomics. All rights reserved.
//  Please see http://integration.playnomics.com for instructions.
//  Please contact support@playnomics.com for assistance.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//this is available in iOS 6 and above, add this in for iOS 5 and below
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(int, PNMilestoneType){
    PNMilestoneCustom1 = 1,
    PNMilestoneCustom2 = 2,
    PNMilestoneCustom3 = 3,
    PNMilestoneCustom4 = 4,
    PNMilestoneCustom5 = 5,
    PNMilestoneCustom6 = 6,
    PNMilestoneCustom7 = 7,
    PNMilestoneCustom8 = 8,
    PNMilestoneCustom9 = 9,
    PNMilestoneCustom10 = 10,
    PNMilestoneCustom11 = 11,
    PNMilestoneCustom12 = 12,
    PNMilestoneCustom13 = 13,
    PNMilestoneCustom14 = 14,
    PNMilestoneCustom15 = 15,
    PNMilestoneCustom16 = 16,
    PNMilestoneCustom17 = 17,
    PNMilestoneCustom18 = 18,
    PNMilestoneCustom19 = 19,
    PNMilestoneCustom20 = 20,
    PNMilestoneCustom21 = 21,
    PNMilestoneCustom22 = 22,
    PNMilestoneCustom23 = 23,
    PNMilestoneCustom24 = 24,
    PNMilestoneCustom25 = 25
};

@interface PlaynomicsSession : NSObject
@property (nonatomic, assign) bool testMode;
@property (nonatomic, copy) NSString* overrideEventsUrl;
@property (nonatomic, copy) NSString* overrideMessagingUrl;

@property (nonatomic, readonly) NSString* sdkVersion;
@property (nonatomic, readonly) signed long long applicationId;
@property (nonatomic, readonly) NSString * userId;

+ (PlaynomicsSession*) sharedInstance;

- (bool) startWithApplicationId:(signed long long) applicationId userId: (NSString *) userId;
- (bool) startWithApplicationId:(signed long long) applicationId;
- (void) milestone: (PNMilestoneType) milestoneType;
- (void) transactionWithUSDPrice: (NSNumber*) priceInUSD quantity: (NSInteger) quantity;

- (void) enablePushNotificationsWithToken: (NSData*)deviceToken;
- (void) pushNotificationsWithPayload: (NSDictionary*)payload;

- (void) onTouchDown: (UIEvent*) event;
@end

@interface PNApplication : UIApplication<UIApplicationDelegate>
- (void) sendEvent:(UIEvent *)event;
@end
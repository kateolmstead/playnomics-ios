//  Playnomics PlayRM SDK
//  PlaynomicsSession.h
//
//  Copyright (c) 2012 Playnomics. All rights reserved.
//
//  Please see http://integration.playnomics.com for instructions
//  Please contact support@playnomics.com for assistance

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  PNTransactionType
 *
 *  Possible Transaction Types
 */
typedef enum {
    PNTransactionBuyItem,
    PNTransactionSellItem,
    PNTransactionReturnItem,
    PNTransactionBuyService,
    PNTransactionSellService,
    PNTransactionReturnService,
    PNTransactionCurrencyConvert,
    PNTransactionInitial,
    PNTransactionFree,
    PNTransactionReward,
    PNTransactionGiftSend,
    PNTransactionGiftReceive
} PNTransactionType;

/**
 *  PNCurrencyCategory
 *
 *  Possible currency Categories for transactions
 */
typedef enum {
    PNCurrencyCategoryReal,
    PNCurrencyCategoryVirtual
} PNCurrencyCategory;

/**
 *  PNCurrencyType
 *
 *  Possible currency Types for transactions
 */
typedef enum {
    PNCurrencyUSD,
    PNCurrencyFBC,
    PNCurrencyOFD,
    PNCurrencyOFF
} PNCurrencyType;

@interface PlaynomicsSession : NSObject
+ (bool) startWithApplicationId:(signed long long) applicationId userId: (NSString *) userId;
+ (bool) startWithApplicationId:(signed long long) applicationId;

+ (void) setTestMode: (bool) testMode;
+ (bool) getTestMode;

+ (NSString*) getOverrideMessagingUrl;
+ (void) setOverrideMessagingUrl: (NSString*) url;

+ (NSString*) getOverrideEventsUrl;
+ (void) setOverrideEventsUrl: (NSString*) url;

+ (NSString*) getSDKVersion;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyType: (PNCurrencyType) currencyType currencyValue: (double) currencyValue currencyCategory: (PNCurrencyCategory) currencyCategory;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyTypeAsString: (NSString *) currencyType currencyValue: (double) currencyValue currencyCategory: (PNCurrencyCategory) currencyCategory;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyTypes: (NSArray *) currencyTypes currencyValues: (NSArray *) currencyValues currencyCategories: (NSArray *) currencyCategories;

+ (void) milestoneWithId: (signed long long) milestoneId
                        andName: (NSString *) milestoneName;

+ (void) enablePushNotificationsWithToken:(NSData*)deviceToken;

+ (void) pushNotificationsWithPayload:(NSDictionary*)payload;

+ (void) onTouchDown: (UIEvent*) event;
@end

@interface PNApplication : UIApplication<UIApplicationDelegate>
- (void) sendEvent:(UIEvent *)event;
@end
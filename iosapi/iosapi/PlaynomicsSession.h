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
 *  PNAPIResult
 *
 *  Possible results for PlaynomicsSession messages
 */
typedef enum {
    PNAPIResultNotSent,
    PNAPIResultSent,
    PNAPIResultQueued,
    PNAPIResultSwitched,
    PNAPIResultStopped,
    PNAPIResultAlreadyStarted,
    PNAPIResultAlreadySwitched,
    PNAPIResultAlreadyStopped,
    PNAPIResultSessionResumed,
    PNAPIResultStartNotCalled,
    PNAPIResultNoInternetPermission,
    PNAPIResultMissingReqParam,
    PNAPIResultFailUnkown
} PNAPIResult;


/**
 *  PNResponseType
 *
 *  Possible responses for the invitations/SocialEvents
 */
typedef enum {
    PNResponseTypeAccepted
} PNResponseType;

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

/**
 *  PNUserInfoType
 *
 *  Possible User Info requests types
 */
typedef enum {
    PNUserInfoTypeUpdate
} PNUserInfoType;

/**
 *  PNUserInfoSex
 *
 *  Possible Sex types.
 *  Sent in a user update request.
 */
typedef enum {
    PNUserInfoSexMale,
    PNUserInfoSexFemale,
    PNUserInfoSexUnknown
} PNUserInfoSex;

/**
 *  PNUserInfoSource
 *
 *  Where the User Info comes from.
 *  Sent in a user update request.
 */
typedef enum {
    PNUserInfoSourceAdwords,
    PNUserInfoSourceDoubleClick,
    PNUserInfoSourceYahooAds,
    PNUserInfoSourceMSNAds,
    PNUserInfoSourceAOLAds,
    PNUserInfoSourceAdbrite,
    PNUserInfoSourceFacebookAds,
    PNUserInfoSourceGoogleSearch,
    PNUserInfoSourceYahooSearch,
    PNUserInfoSourceBingSearch,
    PNUserInfoSourceFacebookSearch,
    PNUserInfoSourceApplifier,
    PNUserInfoSourceAppStrip,
    PNUserInfoSourceVIPGamesNetwork,
    PNUserInfoSourceUserReferral,
    PNUserInfoSourceInterGame,
    PNUserInfoSourceOther
} PNUserInfoSource;

@interface PlaynomicsSession : NSObject

+ (BOOL) startWithApplicationId:(signed long long) applicationId userId: (NSString *) userId;
+ (BOOL) startWithApplicationId:(signed long long) applicationId;
+ (void) stop;

+ (void) setTestMode: (bool) testMode;
+ (bool) getTestMode;

+ (NSString*) getOverrideMessagingUrl;
+ (void) setOverrideMessagingUrl: (NSString*) url;

+ (NSString*) getOverrideEventsUrl;
+ (void) setOverrideEventsUrl: (NSString*) url;

+ (NSString*) getSDKVersion;
@end

@interface PlaynomicsSession (Events)
+ (void) userInfoForType: (PNUserInfoType) type country: (NSString *) country subdivision: (NSString *) subdivision sex: (PNUserInfoSex) sex birthday: (NSDate *) birthday source: (PNUserInfoSource) source sourceCampaign: (NSString *) sourceCampaign installTime: (NSDate *) installTime;

+ (void) userInfoForType: (PNUserInfoType) type country: (NSString *) country subdivision: (NSString *) subdivision sex: (PNUserInfoSex) sex birthday: (NSDate*) birthday sourceAsString: (NSString*) source sourceCampaign: (NSString*) sourceCampaign installTime: (NSDate *) installTime;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyType: (PNCurrencyType) currencyType currencyValue: (double) currencyValue currencyCategory: (PNCurrencyCategory) currencyCategory;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyTypeAsString: (NSString *) currencyType currencyValue: (double) currencyValue currencyCategory: (PNCurrencyCategory) currencyCategory;

+ (void) transactionWithId: (signed long long) transactionId itemId: (NSString *) itemId quantity: (double) quantity type: (PNTransactionType) type otherUserId: (NSString *) otherUserId currencyTypes: (NSArray *) currencyTypes currencyValues: (NSArray *) currencyValues currencyCategories: (NSArray *) currencyCategories;

+ (void) invitationSentWithId: (signed long long) invitationId recipientUserId: (NSString *) recipientUserId recipientAddress: (NSString *) recipientAddress method: (NSString *) method;

+ (void) invitationResponseWithId: (signed long long) invitationId
                         recipientUserId: (NSString *) recipientUserId
                            responseType: (PNResponseType) responseType;

+ (void) milestoneWithId: (signed long long) milestoneId
                        andName: (NSString *) milestoneName;


+ (void) enablePushNotificationsWithToken:(NSData*)deviceToken;

+ (void) pushNotificationsWithPayload:(NSDictionary*)payload ;

+ (PNAPIResult) errorReport:(id)errorDetails;

+(void) onTouchDown: (UIEvent*) event;

@end

@interface PNApplication : UIApplication<UIApplicationDelegate>
- (void) sendEvent:(UIEvent *)event;
@end

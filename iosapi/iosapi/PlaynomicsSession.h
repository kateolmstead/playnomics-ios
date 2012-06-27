//
//  PlaynomicsSession.h
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 
 *  PLAPIResult
 *
 *  Possible results for PlaynomicsSession messages
 */
typedef enum {
    PLAPIResultSent,
    PLAPIResultQueued,
    PLAPIResultSwitched,
    PLAPIResultStopped,
    PLAPIResultAlreadyStarted,
    PLAPIResultAlreadySwitched,
    PLAPIResultAlreadyStopped,
    PLAPIResultSessionResumed,
    PLAPIResultStartNotCalled,
    PLAPIResultNoInternetPermission,
    PLAPIResultMissingReqParam,
    PLAPIResultFailUnkown
} PLAPIResult;


/** 
 *  PLResponseType
 *
 *  Possible responses for the invitations/SocialEvents
 */
typedef enum {
    PLResponseTypeAccepted
} PLResponseType;

/**
 *  PLTransactionType
 *
 *  Possible Transaction Types
 */
typedef enum {
    PLTransactionBuyItem,
    PLTransactionSellItem,
    PLTransactionReturnItem,
    PLTransactionBuyService,
    PLTransactionSellService,
    PLTransactionReturnService,
    PLTransactionCurrencyConvert,
    PLTransactionInitial,
    PLTransactionFree,
    PLTransactionReward,
    PLTransactionGiftSend,
    PLTransactionGiftReceive
} PLTransactionType;

/**
 *  PLCurrencyCategory
 *  
 *  Possible currency Categories for transactions
 */
typedef enum {
    PLCurrencyCategoryReal,
    PLCurrencyCategoryVirtual
} PLCurrencyCategory;

/**
 *  PLCurrencyType
 *
 *  Possible currency Types for transactions
 */
typedef enum {
    PLCurrencyUSD,
    PLCurrencyFBC,
    PLCurrencyOFD,
    PLCurrencyOFF
} PLCurrencyType;

/**
 *  PLUserInfoType
 *
 *  Possible User Info requests types
 */
typedef enum {
    PLUserInfoTypeUpdate
} PLUserInfoType;

/**
 *  PLUserInfoSex
 *
 *  Possible Sex types.
 *  Sent in a user update request.
 */
typedef enum {
    PLUserInfoSexMale,
    PLUserInfoSexFemale,
    PLUserInfoSexUnknown
} PLUserInfoSex;

/**
 *  PLUserInfoSource
 *
 *  Where the User Info comes from.
 *  Sent in a user update request.
 */
typedef enum {
    PLUserInfoSourceAdwords,
    PLUserInfoSourceDoubleClick,
    PLUserInfoSourceYahooAds,
    PLUserInfoSourceMSNAds,
    PLUserInfoSourceAOLAds,
    PLUserInfoSourceAdbrite,
    PLUserInfoSourceFacebookAds,
    PLUserInfoSourceGoogleSearch,
    PLUserInfoSourceYahooSearch,
    PLUserInfoSourceBingSearch,
    PLUserInfoSourceFacebookSearch,
    PLUserInfoSourceApplifier,
    PLUserInfoSourceAppStrip,
    PLUserInfoSourceVIPGamesNetwork,
    PLUserInfoSourceUserReferral,
    PLUserInfoSourceInterGame,
    PLUserInfoSourceOther
} PLUserInfoSource;

@interface PlaynomicsSession : NSObject
/**
 * Start.
 * 
 * @param applicationId
 *            the application id
 * @param userId
 *            the user id
 * @return the API Result
 */
+ (PLAPIResult) startWithApplicationId:(long) applicationId userId: (NSString *) userId;

/**
 * Start.
 * 
 * @param applicationId
 *            the application id
 * @return the API Result
 */
+ (PLAPIResult) startWithApplicationId:(long) applicationId;

/**
 * Stop.
 * 
 * @return the API Result
 */
+ (PLAPIResult) stop;

@end

@interface PlaynomicsSession (Events)
/**
 * User info.
 * 
 * @return the API Result
 */
+ (PLAPIResult) userInfo;

/**
 * User info.
 * 
 * @param type
 *            the type
 * @param country
 *            the country
 * @param subdivision
 *            the subdivision
 * @param sex
 *            the sex
 * @param birthday
 *            the birthday
 * @param source
 *            the source
 * @param sourceCampaign
 *            the source campaign
 * @param installTime
 *            the install time
 * @return the API Result
 */
+ (PLAPIResult) userInfoForType: (PLUserInfoType) type 
                        country: (NSString *) country 
                    subdivision: (NSString *) subdivision
                            sex: (PLUserInfoSex) sex
                       birthday: (NSDate *) birthday
                         source: (PLUserInfoSource) source 
                 sourceCampaign: (NSString *) sourceCampaign 
                    installTime: (NSDate *) installTime;

/**
 * Session start.
 * 
 * @param sessionId
 *            the session id
 * @param site
 *            the site
 * @return the API Result
 */
+ (PLAPIResult) sessionStartWithId: (NSString *) sessionId site: (NSString *) site;

/**
 * Session end.
 * 
 * @param sessionId
 *            the session id
 * @param reason
 *            the reason
 * @return the API Result
 */
+ (PLAPIResult) sessionEndWithId: (NSString *) sessionId reason: (NSString *) reason;

/**
 * Game start.
 * 
 * @param instanceId
 *            the instance id
 * @param sessionId
 *            the session id
 * @param site
 *            the site
 * @param type
 *            the type
 * @param gameId
 *            the game id
 * @return the API Result
 */
+ (PLAPIResult) gameStartWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId site: (NSString *) site type: (NSString *) type gameId: (NSString *) gameId;

/**
 * Game end.
 * 
 * @param instanceId
 *            the instance id
 * @param sessionId
 *            the session id
 * @param reason
 *            the reason
 * @return the API Result
 */
+ (PLAPIResult) gameEndWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId reason: (NSString *) reason;

/**
 * Transaction.
 * 
 * @param transactionId
 *            the transaction id
 * @param itemId
 *            the item id
 * @param quantity
 *            the quantity
 * @param type
 *            the type
 * @param otherUserId
 *            the other user id
 * @param currencyType
 *            the currency type
 * @param currencyValue
 *            the currency value
 * @param currencyCategory
 *            the currency category
 * @return the API Result
 */
+ (PLAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PLTransactionType) type
                      otherUserId: (NSString *) otherUserId
                     currencyType: (PLCurrencyType) currencyType
                    currencyValue: (double) currencyValue
                 currencyCategory: (PLCurrencyCategory) currencyCategory;

/**
 * Transaction.
 * 
 * @param transactionId
 *            the transaction id
 * @param itemId
 *            the item id
 * @param quantity
 *            the quantity
 * @param type
 *            the type
 * @param otherUserId
 *            the other user id
 * @param currencyTypes
 *            the currency types NSString objects
 * @param currencyValues
 *            the currency values
 * @param currencyCategories
 *            the currency categories
 * @return the API Result
 */
+ (PLAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PLTransactionType) type
                      otherUserId: (NSString *) otherUserId
                    currencyTypes: (NSArray *) currencyTypes
                   currencyValues: (NSArray *) currencyValues
               currencyCategories: (NSArray *) currencyCategories; 

/**
 * Invitation sent.
 * 
 * @param invitationId
 *            the invitation id
 * @param recipientUserId
 *            the recipient user id
 * @param recipientAddress
 *            the recipient address
 * @param method
 *            the method
 * @return the API Result
 */
+ (PLAPIResult) invitationSentWithId: (NSString *) invitationId 
                     recipientUserId: (NSString *) recipientUserId 
                    recipientAddress: (NSString *) recipientAddress 
                              method: (NSString *) method;

/**
 * Invitation response.
 * 
 * @param invitationId
 *            the invitation id
 * @param response
 *            the response
 * @return the API Result
 */
+ (PLAPIResult) invitationResponseWithId: (NSString *) invitationId 
                            responseType: (PLResponseType) responseType;
@end

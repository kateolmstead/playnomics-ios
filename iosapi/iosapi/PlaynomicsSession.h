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

/**
 * Start.
 * 
 * @param activity
 *            the activity
 * @param applicationId
 *            the application id
 * @param userId
 *            the user id
 * @return the API Result
 */
+ (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId userId: (NSString *) userId;

/**
 * Start.
 * 
 * @param activity
 *            the activity
 * @param applicationId
 *            the application id
 * @return the API Result
 */
+ (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId;

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
 * @throws StartNotCalledException
 *             the start not called exception
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
                      sourceStr: (NSString *) sourceStr 
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
+ (PLAPIResult) sessionStart: (NSString *) sessionId site: (NSString *) site;

/**
 * Session end.
 * 
 * @param sessionId
 *            the session id
 * @param reason
 *            the reason
 * @return the API Result
 */
+ (PLAPIResult) sessionEnd: (NSString *) sessionId reason: (NSString *) reason;

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
+ (PLAPIResult) gameStartWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId reason: (NSString *) reason;

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
+ (PLAPIResult) transaction:(long) transactionId 
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
 * @param currencyType
 *            the currency type
 * @param currencyValue
 *            the currency value
 * @param currencyCategory
 *            the currency category
 * @return the API Result
 */
+ (PLAPIResult) transaction:(long) transactionId 
                     itemId: (NSString *) itemId
                   quantity: (double) quantity
                       type: (PLTransactionType) type
                otherUserId: (NSString *) otherUserId
            currencyTypeStr: (NSString *) currencyType
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
+ (PLAPIResult) transaction:(long) transactionId 
                     itemId: (NSString *) itemId
                   quantity: (double) quantity
                       type: (PLTransactionType) type
                otherUserId: (NSString *) otherUserId
           currencyTypesStr: (NSArray *) currencyTypes
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
+ (PLAPIResult) invitationSent: (NSString *) invitationId 
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
+ (PLAPIResult) invitationSent: (NSString *) invitationId responseType: (PLResponseType) responseType;
@end
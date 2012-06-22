//
//  Util.m
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "PLUtil.h"


@implementation PLUtil

+(PLResponseType) PLResponseTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"accepted"])
            return PLResponseTypeAccepted;
    }
    return -1;
}

+(NSString*) PLResponseTypeDescription:(PLResponseType) value {
    switch (value) {
        case PLResponseTypeAccepted:
            return @"accepted";
    }
    return nil;
}

+(PLTransactionType) PLTransactionTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"BuyItem"])
            return PLTransactionBuyItem;
        else if ([text isEqualToString:@"SellItem"])
            return PLTransactionSellItem;
        else if ([text isEqualToString:@"ReturnItem"])
            return PLTransactionReturnItem;
        else if ([text isEqualToString:@"BuyService"])
            return PLTransactionBuyService;
        else if ([text isEqualToString:@"SellService"])
            return PLTransactionSellService;
        else if ([text isEqualToString:@"ReturnService"])
            return PLTransactionReturnService;
        else if ([text isEqualToString:@"CurrencyConvert"])
            return PLTransactionCurrencyConvert;
        else if ([text isEqualToString:@"Initial"])
            return PLTransactionInitial;
        else if ([text isEqualToString:@"Free"])
            return PLTransactionFree;
        else if ([text isEqualToString:@"Reward"])
            return PLTransactionReward;
        else if ([text isEqualToString:@"GiftSend"])
            return PLTransactionGiftSend;
        else if ([text isEqualToString:@"GiftReceive"])
            return PLTransactionGiftReceive;
    }
    return -1;
}

+(NSString*) PLTransactionTypeDescription:(PLTransactionType) value {
    switch (value) {
        case PLTransactionBuyItem:
            return @"BuyItem";
        case PLTransactionSellItem:
            return @"SellItem";
        case PLTransactionReturnItem:
            return @"ReturnItem";
        case PLTransactionBuyService:
            return @"BuyService";
        case PLTransactionSellService:
            return @"SellService";
        case PLTransactionReturnService:
            return @"ReturnService";
        case PLTransactionCurrencyConvert:
            return @"CurrencyConvert";
        case PLTransactionInitial:
            return @"Initial";
        case PLTransactionFree:
            return @"Free";
        case PLTransactionReward:
            return @"Reward";
        case PLTransactionGiftSend:
            return @"GiftSend";
        case PLTransactionGiftReceive:
            return @"GiftReceive";
    }
    return nil;
}

+ (PLCurrencyCategory) PLCurrencyCategoryValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"Real"])
            return PLCurrencyCategoryReal;
        else if ([text isEqualToString:@"Virtual"])
            return PLCurrencyCategoryVirtual;
    }
    return -1;
}

+ (NSString *) PLCurrencyCategoryDescription:(PLCurrencyCategory) value {
    switch (value) {
        case PLCurrencyCategoryReal:
            return @"Real";
        case PLCurrencyCategoryVirtual:
            return @"Virtual";
    }
    return nil;
}

+(PLCurrencyType) PLCurrencyTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"USD"])
            return PLCurrencyUSD;
        else if ([text isEqualToString:@"FBC"])
            return PLCurrencyFBC;
        else if ([text isEqualToString:@"OFD"])
            return PLCurrencyOFD;
        else if ([text isEqualToString:@"OFF"])
            return PLCurrencyOFF;
    }
    return -1;
}

+ (NSString *) PLCurrencyTypeDescription:(PLCurrencyType) value {
    switch (value) {
        case PLCurrencyUSD:
            return @"USD";
        case PLCurrencyFBC:
            return @"FBC";
        case PLCurrencyOFD:
            return @"OFD";
        case PLCurrencyOFF:
            return @"OFF";
    }
    return nil;
}

+(PLUserInfoType) PLUserInfoTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"update"])
            return PLUserInfoTypeUpdate;
    }
    return -1;
}

+ (NSString *) PLUserInfoTypeDescription:(PLUserInfoType) value {
    switch (value) {
        case PLUserInfoTypeUpdate:
            return @"update";
    }
    return nil;
}

+(PLUserInfoSex) PLUserInfoSexValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"Male"])
            return PLUserInfoSexMale;
        else if ([text isEqualToString:@"Female"])
            return PLUserInfoSexFemale;
        else if ([text isEqualToString:@"Unknown"])
            return PLUserInfoSexUnknown;
    }
    return -1;
}

+ (NSString *) PLUserInfoSexDescription:(PLUserInfoSex) value {
    switch (value) {
        case PLUserInfoSexMale:
            return @"Male";
        case PLUserInfoSexFemale:
            return @"Female";
        case PLUserInfoSexUnknown:
            return @"Unknown";
    }
    return nil;
}

+(PLUserInfoSource) PLUserInfoSourceValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"Adwords"])
            return PLUserInfoSourceAdwords;
        else if ([text isEqualToString:@"DoubleClick"])
            return PLUserInfoSourceDoubleClick;
        else if ([text isEqualToString:@"YahooAds"])
            return PLUserInfoSourceYahooAds;
        else if ([text isEqualToString:@"MSNAds"])
            return PLUserInfoSourceMSNAds;
        else if ([text isEqualToString:@"AOLAds"])
            return PLUserInfoSourceAOLAds;
        else if ([text isEqualToString:@"Adbrite"])
            return PLUserInfoSourceAdbrite;
        else if ([text isEqualToString:@"FacebookAds"])
            return PLUserInfoSourceFacebookAds;
        else if ([text isEqualToString:@"GoogleSearch"])
            return PLUserInfoSourceGoogleSearch;
        else if ([text isEqualToString:@"YahooSearch"])
            return PLUserInfoSourceYahooSearch;
        else if ([text isEqualToString:@"BingSearch"])
            return PLUserInfoSourceBingSearch;
        else if ([text isEqualToString:@"FacebookSearch"])
            return PLUserInfoSourceFacebookSearch;
        else if ([text isEqualToString:@"Applifier"])
            return PLUserInfoSourceApplifier;
        else if ([text isEqualToString:@"AppStrip"])
            return PLUserInfoSourceAppStrip;
        else if ([text isEqualToString:@"VIPGamesNetwork"])
            return PLUserInfoSourceVIPGamesNetwork;
        else if ([text isEqualToString:@"UserReferral"])
            return PLUserInfoSourceUserReferral;
        else if ([text isEqualToString:@"InterGame"])
            return PLUserInfoSourceInterGame;
        else if ([text isEqualToString:@"Other"])
            return PLUserInfoSourceOther;
    }
    return -1;
}

+ (NSString *) PLUserInfoSourceDescription:(PLUserInfoSource) value {
    switch (value) {
        case PLUserInfoSourceAdwords:
            return @"Adwords";
        case PLUserInfoSourceDoubleClick:
            return @"DoubleClick";
        case PLUserInfoSourceYahooAds:
            return @"YahooAds";
        case PLUserInfoSourceMSNAds:
            return @"MSNAds";
        case PLUserInfoSourceAOLAds:
            return @"AOLAds";
        case PLUserInfoSourceAdbrite:
            return @"Adbrite";
        case PLUserInfoSourceFacebookAds:
            return @"FacebookAds";
        case PLUserInfoSourceGoogleSearch:
            return @"GoogleSearch";
        case PLUserInfoSourceYahooSearch:
            return @"YahooSearch";
        case PLUserInfoSourceBingSearch:
            return @"BingSearch";
        case PLUserInfoSourceFacebookSearch:
            return @"FacebookSearch";
        case PLUserInfoSourceApplifier:
            return @"Applifier";
        case PLUserInfoSourceAppStrip:
            return @"AppStrip";
        case PLUserInfoSourceVIPGamesNetwork:
            return @"VIPGamesNetwork";
        case PLUserInfoSourceUserReferral:
            return @"UserReferral";
        case PLUserInfoSourceInterGame:
            return @"InterGame";
        case PLUserInfoSourceOther:
            return @"Other";
    }
    return nil;
}

+(PLEventType) PLEventTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"appStart"])
            return PLEventAppStart;
        else if ([text isEqualToString:@"appPage"])
            return PLEventAppPage;
        else if ([text isEqualToString:@"appRunning"])
            return PLEventAppRunning;
        else if ([text isEqualToString:@"appPause"])
            return PLEventAppPause;
        else if ([text isEqualToString:@"appResume"])
            return PLEventAppResume;
        else if ([text isEqualToString:@"appStop"])
            return PLEventAppStop;
        else if ([text isEqualToString:@"userInfo"])
            return PLEventUserInfo;
        else if ([text isEqualToString:@"sessionStart"])
            return PLEventSessionStart;
        else if ([text isEqualToString:@"sessionEnd"])
            return PLEventSessionEnd;
        else if ([text isEqualToString:@"gameStart"])
            return PLEventGameStart;
        else if ([text isEqualToString:@"gameEnd"])
            return PLEventGameEnd;
        else if ([text isEqualToString:@"transaction"])
            return PLEventTransaction;
        else if ([text isEqualToString:@"invitationSent"])
            return PLEventInvitationSent;
        else if ([text isEqualToString:@"invitationResponse"])
            return PLEventInvitationResponse;
    }
    return -1;
}

+(NSString*) PLEventTypeDescription: (PLEventType) value {
    switch (value) {
        case PLEventAppStart:
            return @"appStart";
        case PLEventAppPage:
            return @"appPage";
        case PLEventAppRunning:
            return @"appRunning";
        case PLEventAppPause:
            return @"appPause";
        case PLEventAppResume:
            return @"appResume";
        case PLEventAppStop:
            return @"appStop";
        case PLEventUserInfo:
            return @"userInfo";
        case PLEventSessionStart:
            return @"sessionStart";
        case PLEventSessionEnd:
            return @"sessionEnd";
        case PLEventGameStart:
            return @"gameStart";
        case PLEventGameEnd:
            return @"gameEnd";
        case PLEventTransaction:
            return @"transaction";
        case PLEventInvitationSent:
            return @"invitationSent";
        case PLEventInvitationResponse:
            return @"invitationResponse";
    }
    return nil;
}



@end

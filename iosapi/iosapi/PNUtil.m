//
//  Util.m
//  iosapi
//
//  Created by Martin Harkins on 6/21/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "PlaynomicsSession+Exposed.h"
#import "PNUtil.h"
#import <AdSupport/AdSupport.h>


@implementation PNUtil

/*  The Pasteboard is kept in memory even if the app is deleted.
 *  This provides a suitable means for having a unique device ID
 */
+ (NSString *) getDeviceUniqueIdentifier {
    // First check the old pasteboard (pre v8.2) to see if the Playnomics breadcrumbId exists
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:PNUserDefaultsLastDeviceID create:NO];
    NSString *storedUUID = [pasteBoard string];
    
    // If it doesn't exist, create a new Playnomics breadcrumbId, but don't save it anywhere
    // The calling method will save it
    if ([storedUUID length] == 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        storedUUID = [(NSString *)CFUUIDCreateString(NULL,uuidRef) autorelease];
        CFRelease(uuidRef);
    }
    
    return storedUUID;
}

// Unique to an app group, which is tied by the organization deploying the apps to the AppStore
+ (NSString *) getVendorIdentifier {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSDictionary *) getAdvertisingInfo {
    NSMutableDictionary *advertisingInfo = [NSMutableDictionary dictionary];
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    
    [advertisingInfo setValue:(manager.isAdvertisingTrackingEnabled ? @"false" : @"true") forKey:PNPasteboardLastLimitAdvertising];
    [advertisingInfo setValue:[manager.advertisingIdentifier UUIDString] forKey:PNPasteboardLastIDFA];
    
    NSLog(@"Latest Advertising Information is:%@", advertisingInfo);
    return advertisingInfo;
}

+ (UIInterfaceOrientation)getCurrentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}


+(PNResponseType) PNResponseTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"accepted"])
            return PNResponseTypeAccepted;
    }
    return -1;
}

+(NSString*) PNResponseTypeDescription:(PNResponseType) value {
    switch (value) {
        case PNResponseTypeAccepted:
            return @"accepted";
    }
    return nil;
}

+(PNTransactionType) PNTransactionTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"BuyItem"])
            return PNTransactionBuyItem;
        else if ([text isEqualToString:@"SellItem"])
            return PNTransactionSellItem;
        else if ([text isEqualToString:@"ReturnItem"])
            return PNTransactionReturnItem;
        else if ([text isEqualToString:@"BuyService"])
            return PNTransactionBuyService;
        else if ([text isEqualToString:@"SellService"])
            return PNTransactionSellService;
        else if ([text isEqualToString:@"ReturnService"])
            return PNTransactionReturnService;
        else if ([text isEqualToString:@"CurrencyConvert"])
            return PNTransactionCurrencyConvert;
        else if ([text isEqualToString:@"Initial"])
            return PNTransactionInitial;
        else if ([text isEqualToString:@"Free"])
            return PNTransactionFree;
        else if ([text isEqualToString:@"Reward"])
            return PNTransactionReward;
        else if ([text isEqualToString:@"GiftSend"])
            return PNTransactionGiftSend;
        else if ([text isEqualToString:@"GiftReceive"])
            return PNTransactionGiftReceive;
    }
    return -1;
}

+(NSString*) PNTransactionTypeDescription:(PNTransactionType) value {
    switch (value) {
        case PNTransactionBuyItem:
            return @"BuyItem";
        case PNTransactionSellItem:
            return @"SellItem";
        case PNTransactionReturnItem:
            return @"ReturnItem";
        case PNTransactionBuyService:
            return @"BuyService";
        case PNTransactionSellService:
            return @"SellService";
        case PNTransactionReturnService:
            return @"ReturnService";
        case PNTransactionCurrencyConvert:
            return @"CurrencyConvert";
        case PNTransactionInitial:
            return @"Initial";
        case PNTransactionFree:
            return @"Free";
        case PNTransactionReward:
            return @"Reward";
        case PNTransactionGiftSend:
            return @"GiftSend";
        case PNTransactionGiftReceive:
            return @"GiftReceive";
    }
    return nil;
}

+ (PNCurrencyCategory) PNCurrencyCategoryValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"r"])
            return PNCurrencyCategoryReal;
        else if ([text isEqualToString:@"v"])
            return PNCurrencyCategoryVirtual;
    }
    return -1;
}

+ (NSString *) PNCurrencyCategoryDescription:(PNCurrencyCategory) value {
    switch (value) {
        case PNCurrencyCategoryReal:
            return @"r";
        case PNCurrencyCategoryVirtual:
            return @"v";
    }
    return nil;
}

+(PNCurrencyType) PNCurrencyTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"USD"])
            return PNCurrencyUSD;
        else if ([text isEqualToString:@"FBC"])
            return PNCurrencyFBC;
        else if ([text isEqualToString:@"OFD"])
            return PNCurrencyOFD;
        else if ([text isEqualToString:@"OFF"])
            return PNCurrencyOFF;
    }
    return -1;
}

+ (NSString *) PNCurrencyTypeDescription:(PNCurrencyType) value {
    switch (value) {
        case PNCurrencyUSD:
            return @"USD";
        case PNCurrencyFBC:
            return @"FBC";
        case PNCurrencyOFD:
            return @"OFD";
        case PNCurrencyOFF:
            return @"OFF";
    }
    return nil;
}

+(PNUserInfoType) PNUserInfoTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"update"])
            return PNUserInfoTypeUpdate;
    }
    return -1;
}

+ (NSString *) PNUserInfoTypeDescription:(PNUserInfoType) value {
    switch (value) {
        case PNUserInfoTypeUpdate:
            return @"update";
    }
    return nil;
}

+(PNUserInfoSex) PNUserInfoSexValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"M"])
            return PNUserInfoSexMale;
        else if ([text isEqualToString:@"F"])
            return PNUserInfoSexFemale;
        else if ([text isEqualToString:@"U"])
            return PNUserInfoSexUnknown;
    }
    return -1;
}

+ (NSString *) PNUserInfoSexDescription:(PNUserInfoSex) value {
    switch (value) {
        case PNUserInfoSexMale:
            return @"M";
        case PNUserInfoSexFemale:
            return @"F";
        case PNUserInfoSexUnknown:
            return @"U";
    }
    return nil;
}

+(PNUserInfoSource) PNUserInfoSourceValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"Adwords"])
            return PNUserInfoSourceAdwords;
        else if ([text isEqualToString:@"DoubleClick"])
            return PNUserInfoSourceDoubleClick;
        else if ([text isEqualToString:@"YahooAds"])
            return PNUserInfoSourceYahooAds;
        else if ([text isEqualToString:@"MSNAds"])
            return PNUserInfoSourceMSNAds;
        else if ([text isEqualToString:@"AOLAds"])
            return PNUserInfoSourceAOLAds;
        else if ([text isEqualToString:@"Adbrite"])
            return PNUserInfoSourceAdbrite;
        else if ([text isEqualToString:@"FacebookAds"])
            return PNUserInfoSourceFacebookAds;
        else if ([text isEqualToString:@"GoogleSearch"])
            return PNUserInfoSourceGoogleSearch;
        else if ([text isEqualToString:@"YahooSearch"])
            return PNUserInfoSourceYahooSearch;
        else if ([text isEqualToString:@"BingSearch"])
            return PNUserInfoSourceBingSearch;
        else if ([text isEqualToString:@"FacebookSearch"])
            return PNUserInfoSourceFacebookSearch;
        else if ([text isEqualToString:@"Applifier"])
            return PNUserInfoSourceApplifier;
        else if ([text isEqualToString:@"AppStrip"])
            return PNUserInfoSourceAppStrip;
        else if ([text isEqualToString:@"VIPGamesNetwork"])
            return PNUserInfoSourceVIPGamesNetwork;
        else if ([text isEqualToString:@"UserReferral"])
            return PNUserInfoSourceUserReferral;
        else if ([text isEqualToString:@"InterGame"])
            return PNUserInfoSourceInterGame;
        else if ([text isEqualToString:@"Other"])
            return PNUserInfoSourceOther;
    }
    return -1;
}

+ (NSString *) PNUserInfoSourceDescription:(PNUserInfoSource) value {
    switch (value) {
        case PNUserInfoSourceAdwords:
            return @"Adwords";
        case PNUserInfoSourceDoubleClick:
            return @"DoubleClick";
        case PNUserInfoSourceYahooAds:
            return @"YahooAds";
        case PNUserInfoSourceMSNAds:
            return @"MSNAds";
        case PNUserInfoSourceAOLAds:
            return @"AOLAds";
        case PNUserInfoSourceAdbrite:
            return @"Adbrite";
        case PNUserInfoSourceFacebookAds:
            return @"FacebookAds";
        case PNUserInfoSourceGoogleSearch:
            return @"GoogleSearch";
        case PNUserInfoSourceYahooSearch:
            return @"YahooSearch";
        case PNUserInfoSourceBingSearch:
            return @"BingSearch";
        case PNUserInfoSourceFacebookSearch:
            return @"FacebookSearch";
        case PNUserInfoSourceApplifier:
            return @"Applifier";
        case PNUserInfoSourceAppStrip:
            return @"AppStrip";
        case PNUserInfoSourceVIPGamesNetwork:
            return @"VIPGamesNetwork";
        case PNUserInfoSourceUserReferral:
            return @"UserReferral";
        case PNUserInfoSourceInterGame:
            return @"InterGame";
        case PNUserInfoSourceOther:
            return @"Other";
    }
    return nil;
}

+(PNEventType) PNEventTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"appStart"])
            return PNEventAppStart;
        else if ([text isEqualToString:@"appPage"])
            return PNEventAppPage;
        else if ([text isEqualToString:@"appRunning"])
            return PNEventAppRunning;
        else if ([text isEqualToString:@"appPause"])
            return PNEventAppPause;
        else if ([text isEqualToString:@"appResume"])
            return PNEventAppResume;
        else if ([text isEqualToString:@"appStop"])
            return PNEventAppStop;
        else if ([text isEqualToString:@"userInfo"])
            return PNEventUserInfo;
        else if ([text isEqualToString:@"sessionStart"])
            return PNEventSessionStart;
        else if ([text isEqualToString:@"sessionEnd"])
            return PNEventSessionEnd;
        else if ([text isEqualToString:@"gameStart"])
            return PNEventGameStart;
        else if ([text isEqualToString:@"gameEnd"])
            return PNEventGameEnd;
        else if ([text isEqualToString:@"transaction"])
            return PNEventTransaction;
        else if ([text isEqualToString:@"invitationSent"])
            return PNEventInvitationSent;
        else if ([text isEqualToString:@"invitationResponse"])
            return PNEventInvitationResponse;
        else if ([text isEqualToString:@"milestone"])
            return PNEventMilestone;
        else if ([text isEqualToString:@"jslog"])
            return PNEventError;
        else if ([text isEqualToString:@"pushNotificationToken"])
            return PNEventPushNotificationToken;
        else if ([text isEqualToString:@"pushNotificationPayload"])
            return PNEventPushNotificationPayload;
    }
    return -1;
}

+ (NSString*) PNEventTypeDescription: (PNEventType) value {
    switch (value) {
        case PNEventAppStart:
            return @"appStart";
        case PNEventAppPage:
            return @"appPage";
        case PNEventAppRunning:
            return @"appRunning";
        case PNEventAppPause:
            return @"appPause";
        case PNEventAppResume:
            return @"appResume";
        case PNEventAppStop:
            return @"appStop";
        case PNEventUserInfo:
            return @"userInfo";
        case PNEventSessionStart:
            return @"sessionStart";
        case PNEventSessionEnd:
            return @"sessionEnd";
        case PNEventGameStart:
            return @"gameStart";
        case PNEventGameEnd:
            return @"gameEnd";
        case PNEventTransaction:
            return @"transaction";
        case PNEventInvitationSent:
            return @"invitationSent";
        case PNEventInvitationResponse:
            return @"invitationResponse";
        case PNEventMilestone:
            return @"milestone";
        case PNEventError:
            return @"jslog";
        case PNEventPushNotificationToken:
            return @"userInfo";
        case PNEventPushNotificationPayload:
            return @"userInfo";
    }
    return nil;
}
 
+ (NSString *) urlEncodeValue: (NSString*) unescapedValued {
    if([unescapedValued length] ==  0){
        return NULL;
    }
    NSString* result = (NSString *)CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (CFStringRef)unescapedValued,
        NULL,
        CFSTR("!*'();:@&=+$,/?%#[]"),
        kCFStringEncodingUTF8);
    return [result autorelease];
}

@end

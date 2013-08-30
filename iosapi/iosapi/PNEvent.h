#import <Foundation/Foundation.h>
#import "PNGameSessionInfo.h"


//all events
#define PNEventParameterTimeStamp @"t"
#define PNEventParameterUserId @"u"
#define PNEventParameterApplicationId @"a"
#define PNEventParameterDeviceID @"b"
#define PNEventParameterSdkName @"esrc"
#define PNEventParameterSdkVersion @"ever"
//implicit event
#define PNEventParameterInstanceId @"i"
#define PNEventParameterImplicitSessionId @"s"
//explicit event
#define PNEventParameterExplicitSessionId @"jsh"
//appStart/appPage
#define PNEventParameterTimezoneOffset @"z"
//appRunning/appPause
#define PNEventParameterSequence @"q"
#define PNEventParameterTouches @"c"
#define PNEventParameterTotalTouches @"e"
#define PNEventParameterKeysPressed @"k"
#define PNEventParameterTotalKeysPressed @"l"
#define PNEventParameterSessionStartTime @"r"
#define PNEventParameterIntervalMilliseconds @"d"
#define PNEventParameterCaptureMode @"m"
//appResume
#define PNEventParameterSessionPauseTime @"p"
//userinfo
#define PNEventParameterUserInfoType @"pt"
#define PNEventParameterUserInfoPushToken @"pushTok"
#define PNEventParameterUserInfoLimitAdvertising @"limitAdvertising"
#define PNEventParameterUserInfoIdfa @"idfa"
#define PNEventParameterUserInfoIdfv @"idfv"

//transactions
#define PNEventParameterTransactionId @"r"
#define PNEventParameterTransactionType @"tt"
#define PNEventParameterTransactionItemId @"i"
#define PNEventParameterTransactionQuantity @"tq"
#define PNEventParameterTransactionCurrencyTypeFormat @"tc%d"
#define PNEventParameterTransactionCurrencyValueFormat @"tv%d"
#define PNEventParameterTransactionCurrencyCategoryFormat @"ta%d"
//milestones
#define PNEventParameterMilestoneId @"mi"
#define PNEventParameterMilestoneName @"mn"
//push notifications
#define PNEventParameterPushToken @"pt"

@interface PNEvent : NSObject

@property (nonatomic, readonly) NSDictionary *eventParameters;
@property (nonatomic, readonly) NSTimeInterval eventTime;

- (id) initWithSessionInfo: (PNGameSessionInfo *) info;
- (id) initWithSessionInfo: (PNGameSessionInfo *) info instanceId: (PNGeneratedHexId *) instanceId;

- (void) appendParameter: (id) value  forKey:(NSString *) key;

- (NSString*) sessionKey;
- (NSString *) baseUrlPath;
@end

/**
 *  PLResponseType for the SocialEvent
 */
typedef enum {
    PLResponseTypeAccepted
} PLResponseType;

/**
 *  PLEventType
 *  Type of event to be sent to the API
 */
typedef enum {
    PLEventAppStart,
    PLEventAppPage,
    PLEventAppRunning,
    PLEventAppPause,
    PLEventAppResume,
    PLEventAppStop,
    PLEventUserInfo,
    PLEventSessionStart,
    PLEventSessionEnd,
    PLEventGameStart,
    PLEventGameEnd,
    PLEventTransaction,
    PLEventInvitationSent,
    PLEventInvitationResponse
} PLEventType;

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

typedef enum {
  PLCurrencyCategoryReal,
  PLCurrencyCategoryVirtual
} PLCurrencyCategory;

typedef enum {
  PLCurrencyUSD,
  PLCurrencyFBC,
  PLCurrencyOFD,
  PLCurrencyOFF
} PLCurrencyType;

typedef enum {
  PLUserInfoTypeUpdate
} PLUserInfoType;

typedef enum {
  PLUserInfoSexMale,
  PLUserInfoSexFemale,
  PLUserInfoSexUnknown
} PLUserInfoSex;

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

typedef enum {
    PLSessionStateUnkown,
    PLSessionStateStarted,
    PLSessionStatePaused,
    PLSessionStateStopped
} PLSessionState;

/*************** MACROS *****************/
/** Converts the NSTimeInterval (seconds) to Milliseconds for the server API */
#define TO_LONG_MILLISECONDS(timeInterval) (unsigned long long) ((NSTimeInterval)timeInterval * 1000)

// Singleton Macro
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;


// User Default Keys
#define PLUserDefaultsLastSessionStartTime @"com.playnomics.lastSessionStartTime"
#define PLUserDefaultsLastSessionID @"com.playnomics.lastSessionId"
#define PLUserDefaultsLastUserID @"com.playnomics.lastUserId"

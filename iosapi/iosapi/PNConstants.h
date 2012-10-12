/************** PRIVATE *****************/
/**
 *  PNEventType
 *  Type of event to be sent to the Server API
 */
typedef enum {
    PNEventAppStart,
    PNEventAppPage,
    PNEventAppRunning,
    PNEventAppPause,
    PNEventAppResume,
    PNEventAppStop,
    PNEventUserInfo,
    PNEventSessionStart,
    PNEventSessionEnd,
    PNEventGameStart,
    PNEventGameEnd,
    PNEventTransaction,
    PNEventInvitationSent,
    PNEventInvitationResponse
} PNEventType;

/**
 *  PNSessionState
 *  Possible states for the Playnomics Session
 */
typedef enum {
    PNSessionStateUnkown,
    PNSessionStateStarted,
    PNSessionStatePaused,
    PNSessionStateStopped
} PNSessionState;

/*************** MACROS *****************/
/*!
* @function Singleton GCD Macro
*/



// Singleton Macro
#ifndef DEFINE_SHARED_INSTANCE_USING_BLOCK
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
    static dispatch_once_t pred = 0;              \
    __strong static id _sharedObject = nil;       \
                                                  \
    dispatch_once(&pred, ^{                       \
        _sharedObject = block();                  \
    });                                           \
    return _sharedObject;
#endif


// User Default Keys
#define PNUserDefaultsLastSessionStartTime @"com.playnomics.lastSessionStartTime"
#define PNUserDefaultsLastSessionID @"com.playnomics.lastSessionId"
#define PNUserDefaultsLastUserID @"com.playnomics.lastUserId"

// Ad Response: Common
#define FrameResponseHeight @"h"
#define FrameResponseWidth @"w"
#define FrameResponseXOffset @"x"
#define FrameResponseYOffset @"y"
#define FrameResponseImageUrl @"i"

// Ad Response: Top level keys
#define FrameResponseAds @"a"
#define FrameResponseAdLocationInfo @"l"
#define FrameResponseBackgroundInfo @"b"
#define FrameResponseCloseButtonInfo @"c"
#define FrameResponseExpiration @"e"
#define FrameResponseStatus @"s"
#define FrameResponseStatusMessage @"m"

// Ad Response: Ad information keys
#define FrameResponseAd_PrimaryImage @"i"
#define FrameResponseAd_RolloverImage @"r"
#define FrameResponseAd_ToolTipText @"x
#define FrameResponseAd_ClickTarget @"t"
#define FrameResponseAd_PreExecuteUrl @"u"
#define FrameResponseAd_PostExecuteUrl @"v"
#define FrameResponseAd_ImpressionUrl @"s"
#define FrameResponseAd_FlagUrl @"f"
#define FrameResponseAd_CloseUrl @"d"

// Ad Response: Background keys
#define FrameResponseBackground_Landscape @"l"
#define FrameResponseBackground_Portrait @"p"

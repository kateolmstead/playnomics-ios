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
    PNEventInvitationResponse,
    PNEventMilestone,
    PNEventError,
    PNEventPushNotificationToken,
    PNEventPushNotificationPayload,
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
#define PNUserDefaultsLastDeviceToken @"com.playnomics.lastDeviceToken"
#define PNUserDefaultsLastIDFV @"com.playnomics.lastIDFV"
// Deprecate this eventually once everyone has migrated to version 8.2 or later of the SDK
// since we are moving this field to the Pasteboard
#define PNUserDefaultsLastDeviceID @"com.playnomics.uniqueDeviceId"

// Information that we store on the Pasteboard so they remain persistent across sessions
#define PNPasteboardName @"com.playnomics.pasteboardData"
#define PNPasteboardLastBreadcrumbID @"lastBreadcrumbId"
#define PNPasteboardLastLimitAdvertising @"lastLimitAdvertising"
#define PNPasteboardLastIDFA @"lastIDFA"

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
#define FrameResponseAd_ToolTipText @"x"
#define FrameResponseAd_ClickTarget @"t"
#define FrameResponseAd_PreExecuteUrl @"u"
#define FrameResponseAd_PostExecuteUrl @"v"
#define FrameResponseAd_ImpressionUrl @"s"
#define FrameResponseAd_FlagUrl @"f"
#define FrameResponseAd_CloseUrl @"d"
#define FrameResponseAd_AdType @"type"
#define FrameResponseAd_VideoViewUrl @"view"

// Ad Response: Background keys
#define FrameResponseBackground_Landscape @"l"
#define FrameResponseBackground_Portrait @"p"

// Push Payload
#define PushResponse_InteractionUrl @"ti"
#define PushInteractionUrl_AppIdParam @"a"
#define PushInteractionUrl_UserIdParam @"u"
#define PushInteractionUrl_BreadcrumbIdParam @"b"
#define PushInteractionUrl_PushTokenParam @"pt"
#define PushInteractionUrl_IgnoredParam @"pushIgnored"

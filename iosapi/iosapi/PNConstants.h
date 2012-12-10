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
    PNEventMilestone
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
// Singleton Macro
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;


// User Default Keys
#define PNUserDefaultsLastSessionStartTime @"com.playnomics.lastSessionStartTime"
#define PNUserDefaultsLastSessionID @"com.playnomics.lastSessionId"
#define PNUserDefaultsLastUserID @"com.playnomics.lastUserId"

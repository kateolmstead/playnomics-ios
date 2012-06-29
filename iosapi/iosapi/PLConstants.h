/************** PRIVATE *****************/
/**
 *  PLEventType
 *  Type of event to be sent to the Server API
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

/**
 *  PLSessionState
 *  Possible states for the Playnomics Session
 */
typedef enum {
    PLSessionStateUnkown,
    PLSessionStateStarted,
    PLSessionStatePaused,
    PLSessionStateStopped
} PLSessionState;

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
#define PLUserDefaultsLastSessionStartTime @"com.playnomics.lastSessionStartTime"
#define PLUserDefaultsLastSessionID @"com.playnomics.lastSessionId"
#define PLUserDefaultsLastUserID @"com.playnomics.lastUserId"

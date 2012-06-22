#import "BasicEvent.h"

long const serialVersionUID = 1L;
int const UPDATE_INTERVAL = 60000;

@implementation BasicEvent
@synthesize cookieId=_cookieId;
@synthesize sessionId=_sessionId;
@synthesize instanceId=_instanceId;
@synthesize sessionStartTime=_sessionStartTime;
@synthesize pauseTime=_pauseTime;
@synthesize sequence=_sequence;
@synthesize timeZoneOffset=_timeZoneOffset;
@synthesize clicks=_clicks;
@synthesize totalClicks=_totalClicks;
@synthesize keys=_keys;
@synthesize totalKeys=_totalKeys;
@synthesize collectMode=_collectMode;

- (id) init:  (PLEventType) eventType
        applicationId:(long) applicationId
             userId:(NSString *)userId
           cookieId:(NSString *)cookieId
          sessionId:(NSString *)sessionId
         instanceId:(NSString *)instanceId
        sessionStartTime:(NSTimeInterval)sessionStartTime 
           sequence:(int)sequence
             clicks:(int)clicks
        totalClicks:(int)totalClicks
               keys:(int)keys
          totalKeys:(int)totalKeys
        collectMode:(int)collectMode {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId])) {
        _cookieId = [cookieId retain];
        _sessionId = [sessionId retain];
        _instanceId = [instanceId retain];
        _sessionStartTime = sessionStartTime;
        _sequence = sequence;
        _clicks = clicks;
        _totalClicks = totalClicks;
        _keys = keys;
        _totalKeys = totalKeys;
        _collectMode = collectMode;
    }
    return self;
}

- (id) init:  (PLEventType) eventType 
        applicationId:(long) applicationId
             userId:(NSString *)userId
           cookieId:(NSString *)cookieId
          sessionId:(NSString *)sessionId
         instanceId:(NSString *)instanceId
        timeZoneOffset:(int)timeZoneOffset {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId])) {
        _cookieId = cookieId;
        _sessionId = sessionId;
        _instanceId = instanceId;
        _timeZoneOffset = timeZoneOffset;
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&b=%@&s=%@&i=%@", [self cookieId], [self sessionId], [self instanceId]];
    
    switch ([self eventType]) {
        case PLEventAppStart:
        case PLEventAppPage:
            queryString = [queryString stringByAppendingFormat:@"&z=%d", [self timeZoneOffset]];
            break;
        case PLEventAppRunning:
            queryString = [queryString stringByAppendingFormat: @"&r=%d&q=%d&d=%d&c=%d&e=%d&k=%d&l=%d&m=%d", 
                           [self sessionStartTime], 
                           [self sequence],
                           UPDATE_INTERVAL,
                           [self clicks],
                           [self totalClicks],
                           [self keys],
                           [self totalKeys],
                           [self collectMode]];
            break;
        case PLEventAppResume:
            queryString = [queryString stringByAppendingFormat:@"&p=%d", [self pauseTime]];
        case PLEventAppPause:
            queryString = [queryString stringByAppendingFormat:@"&r=%d&q=%d", [self sessionStartTime], [self sequence]];
            break;
        default:
            NSLog(@"BasicEvent: %@ not handled", [PLUtil PLEventTypeDescription:[self eventType]]);
    }
    return queryString;
}

- (void) dealloc {
    [_cookieId release];
    [_sessionId release];
    [_instanceId release];
    
    [super dealloc];
}

@end

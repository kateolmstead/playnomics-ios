#import "BasicEvent.h"
#import "PLConfig.h"

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
    
    [self setup];
    
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
    
    [self setup];
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId])) {
        _cookieId = [cookieId retain];
        _sessionId = [sessionId retain];
        _instanceId = [instanceId retain];
        _timeZoneOffset = timeZoneOffset;
    }
    return self;
}

- (void) setup {
    _clicks = 0;
    _totalClicks = 0;
    _keys = 0;
    _totalKeys = 0;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&b=%@&s=%@&i=%@", [self cookieId], [self sessionId], [self instanceId]];
    
    switch ([self eventType]) {
        case PLEventAppStart:
        case PLEventAppPage:
            queryString = [queryString stringByAppendingFormat:@"&z=%d", [self timeZoneOffset]];
            break;
        case PLEventAppRunning:
            queryString = [queryString stringByAppendingFormat: @"&r=%llu&q=%d&d=%d&c=%d&e=%d&k=%d&l=%d&m=%d", 
                           TO_LONG_MILLISECONDS([self sessionStartTime]), 
                           [self sequence],
                           (int) (PLUpdateTimeInterval * 1000),
                           [self clicks],
                           [self totalClicks],
                           [self keys],
                           [self totalKeys],
                           [self collectMode]];
            break;
        case PLEventAppResume:
            queryString = [queryString stringByAppendingFormat:@"&p=%llu", TO_LONG_MILLISECONDS([self pauseTime])];
        case PLEventAppPause:
            queryString = [queryString stringByAppendingFormat:@"&r=%llu&q=%d", TO_LONG_MILLISECONDS([self sessionStartTime]), [self sequence]];
            break;
        default:
            NSLog(@"BasicEvent: %@ not handled", [PLUtil PLEventTypeDescription:[self eventType]]);
    }
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject: _cookieId forKey:@"PLBasicEvent._cookieId"]; 
    [encoder encodeObject: _sessionId forKey:@"PLBasicEvent._sessionId"]; 
    [encoder encodeObject: _instanceId forKey:@"PLBasicEvent._instanceId"];  
    [encoder encodeDouble: _sessionStartTime forKey:@"PLBasicEvent._sessionStartTime"];  
    [encoder encodeDouble: _pauseTime forKey:@"PLBasicEvent._pauseTime"];  
    [encoder encodeInt: _sequence forKey:@"PLBasicEvent._sequence"];  
    [encoder encodeInt: _clicks forKey:@"PLBasicEvent._clicks"];  
    [encoder encodeInt: _totalClicks forKey:@"PLBasicEvent._totalClicks"];  
    [encoder encodeInt: _keys forKey:@"PLBasicEvent._keys"];  
    [encoder encodeInt: _totalKeys forKey:@"PLBasicEvent._totalKeys"];  
    [encoder encodeInt: _collectMode forKey:@"PLBasicEvent._collectMode"];  
}


- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _cookieId = [(NSString *)[decoder decodeObjectForKey:@"PLBasicEvent._cookieId"] retain]; 
        _sessionId = [(NSString *)[decoder decodeObjectForKey:@"PLBasicEvent._sessionId"] retain]; 
        _instanceId = [(NSString *)[decoder decodeObjectForKey:@"PLBasicEvent._instanceId"] retain]; 
        _sessionStartTime = [decoder decodeDoubleForKey:@"PLBasicEvent._sessionStartTime"]; 
        _sequence = [decoder decodeDoubleForKey:@"PLBasicEvent._sequence"]; 
        _pauseTime = [decoder decodeIntForKey:@"PLBasicEvent._pauseTime"];
        _clicks = [decoder decodeIntForKey:@"PLBasicEvent._clicks"]; 
        _totalClicks = [decoder decodeIntForKey:@"PLBasicEvent._totalClicks"]; 
        _keys = [decoder decodeIntForKey:@"PLBasicEvent._keys"]; 
        _totalKeys = [decoder decodeIntForKey:@"PLBasicEvent._totalKeys"]; 
        _collectMode = [decoder decodeIntForKey:@"PLBasicEvent._collectMode"]; 
    }
    return self;
}


- (void) dealloc {
    [_cookieId release];
    [_sessionId release];
    [_instanceId release];
    
    [super dealloc];
}

@end

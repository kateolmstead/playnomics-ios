#import "PNBasicEvent.h"
#import "PNConfig.h"

@implementation PNBasicEvent
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

- (id) init:  (PNEventType) eventType
        applicationId:(signed long long) applicationId
             userId:(NSString *)userId
           cookieId:(NSString *)cookieId
  internalSessionId:(NSString *)internalSessionId
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
        _instanceId = [instanceId retain];
        _sessionStartTime = sessionStartTime;
        self.internalSessionId = [internalSessionId retain];
        _sequence = sequence;
        _clicks = clicks;
        _totalClicks = totalClicks;
        _keys = keys;
        _totalKeys = totalKeys;
        _collectMode = collectMode;
    }
    return self;
}

- (id) init:  (PNEventType) eventType 
        applicationId:(signed long long) applicationId
             userId:(NSString *)userId
           cookieId:(NSString *)cookieId
  internalSessionId:(NSString *)internalSessionId
         instanceId:(NSString *)instanceId
        timeZoneOffset:(int)timeZoneOffset {
    
    [self setup];
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId])) {
        _cookieId = [cookieId retain];
        self.internalSessionId = [internalSessionId retain];
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
    
    NSLog(@"PNBasicEvent: toQueryString");
    
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&s=%@&i=%@", self.internalSessionId, self.instanceId];
    signed long long updateTimeInterval = PNUpdateTimeInterval * 1000;
    signed long long rTime = [self sessionStartTime] * 1000;
    signed long long pTime = [self pauseTime] * 1000;
    
    switch ([self eventType]) {
        case PNEventAppStart:
        case PNEventAppPage:
            queryString = [queryString stringByAppendingFormat:@"&z=%d", [self timeZoneOffset]];
            break;
        // Note fallthrough
        case PNEventAppResume:
            queryString = [queryString stringByAppendingFormat:@"&p=%lld", pTime];
        case PNEventAppPause:
            queryString = [queryString stringByAppendingFormat:@"&q=%d", [self sequence]];
        case PNEventAppRunning:
            queryString = [queryString stringByAppendingFormat: @"&r=%lld&q=%d&d=%lld&c=%d&e=%d&k=%d&l=%d&m=%d", 
                           rTime, 
                           [self sequence],
                           updateTimeInterval,
                           [self clicks],
                           [self totalClicks],
                           [self keys],
                           [self totalKeys],
                           [self collectMode]];
            break;
        default:
            NSLog(@"BasicEvent: %@ not handled", [PNUtil PNEventTypeDescription:[self eventType]]);
    }
    
    
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject: _cookieId forKey:@"PNBasicEvent._cookieId"]; 
    [encoder encodeObject: _sessionId forKey:@"PNBasicEvent._sessionId"]; 
    [encoder encodeObject: _instanceId forKey:@"PNBasicEvent._instanceId"];  
    [encoder encodeDouble: _sessionStartTime forKey:@"PNBasicEvent._sessionStartTime"];  
    [encoder encodeDouble: _pauseTime forKey:@"PNBasicEvent._pauseTime"];  
    [encoder encodeInt: _sequence forKey:@"PNBasicEvent._sequence"];  
    [encoder encodeInt: _clicks forKey:@"PNBasicEvent._clicks"];  
    [encoder encodeInt: _totalClicks forKey:@"PNBasicEvent._totalClicks"];  
    [encoder encodeInt: _keys forKey:@"PNBasicEvent._keys"];  
    [encoder encodeInt: _totalKeys forKey:@"PNBasicEvent._totalKeys"];  
    [encoder encodeInt: _collectMode forKey:@"PNBasicEvent._collectMode"];  
}


- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _cookieId = [(NSString *)[decoder decodeObjectForKey:@"PNBasicEvent._cookieId"] retain]; 
        _sessionId = [(NSString *)[decoder decodeObjectForKey:@"PNBasicEvent._sessionId"] retain]; 
        _instanceId = [(NSString *)[decoder decodeObjectForKey:@"PNBasicEvent._instanceId"] retain]; 
        _sessionStartTime = [decoder decodeDoubleForKey:@"PNBasicEvent._sessionStartTime"]; 
        _pauseTime = [decoder decodeDoubleForKey:@"PNBasicEvent._pauseTime"];
        _sequence = [decoder decodeIntForKey:@"PNBasicEvent._sequence"]; 
        _clicks = [decoder decodeIntForKey:@"PNBasicEvent._clicks"]; 
        _totalClicks = [decoder decodeIntForKey:@"PNBasicEvent._totalClicks"]; 
        _keys = [decoder decodeIntForKey:@"PNBasicEvent._keys"]; 
        _totalKeys = [decoder decodeIntForKey:@"PNBasicEvent._totalKeys"]; 
        _collectMode = [decoder decodeIntForKey:@"PNBasicEvent._collectMode"]; 
    }
    return self;
}


- (void) dealloc {
    [_cookieId release];
    [_instanceId release];
    
    [super dealloc];
}

@end

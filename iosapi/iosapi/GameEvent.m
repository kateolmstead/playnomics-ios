#import "GameEvent.h"

@implementation GameEvent

@synthesize sessionId=_sessionId;
@synthesize instanceId=_instanceId;
@synthesize type=_type;
@synthesize gameId=_gameId;
@synthesize reason=_reason;
@synthesize site=_site;

- (id) init:  (PLEventType)eventType 
        applicationId: (long) applicationId 
             userId:(NSString *)userId
          sessionId:(NSString *)sessionId
               site:(NSString *)site
         instanceId:(NSString *)instanceId
               type:(NSString *)type
             gameId:(NSString *)gameId
             reason:(NSString *)reason {
    
    if (self = [super init:eventType applicationId:applicationId userId:userId]) {
        _sessionId = [sessionId retain];
        _site = [site retain];
        _instanceId = [instanceId retain];
        _type = [type retain];
        _gameId = [gameId retain];
        _reason = [reason retain];
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [super toQueryString];
    if ([self eventType] == PLEventGameStart || [self eventType] == PLEventGameEnd)
        queryString = [self addOptionalParam:queryString name:@"s" value:[self sessionId]];
    else
        queryString = [queryString stringByAppendingFormat:@"&s=%@", [self sessionId]];
    queryString = [self addOptionalParam:queryString name:@"ss" value:[self site]];
    queryString = [self addOptionalParam:queryString name:@"r" value:[self reason]];
    queryString = [self addOptionalParam:queryString name:@"g" value:[self instanceId]];
//    queryString = [self addOptionalParam:queryString name:@"ss" value:[self site]]; TODO: Fix duplicate on Android
    queryString = [self addOptionalParam:queryString name:@"gt" value:[self type]];
    queryString = [self addOptionalParam:queryString name:@"gi" value:[self gameId]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
        [encoder encodeObject: _sessionId forKey:@"PLGameEvent._sessionId"];  
        [encoder encodeObject: _site forKey:@"PLGameEvent._site"];  
        [encoder encodeObject: _instanceId forKey:@"PLGameEvent._instanceId"];  
        [encoder encodeObject: _type forKey:@"PLGameEvent._type"];  
        [encoder encodeObject: _gameId forKey:@"PLGameEvent._gameId"];  
        [encoder encodeObject: _reason forKey:@"PLGameEvent._reason"];  
}


- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _sessionId = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._sessionId"] retain]; 
        _site = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._site"] retain]; 
        _instanceId = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._instanceId"] retain]; 
        _type = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._type"] retain]; 
        _gameId = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._gameId"] retain]; 
        _reason = [(NSString *)[decoder decodeObjectForKey:@"PLGameEvent._reason"] retain]; 
    }
    return self;
}

- (void) dealloc {
  [_sessionId release];
  [_site release];
  [_instanceId release];
  [_type release];
  [_gameId release];
  [_reason release];
    
  [super dealloc];
}

@end

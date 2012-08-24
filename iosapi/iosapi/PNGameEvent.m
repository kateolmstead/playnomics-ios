#import "PNGameEvent.h"

@implementation PNGameEvent

@synthesize sessionId=_sessionId;
@synthesize instanceId=_instanceId;
@synthesize type=_type;
@synthesize gameId=_gameId;
@synthesize reason=_reason;
@synthesize site=_site;

- (id) init:  (PNEventType)eventType 
      applicationId:(signed long long) applicationId
             userId:(NSString *)userId
          sessionId:(signed long long)sessionId
         instanceId:(signed long long)instanceId
               site:(NSString *)site
               type:(NSString *)type
             gameId:(NSString *)gameId
             reason:(NSString *)reason {
    
    if (self = [super init:eventType applicationId:applicationId userId:userId]) {
        _sessionId = sessionId;
        _instanceId = instanceId;
        _site = [site retain];
        _type = [type retain];
        _gameId = [gameId retain];
        _reason = [reason retain];
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&jsh=%@", [self internalSessionId]];;
    if ([self eventType] == PNEventGameStart || [self eventType] == PNEventGameEnd) {
        queryString = [self addOptionalParam:queryString name:@"s" value:[NSString stringWithFormat:@"%lld", [self sessionId]]];
        queryString = [self addOptionalParam:queryString name:@"g" value:[NSString stringWithFormat:@"%lld", [self instanceId]]];
    } else
        queryString = [queryString stringByAppendingFormat:@"&s=%lld", [self sessionId]];
    
    queryString = [self addOptionalParam:queryString name:@"ss" value:[self site]];
    queryString = [self addOptionalParam:queryString name:@"r" value:[self reason]];
    queryString = [self addOptionalParam:queryString name:@"gt" value:[self type]];
    queryString = [self addOptionalParam:queryString name:@"gi" value:[self gameId]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
        [encoder encodeInt64: _sessionId forKey:@"PNGameEvent._sessionId"];
        [encoder encodeObject: _site forKey:@"PNGameEvent._site"];  
        [encoder encodeInt64: _instanceId forKey:@"PNGameEvent._instanceId"];
        [encoder encodeObject: _type forKey:@"PNGameEvent._type"];  
        [encoder encodeObject: _gameId forKey:@"PNGameEvent._gameId"];  
        [encoder encodeObject: _reason forKey:@"PNGameEvent._reason"];  
}


- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _sessionId = [decoder decodeInt64ForKey:@"PNGameEvent._sessionId"];
        _site = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._site"] retain]; 
        _instanceId = [decoder decodeInt64ForKey:@"PNGameEvent._instanceId"];
        _type = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._type"] retain]; 
        _gameId = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._gameId"] retain]; 
        _reason = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._reason"] retain]; 
    }
    return self;
}

- (void) dealloc {
  [_site release];
  [_type release];
  [_gameId release];
  [_reason release];
    
  [super dealloc];
}

@end

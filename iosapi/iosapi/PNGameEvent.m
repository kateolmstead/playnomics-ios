#import "PNGameEvent.h"

@implementation PNGameEvent

@synthesize gameSessionId=_gameSessionId;
@synthesize instanceId=_instanceId;
@synthesize type=_type;
@synthesize gameId=_gameId;
@synthesize reason=_reason;
@synthesize site=_site;

- (id) init:  (PNEventType)eventType 
        applicationId: (long) applicationId 
             userId:(NSString *)userId
          gameSessionId:(NSString *)gameSessionId
               site:(NSString *)site
         instanceId:(NSString *)instanceId
               type:(NSString *)type
             gameId:(NSString *)gameId
             reason:(NSString *)reason {
    
    if (self = [super init:eventType applicationId:applicationId userId:userId]) {
        _gameSessionId = [gameSessionId retain];
        _site = [site retain];
        _instanceId = [instanceId retain];
        _type = [type retain];
        _gameId = [gameId retain];
        _reason = [reason retain];
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&jsh=%@", [self sessionId]];;
    if ([self eventType] == PNEventGameStart || [self eventType] == PNEventGameEnd)
        queryString = [self addOptionalParam:queryString name:@"s" value:[self gameSessionId]];
    else
        queryString = [queryString stringByAppendingFormat:@"&s=%@", [self gameSessionId]];
    
    queryString = [self addOptionalParam:queryString name:@"ss" value:[self site]];
    queryString = [self addOptionalParam:queryString name:@"r" value:[self reason]];
    queryString = [self addOptionalParam:queryString name:@"g" value:[self instanceId]];
    queryString = [self addOptionalParam:queryString name:@"gt" value:[self type]];
    queryString = [self addOptionalParam:queryString name:@"gi" value:[self gameId]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
        [encoder encodeObject: _gameSessionId forKey:@"PNGameEvent._gameSessionId"];  
        [encoder encodeObject: _site forKey:@"PNGameEvent._site"];  
        [encoder encodeObject: _instanceId forKey:@"PNGameEvent._instanceId"];  
        [encoder encodeObject: _type forKey:@"PNGameEvent._type"];  
        [encoder encodeObject: _gameId forKey:@"PNGameEvent._gameId"];  
        [encoder encodeObject: _reason forKey:@"PNGameEvent._reason"];  
}


- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _gameSessionId = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._gameSessionId"] retain]; 
        _site = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._site"] retain]; 
        _instanceId = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._instanceId"] retain]; 
        _type = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._type"] retain]; 
        _gameId = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._gameId"] retain]; 
        _reason = [(NSString *)[decoder decodeObjectForKey:@"PNGameEvent._reason"] retain]; 
    }
    return self;
}

- (void) dealloc {
  [_gameSessionId release];
  [_site release];
  [_instanceId release];
  [_type release];
  [_gameId release];
  [_reason release];
    
  [super dealloc];
}

@end

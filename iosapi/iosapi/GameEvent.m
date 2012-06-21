#import "GameEvent.h"

long const serialVersionUID = 1L;

@implementation GameEvent

@synthesize sessionId;
@synthesize instanceId;
@synthesize type;
@synthesize gameId;
@synthesize reason;
@synthesize site;

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId sessionId:(NSString *)sessionId site:(NSString *)site instanceId:(NSString *)instanceId type:(NSString *)type gameId:(NSString *)gameId reason:(NSString *)reason {
  if (self = [super init:eventType param1:applicationId param2:userId]) {
    sessionId = sessionId;
    site = site;
    instanceId = instanceId;
    type = type;
    gameId = gameId;
    reason = reason;
  }
  return self;
}

- (NSString *) toQueryString {
  NSString * queryString = [[[[self eventType] stringByAppendingString:@"?t="] + [[self eventTime] time] stringByAppendingString:@"&a="] + [self applicationId] stringByAppendingString:@"&u="] + [self userId];
  if ([self eventType] == EventType.gameStart || [self eventType] == EventType.gameEnd)
    queryString = [self addOptionalParam:queryString param1:@"s" param2:[self sessionId]];
  else
    queryString = [queryString stringByAppendingString:[@"&s=" stringByAppendingString:[self sessionId]]];
  queryString = [self addOptionalParam:queryString param1:@"ss" param2:[self site]];
  queryString = [self addOptionalParam:queryString param1:@"r" param2:[self reason]];
  queryString = [self addOptionalParam:queryString param1:@"g" param2:[self instanceId]];
  queryString = [self addOptionalParam:queryString param1:@"ss" param2:[self site]];
  queryString = [self addOptionalParam:queryString param1:@"gt" param2:[self type]];
  queryString = [self addOptionalParam:queryString param1:@"gi" param2:[self gameId]];
  return queryString;
}

- (void) dealloc {
  [sessionId release];
  [site release];
  [instanceId release];
  [type release];
  [gameId release];
  [reason release];
  [super dealloc];
}

@end

#import "BasicEvent.h"

long const serialVersionUID = 1L;
int const UPDATE_INTERVAL = 60000;

@implementation BasicEvent

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId sessionId:(NSString *)sessionId instanceId:(NSString *)instanceId sessionStartTime:(Date *)sessionStartTime sequence:(int)sequence clicks:(int)clicks totalClicks:(int)totalClicks keys:(int)keys totalKeys:(int)totalKeys collectMode:(int)collectMode {
  if (self = [super init:eventType param1:applicationId param2:userId]) {
    cookieId = cookieId;
    sessionId = sessionId;
    instanceId = instanceId;
    sessionStartTime = sessionStartTime;
    sequence = sequence;
    clicks = clicks;
    totalClicks = totalClicks;
    keys = keys;
    totalKeys = totalKeys;
    collectMode = collectMode;
  }
  return self;
}

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId sessionId:(NSString *)sessionId instanceId:(NSString *)instanceId timeZoneOffset:(int)timeZoneOffset {
  if (self = [super init:eventType param1:applicationId param2:userId]) {
    cookieId = cookieId;
    sessionId = sessionId;
    instanceId = instanceId;
    timeZoneOffset = timeZoneOffset;
  }
  return self;
}

- (NSString *) getCookieId {
  return cookieId;
}

- (void) setCookieId:(NSString *)cookieId {
  cookieId = cookieId;
}

- (NSString *) getSessionId {
  return sessionId;
}

- (void) setSessionId:(NSString *)sessionId {
  sessionId = sessionId;
}

- (NSString *) getInstanceId {
  return instanceId;
}

- (void) setInstanceId:(NSString *)instanceId {
  instanceId = instanceId;
}

- (Date *) getSessionStartTime {
  return sessionStartTime;
}

- (void) setSessionStartTime:(Date *)sessionStartTime {
  sessionStartTime = sessionStartTime;
}

- (Date *) getPauseTime {
  return pauseTime;
}

- (void) setPauseTime:(Date *)pauseTime {
  pauseTime = pauseTime;
}

- (int) getSequence {
  return sequence;
}

- (void) setSequence:(int)sequence {
  sequence = sequence;
}

- (int) getTimeZoneOffset {
  return timeZoneOffset;
}

- (void) setTimeZoneOffset:(int)timeZoneOffset {
  timeZoneOffset = timeZoneOffset;
}

- (int) getClicks {
  return clicks;
}

- (void) setClicks:(int)clicks {
  clicks = clicks;
}

- (int) getTotalClicks {
  return totalClicks;
}

- (void) setTotalClicks:(int)totalClicks {
  totalClicks = totalClicks;
}

- (int) getKeys {
  return keys;
}

- (void) setKeys:(int)keys {
  keys = keys;
}

- (int) getTotalKeys {
  return totalKeys;
}

- (void) setTotalKeys:(int)totalKeys {
  totalKeys = totalKeys;
}

- (int) getCollectMode {
  return collectMode;
}

- (void) setCollectMode:(int)collectMode {
  collectMode = collectMode;
}

- (NSString *) toQueryString {
  NSString * queryString = [[[[[[[self eventType] stringByAppendingString:@"?t="] + [[self eventTime] time] stringByAppendingString:@"&a="] + [self applicationId] stringByAppendingString:@"&u="] + [self userId] stringByAppendingString:@"&b="] + [self cookieId] stringByAppendingString:@"&s="] + [self sessionId] stringByAppendingString:@"&i="] + [self instanceId];

  switch ([self eventType]) {
  case appStart:
  case appPage:
    queryString = [queryString stringByAppendingString:[@"&z=" stringByAppendingString:[self timeZoneOffset]]];
    break;
  case appRunning:
    queryString = [queryString stringByAppendingString:[[[[[[[[@"&r=" stringByAppendingString:[[self sessionStartTime] time]] stringByAppendingString:@"&q="] + [self sequence] stringByAppendingString:@"&d="] + UPDATE_INTERVAL stringByAppendingString:@"&c="] + [self clicks] stringByAppendingString:@"&e="] + [self totalClicks] stringByAppendingString:@"&k="] + [self keys] stringByAppendingString:@"&l="] + [self totalKeys] stringByAppendingString:@"&m="] + [self collectMode]];
    break;
  case appResume:
    queryString = [queryString stringByAppendingString:[@"&p=" stringByAppendingString:[[self pauseTime] time]]];
  case appPause:
    queryString = [queryString stringByAppendingString:[[@"&r=" stringByAppendingString:[[self sessionStartTime] time]] stringByAppendingString:@"&q="] + [self sequence]];
    break;
  }
  return queryString;
}

- (void) dealloc {
  [cookieId release];
  [sessionId release];
  [instanceId release];
  [sessionStartTime release];
  [pauseTime release];
  [super dealloc];
}

@end

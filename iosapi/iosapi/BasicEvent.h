#import "Date.h"

@interface BasicEvent : PlaynomicsEvent {
  NSString * cookieId;
  NSString * sessionId;
  NSString * instanceId;
  Date * sessionStartTime;
  Date * pauseTime;
  int sequence;
  int timeZoneOffset;
  int clicks;
  int totalClicks;
  int keys;
  int totalKeys;
  int collectMode;
}

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId sessionId:(NSString *)sessionId instanceId:(NSString *)instanceId sessionStartTime:(Date *)sessionStartTime sequence:(int)sequence clicks:(int)clicks totalClicks:(int)totalClicks keys:(int)keys totalKeys:(int)totalKeys collectMode:(int)collectMode;
- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId sessionId:(NSString *)sessionId instanceId:(NSString *)instanceId timeZoneOffset:(int)timeZoneOffset;
- (NSString *) getCookieId;
- (void) setCookieId:(NSString *)cookieId;
- (NSString *) getSessionId;
- (void) setSessionId:(NSString *)sessionId;
- (NSString *) getInstanceId;
- (void) setInstanceId:(NSString *)instanceId;
- (Date *) getSessionStartTime;
- (void) setSessionStartTime:(Date *)sessionStartTime;
- (Date *) getPauseTime;
- (void) setPauseTime:(Date *)pauseTime;
- (int) getSequence;
- (void) setSequence:(int)sequence;
- (int) getTimeZoneOffset;
- (void) setTimeZoneOffset:(int)timeZoneOffset;
- (int) getClicks;
- (void) setClicks:(int)clicks;
- (int) getTotalClicks;
- (void) setTotalClicks:(int)totalClicks;
- (int) getKeys;
- (void) setKeys:(int)keys;
- (int) getTotalKeys;
- (void) setTotalKeys:(int)totalKeys;
- (int) getCollectMode;
- (void) setCollectMode:(int)collectMode;
- (NSString *) toQueryString;
@end

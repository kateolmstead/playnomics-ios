#import "Serializable.h"

@interface GameEvent : PlaynomicsEvent <Serializable> {
  NSString * sessionId;
  NSString * site;
  NSString * instanceId;
  NSString * type;
  NSString * gameId;
  NSString * reason;
}

@property(nonatomic, retain) NSString * sessionId;
@property(nonatomic, retain) NSString * instanceId;
@property(nonatomic, retain) NSString * type;
@property(nonatomic, retain) NSString * gameId;
@property(nonatomic, retain) NSString * reason;
@property(nonatomic, retain) NSString * site;
- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId sessionId:(NSString *)sessionId site:(NSString *)site instanceId:(NSString *)instanceId type:(NSString *)type gameId:(NSString *)gameId reason:(NSString *)reason;
- (void) setSessionId:(NSString *)sessionId;
- (void) setInstanceId:(NSString *)instanceId;
- (void) setType:(NSString *)type;
- (void) setGameId:(NSString *)gameId;
- (void) setReason:(NSString *)reason;
- (void) setSite:(NSString *)site;
- (NSString *) toQueryString;
@end

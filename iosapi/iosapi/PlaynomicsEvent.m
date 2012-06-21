#import "PlaynomicsEvent.h"

EventType EventTypeValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"appStart"])
      return appStart;
    else if ([text isEqualToString:@"appPage"])
      return appPage;
    else if ([text isEqualToString:@"appRunning"])
      return appRunning;
    else if ([text isEqualToString:@"appPause"])
      return appPause;
    else if ([text isEqualToString:@"appResume"])
      return appResume;
    else if ([text isEqualToString:@"appStop"])
      return appStop;
    else if ([text isEqualToString:@"userInfo"])
      return userInfo;
    else if ([text isEqualToString:@"sessionStart"])
      return sessionStart;
    else if ([text isEqualToString:@"sessionEnd"])
      return sessionEnd;
    else if ([text isEqualToString:@"gameStart"])
      return gameStart;
    else if ([text isEqualToString:@"gameEnd"])
      return gameEnd;
    else if ([text isEqualToString:@"transaction"])
      return transaction;
    else if ([text isEqualToString:@"invitationSent"])
      return invitationSent;
    else if ([text isEqualToString:@"invitationResponse"])
      return invitationResponse;
  }
  return -1;
}

NSString* EventTypeDescription(EventType value) {
  switch (value) {
    case appStart:
      return @"appStart";
    case appPage:
      return @"appPage";
    case appRunning:
      return @"appRunning";
    case appPause:
      return @"appPause";
    case appResume:
      return @"appResume";
    case appStop:
      return @"appStop";
    case userInfo:
      return @"userInfo";
    case sessionStart:
      return @"sessionStart";
    case sessionEnd:
      return @"sessionEnd";
    case gameStart:
      return @"gameStart";
    case gameEnd:
      return @"gameEnd";
    case transaction:
      return @"transaction";
    case invitationSent:
      return @"invitationSent";
    case invitationResponse:
      return @"invitationResponse";
  }
  return nil;
}

long const serialVersionUID = 1L;

@implementation PlaynomicsEvent

- (id) init:(EventType)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId {
  if (self = [super init]) {
    self.eventTime = [[NSDate alloc] init];
    self.eventType = eventType;
    self.applicationId = applicationId;
    self.userId = userId;
  }
  return self;
}

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

- (EventType) getEventType {
  return eventType;
}

- (void) setEventType:(EventType)eventType {
  self.eventType = eventType;
}

- (NSDate *) getEventTime {
  return eventTime;
}

- (void) setEventTime:(NSDate *)eventTime {
  self.eventTime = eventTime;
}

- (NSNumber *) getApplicationId {
  return applicationId;
}

- (void) setApplicationId:(NSNumber *)applicationId {
  self.applicationId = applicationId;
}

- (NSString *) getUserId {
  return userId;
}

- (void) setUserId:(NSString *)userId {
  self.userId = userId;
}

- (NSString *) description {
    return [[[eventTime description] stringByAppendingString:@": "] stringByAppendingString: [EventTypeDescription(eventType) description]];
}

- (NSString *) addOptionalParam:(NSString *)url param:(NSString *)param value:(NSObject *)value {
  if (value != nil) {
    url = [url stringByAppendingString:[[@"&" stringByAppendingString:param] stringByAppendingString:[@"=" stringByAppendingString:[value description]]];
  }
  return url;
}

- (NSString *) toQueryString {
}


@end

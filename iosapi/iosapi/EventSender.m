#import "EventSender.h"

NSString * const TAG = [[EventSender class] simpleName];

@implementation EventSender

- (id) init {
  if (self = [self init:NO]) {
  }
  return self;
}

- (id) initWithTestMode:(BOOL)testMode {
  if (self = [super init]) {
    testMode = NO;

    @try {
      testMode = testMode;
      ResourceBundle * b = [ResourceBundle getBundle:@"playnomicsAndroidAnalytics"];
      version = [b getString:@"version"];
      baseUrl = [b getString:@"baseUrl"];
      connectTimeout = [[[NSNumber alloc] init:[b getString:@"connectTimeout"]] autorelease];
    }
    @catch (NSException * e) {
      [e printStackTrace];
    }
  }
  return self;
}

- (BOOL) sendToServer:(NSString *)eventUrl {

  @try {
    eventUrl = [eventUrl stringByAppendingString:[@"&esrc=aj&ever=" stringByAppendingString:version]];
    if (testMode)
      [System.out println:[@"Sending event to server: " stringByAppendingString:eventUrl]];
    else
      [Log i:TAG param1:[@"Sending event to server: " stringByAppendingString:eventUrl]];
    HttpURLConnection * con = (HttpURLConnection *)[[[[URL alloc] init:eventUrl] autorelease] openConnection];
    [con setConnectTimeout:connectTimeout];
    return ([con responseCode] == HttpURLConnection.HTTP_OK);
  }
  @catch (NSException * e) {
    if (testMode)
      [System.out println:[@"Send failed: " stringByAppendingString:[e message]]];
    else
      [Log i:TAG param1:[@"Send failed: " stringByAppendingString:[e message]]];
    return NO;
  }
}

- (BOOL) sendToServer:(PlaynomicsEvent *)pe {
  return [self sendToServer:[baseUrl stringByAppendingString:[pe toQueryString]]];
}

- (void) dealloc {
  [version release];
  [baseUrl release];
  [super dealloc];
}

@end

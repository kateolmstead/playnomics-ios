#import "HttpURLConnection.h"
#import "URL.h"
#import "ResourceBundle.h"
#import "Log.h"

@interface EventSender : NSObject {
  NSString * version;
  NSString * baseUrl;
  int connectTimeout;
  BOOL testMode;
}

- (id) init;
- (id) initWithTestMode:(BOOL)testMode;
- (BOOL) sendToServer:(NSString *)eventUrl;
- (BOOL) sendToServer:(PlaynomicsEvent *)pe;
@end

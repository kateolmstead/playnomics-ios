#import "ErrorEvent.h"

long const serialVersionUID = 1L;

@implementation ErrorEvent

- (id) initWithE:(NSException *)e {
  if (self = [super init]) {
    e = e;
  }
  return self;
}

- (NSString *) toQueryString {
  NSString * queryString = nil;

  @try {
    StringWriter * sw = [[[StringWriter alloc] init] autorelease];
    PrintWriter * pw = [[[PrintWriter alloc] init:sw] autorelease];
    [e printStackTrace:pw];
    queryString = [@"ajlog?m=" stringByAppendingString:[URLEncoder encode:[sw description] param1:@"US-ASCII"]];
  }
  @catch (UnsupportedEncodingException * e) {
    [e printStackTrace];
  }
  return queryString;
}

- (void) dealloc {
  [e release];
  [super dealloc];
}

@end

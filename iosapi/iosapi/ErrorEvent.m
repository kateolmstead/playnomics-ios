#import "ErrorEvent.h"

@implementation ErrorEvent

- (id) initWithE:(NSException *)e {
  if (self = [super init]) {
    _e = e;
  }
  return self;
}

- (NSString *) toQueryString {
    return nil;
//    NSString * queryString = nil;

//  @try {
//    StringWriter * sw = [[[StringWriter alloc] init] autorelease];
//    PrintWriter * pw = [[[PrintWriter alloc] init:sw] autorelease];
//    [e printStackTrace:pw];
//    queryString = [@"ajlog?m=" stringByAppendingString:[URLEncoder encode:[sw description] param1:@"US-ASCII"]];
//  }
//  @catch (UnsupportedEncodingException * e) {
//    [e printStackTrace];
//  }
//  return queryString;
}

- (void) dealloc {
  [_e release];
  [super dealloc];
}

@end

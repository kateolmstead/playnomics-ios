#import "EventSender.h"

#import "PLConfig.h"
#import "PlaynomicsEvent.h"

@implementation EventSender

- (id) init {
    if (self = [self initWithTestMode: NO]) {
    }
    return self;
}

- (id) initWithTestMode:(BOOL)testMode {
    if (self = [super init]) {
        _testMode = testMode;
        
        
        _version = [PLPropertyVersion retain];
        _baseUrl = [PLPropertyBaseUrl retain];
        _connectTimeout = PLPropertyConnectionTimeout;
    }
    return self;
}

- (BOOL) sendToServer: (NSString *) eventUrl {
    eventUrl = [eventUrl stringByAppendingFormat:@"&esrc=aj&ever=%@", _version];
    NSLog(@"Sending event to server: %@", eventUrl);
    
    NSURL *url = [NSURL URLWithString:eventUrl];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_connectTimeout] autorelease];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Send failed:%@", [error localizedDescription]);
        return NO;
    }
    return TRUE;
}

- (BOOL) sendEventToServer:(PlaynomicsEvent *)pe {
    return [self sendToServer:[_baseUrl stringByAppendingString:[pe toQueryString]]];
}

- (void) dealloc {
    [_version release];
    [_baseUrl release];
    [super dealloc];
}

@end

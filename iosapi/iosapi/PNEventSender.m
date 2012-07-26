#import "PNEventSender.h"

#import "PNConfig.h"
#import "PNEvent.h"

@implementation PNEventSender

- (id) init {
    if (self = [self initWithTestMode: NO]) {
    }
    return self;
}

- (id) initWithTestMode:(BOOL)testMode {
    if (self = [super init]) {
        _testMode = testMode;
        
        
        _version = [PNPropertyVersion retain];
        _baseUrl = [PNPropertyBaseUrl retain];
        _connectTimeout = PNPropertyConnectionTimeout;
    }
    return self;
}

- (BOOL) sendToServer: (NSString *) eventUrl {
    eventUrl = [eventUrl stringByAppendingFormat:@"&esrc=ios&ever=%@", _version];
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

- (BOOL) sendEventToServer:(PNEvent *)pe {
    return [self sendToServer:[_baseUrl stringByAppendingString:[pe toQueryString]]];
}

- (void) dealloc {
    [_version release];
    [_baseUrl release];
    [super dealloc];
}

@end

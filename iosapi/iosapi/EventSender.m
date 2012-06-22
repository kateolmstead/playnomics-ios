#import "EventSender.h"

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
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        _version = [[mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] retain];
        _baseUrl = [[mainBundle objectForInfoDictionaryKey:@"PLBaseURL"] retain];
        _connectTimeout = [[mainBundle objectForInfoDictionaryKey:@"PLConnectionTimeout"] doubleValue];
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
        return false;
    }
    return true;
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

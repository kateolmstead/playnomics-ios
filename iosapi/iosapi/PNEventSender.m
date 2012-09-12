#import "PNEventSender.h"

#import "PNConfig.h"
#import "PNEvent.h"


@interface PNEventSender ()
+ (void)sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))handler;
@end

@implementation PNEventSender

@synthesize testMode=_testMode;

- (id) init {
    if (self = [self initWithTestMode: NO]) {
    }
    return self;
}

- (id) initWithTestMode:(BOOL)testMode {
    if (self = [super init]) {
        _testMode = testMode;
        
        
        _version = [PNPropertyVersion retain];
        
        _connectTimeout = PNPropertyConnectionTimeout;
    }
    return self;
}

- (void) sendEventToServer:(PNEvent *)pe withEventQueue: (NSMutableArray *) eventQueue {

    if (_testMode) {
        _baseUrl = [PNPropertyBaseTestUrl retain];
    }
    else
        _baseUrl = [PNPropertyBaseProdUrl retain];

    NSString * eventUrl = [_baseUrl stringByAppendingString:[pe toQueryString]];
    eventUrl = [eventUrl stringByAppendingFormat:@"&esrc=ios&ever=%@", _version];
    NSLog(@"Sending event to server: %@", eventUrl);
    
    NSURL *url = [NSURL URLWithString:eventUrl];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_connectTimeout] autorelease];

    [PNEventSender sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (![eventQueue containsObject:pe])
                [eventQueue addObject:pe];
             NSLog(@"Send failed:%@", [error localizedDescription]);
        }
        else {
            if ([eventQueue containsObject:pe])
                [eventQueue removeObject:pe];
            NSLog(@"Send succeeded!");
        }
    }];
}


+ (void)sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))handler
{
    __block NSURLResponse *response = nil;
    __block NSError *error = nil;
    __block NSData *data = nil;
    
    // Wrap up synchronous request within a block operation
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        data = [NSURLConnection sendSynchronousRequest:request 
                                     returningResponse:&response 
                                                 error:&error];
    }];
    
    // Set completion block
    // EDIT: Set completion block, perform on main thread for safety
    blockOperation.completionBlock = ^{
        
        // Perform completion on main queue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handler(response, data, error);
        }];
    };
    
    // (or execute completion block on background thread)
    // blockOperation.completionBlock = ^{ handler(response, data, error); };
    
    // Execute operation
    [queue addOperation:blockOperation];
}

- (void) dealloc {
    [_version release];
    [_baseUrl release];
    [super dealloc];
}

@end

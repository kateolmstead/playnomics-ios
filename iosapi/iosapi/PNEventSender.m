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
    if (eventUrl ==nil)
    {
        NSLog(@"WARNING...missing event utl\r\n---> %@",self);
        NSLog(@"%d,%s",__LINE__,__FUNCTION__);
        return;
    }
    eventUrl = [eventUrl stringByAppendingFormat:@"&esrc=ios&ever=%@", _version];
    NSLog(@"Sending event to server: %@", eventUrl);
    
    NSURL *url = [NSURL URLWithString:eventUrl];
    __block NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_connectTimeout] autorelease];

    void (^handler)(NSURLResponse *, NSData *, NSError *);
    handler = ^ (NSURLResponse *response, NSData *data, NSError *error) {
        //NSLog(@"debug ~ In sendAsynchronousRequest Completion Handler.");
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
        //NSLog(@"debug ~ Done sendAsynchronousRequest with Completion Handler.");
    };
    
    //NSLog(@"debug ~ OS is using:%@", [[UIDevice currentDevice] systemVersion]);
    //NSLog(@"debug ~ checking that NSURLConnection responds to sendAsynchronousRequest:queue:completionHandler:");
    
    // Strange that this would work as repondsToSelector is not a static method!.
    // The normal methods are always returning false thought:
    // - [NSURLConnection instancesRespondToSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)]
    // - [[[NSURLConnection alloc] init] respondsToSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)];
    BOOL responds = [NSURLConnection respondsToSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)];
    // Check to see if the NSURL connection has the proper method.
    // Only available from 5.0 and on.
    if (responds) {            
        //NSLog(@"debug ~ OK - NSURLConnection responds to sendAsynchronousRequest:queue:completionHandler:");
        //NSLog(@"debug ~ sending asynchronous request");
        [NSURLConnection sendAsynchronousRequest:request 
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:handler];
        //NSLog(@"debug ~ asynchronous request started");
    }
    else {
        //NSLog(@"debug ~ NOK - NSURLConnection does NOT respond to sendAsynchronousRequest:queue:completionHandler:");
        //NSLog(@"debug ~ Using custom implementation.");
        //NSLog(@"debug ~ sending asynchronous request");
        [PNEventSender sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
        //NSLog(@"debug ~ asynchronous request started");
    }
}


+ (void)sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))handler
{
    //NSLog(@"debug ~ in PNEventSender sendAsynchronousRequest:queue:completionHandler");
    __block NSURLResponse *response = nil;
    __block NSError *error = nil;
    __block NSData *data = nil;
//    __block NSURLRequest *req = request;
    
        //NSLog(@"debug ~ creating block operation");
    // Wrap up synchronous request within a block operation
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        //NSLog(@"debug ~ about to run Synchronous request: NSURLConnection sendSynchronousRequest:returningResponse:error:");
        data = [NSURLConnection sendSynchronousRequest:request
                                     returningResponse:&response 
                                                 error:&error];
        //NSLog(@"debug ~ finished with NSURLConnection sendSynchronousRequest:returningResponse:error:");
    }];
        //NSLog(@"debug ~ created block operation");    
    
    //NSLog(@"debug ~ creating completion block");    
    // Set completion block
    // EDIT: Set completion block, perform on main thread for safety
    blockOperation.completionBlock = ^{
        //NSLog(@"debug ~ in completion block, adding handler to main queue");
        // Perform completion on main queue
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //NSLog(@"debug ~ calling completion handler on main queue");
            handler(response, data, error);
            //NSLog(@"debug ~ called completion handler on main queue");
        }];
        //NSLog(@"debug ~ added completion handler on main queue");
    };
    //NSLog(@"debug ~ created completion block");    
    
    // (or execute completion block on background thread)
    // blockOperation.completionBlock = ^{ handler(response, data, error); };
    
    //NSLog(@"debug ~ queue operation");    
    // Execute operation
    [queue addOperation:blockOperation];
    //NSLog(@"debug ~ operation queued");    
}

- (void) dealloc {
    //NSLog(@"debug ~ deallocating PNEventSender");
    [_version release];
    [_baseUrl release];
    [super dealloc];
}

@end

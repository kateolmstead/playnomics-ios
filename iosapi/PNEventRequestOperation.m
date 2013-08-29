//
//  PNEventRequestOperation.m
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import "PNEventRequestOperation.h"

@implementation PNEventRequestOperation{
    BOOL _executing;
    BOOL _finished;
    PNEventApiClient * _client;
}

@synthesize urlPath=_urlPath;
@synthesize successful=_successful;

- (id) initWithUrl : (NSString *) urlPath apiClient : (PNEventApiClient *) apiClient {
    if((self = [super init])){
        _urlPath = urlPath;
        _executing = NO;
        _finished = NO;
        _successful = NO;
        _client = apiClient;
    }
    return self;
}

- (BOOL) isConcurrent {
    return YES;
}

- (BOOL) isExecuting {
    return _executing;
}

- (BOOL) isFinished {
    @synchronized(self){
        return _finished;
    }
}

-(void) setIsFinished:(BOOL) value{
    @synchronized(self){
        _finished = value;
    }
}

- (void) start {
    [PNLogger log:PNLogLevelDebug format:@"Starting event request @%", _urlPath];
    
    // Always check for cancellation before launching the task.
    if ([self isCancelled]){
        [PNLogger log:PNLogLevelDebug format:@"Request has been cancelled @%", _urlPath];
        
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        [self setIsFinished: YES];
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void) main {
    NSURLConnection *connection;
    @try {
        NSURL *url = [[[NSURL alloc] initWithString: self.urlPath] autorelease];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:PNPropertyConnectionTimeout] autorelease];
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
        while(!([self isCancelled] || [self isFinished])){
            //wait for the operation to either complete or get cancelled
            [NSThread sleepForTimeInterval: 1];
        }
        
        if([self isCancelled]){
            //close the URL request
            [connection cancel];
            [_client onEventWasCanceled:self.urlPath];
            [self completeOperation];
        }
    } @catch(...){
        [self completeOperation];
    } @finally {
        [connection release];
    }
}

//NSURLConnectionDelegate Protocol
- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
    [PNLogger log:PNLogLevelDebug format:@"Request for @% completed with error @%", _urlPath, error.description];
    [self completeOperation];
    [_client enqueueEventUrl: self.urlPath];
}
//NSURLConnectionDataDelegate Protocol
- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
    [PNLogger log:PNLogLevelDebug format:@"Request for @% completed with status code @%", _urlPath, [httpResponse statusCode]];
    [self completeOperation];
}

- (void) completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self setIsFinished: YES];
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end

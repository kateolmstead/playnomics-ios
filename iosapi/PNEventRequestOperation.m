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
    id<PNUrlProcessorDelegate> _delegate;
}

@synthesize urlPath=_urlPath;
@synthesize successful=_successful;

- (id) initWithUrl : (NSString *) urlPath delegate : (id<PNUrlProcessorDelegate>) delegate {
    if((self = [super init])){
        _urlPath = [urlPath retain];
        _executing = NO;
        _finished = NO;
        _delegate = delegate;
    }
    return self;
}

- (BOOL) isExecuting {
    return _executing;
}

- (BOOL) isFinished {
    return _finished;
}

-(void) setIsFinished:(BOOL) value{
    @synchronized(self){
        _finished = value;
    }
}

- (void) start {
    [PNLogger log:PNLogLevelDebug format:@"Starting event request %@", _urlPath];
    
    //check for cancellation before launching the task.
    if ([self isCancelled]){
        [PNLogger log:PNLogLevelDebug format:@"Request has been cancelled %@", _urlPath];
        
        //move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        [self setIsFinished: YES];
        [_delegate onDidFailToProcessUrl:_urlPath tryAgain:NO];
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self performSelectorOnMainThread:@selector(startUrlRequest) withObject:nil waitUntilDone:NO];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void) startUrlRequest{
    NSURL *url = [[[NSURL alloc] initWithString: self.urlPath] autorelease];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:PNPropertyConnectionTimeout] autorelease];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
}


//NSURLConnectionDelegate Protocol
- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
    [PNLogger log:PNLogLevelDebug format:@"Request for %@ completed with error %@", _urlPath, error.description];
    [_delegate onDidFailToProcessUrl:_urlPath tryAgain:YES];
    [self completeOperation];
}
//NSURLConnectionDataDelegate Protocol
- (void) connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
    [PNLogger log:PNLogLevelDebug format:@"Request for %@ completed with status code %d", _urlPath, [httpResponse statusCode]];
    [_delegate onDidProcessUrl: _urlPath];
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

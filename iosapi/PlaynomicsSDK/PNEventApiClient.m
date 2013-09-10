#import "PNEventApiClient.h"
#import "PNEvent.h"
#import "PNSession.h"
#import "PNConcurrentQueue.h"
#import "PNEventRequestOperation.h"
#import "PNConcurrentSet.h"

@implementation PNEventApiClient{
    PNSession* _session;
    BOOL _running;
    NSOperationQueue *_operationQueue;
    
    PNConcurrentSet *_inprocessEvents;
}

- (id) initWithSession: (PNSession *) session {
    if ((self = [super init])) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setSuspended: YES];
        _inprocessEvents = [[PNConcurrentSet alloc] init];
        _session = session;
        _running = NO;
    }
    return self;
}

- (void) dealloc {
    [_operationQueue release];
    _session = nil;
    [super dealloc];
}

- (void) enqueueEvent:(PNEvent *)event{
    NSString* url = [PNEventApiClient buildUrlWithBase:[_session getEventsUrl]  withPath: event.baseUrlPath withParams: event.eventParameters];
    [self enqueueEventUrl: url];
}

- (void) enqueueEventUrl: (NSString *) url{
    if(url) {
        PNEventRequestOperation *op = [[PNEventRequestOperation alloc] initWithUrl:url delegate:self];
        [_operationQueue addOperation: op];
        [_inprocessEvents addObject: url];
        [op autorelease];
    }
}

- (void) onDidProcessUrl:(NSString *)url{
    [_inprocessEvents removeObject: url];
}

- (void) onDidFailToProcessUrl: (NSString *) url
                      tryAgain:(BOOL) tryAgain{
    if(tryAgain){
        [self enqueueEventUrl: url];
        [_inprocessEvents removeObject:url];
    }
}

+ (NSString *) buildUrlWithBase:(NSString *) base
                       withPath:(NSString *) path
                     withParams:(NSDictionary *) params{
    if(!base){
        return nil;
    }
    NSMutableString *url = [NSMutableString stringWithString:base];

    if(path){
        if(![url hasSuffix:@"/"]){
            [url appendString:@"/"];
        }
        [url appendString: path];
    }
    
    BOOL containsQueryString = [url rangeOfString:@"?"].location != NSNotFound;
    BOOL firstParam = YES;
    
    if(params){
        for(NSString *key in params){
            NSObject *value = [params valueForKey: key];
            if(!value){ continue; }
            
            if(firstParam && !containsQueryString){
                [url appendFormat:@"?%@=%@", [PNUtil urlEncodeValue: key], [PNUtil urlEncodeValue: [value description]]];
            } else {
                [url appendFormat:@"&%@=%@", [PNUtil urlEncodeValue: key], [PNUtil urlEncodeValue: [value description]]];
            }
            firstParam = NO;
        }
    }
    return url;
}

- (void) start{
    if(_running){ return; }
    _running = YES;
    [_operationQueue setSuspended: NO];
}

- (void) pause{
    if(!_running){ return; }
    _running = NO;
    [_operationQueue setSuspended: YES];
}

- (void) stop{
    if(!_running){ return; }
    [_operationQueue cancelAllOperations];
    //wait for all cancellations
    [_operationQueue waitUntilAllOperationsAreFinished];
    _running = NO;
}

- (NSSet *) getAllUnprocessedUrls{
    return [_inprocessEvents copyOfData];
}

@end

#import "PNEventApiClient.h"
#import "PNEvent.h"
#import "PNSession.h"
#import "PNConcurrentQueue.h"
#import "PNEventRequestOperation.h"

@implementation PNEventApiClient{
    PNSession* _session;
    BOOL _running;
    NSOperationQueue *_operationQueue;
    PNConcurrentQueue *_cancelledEvents;
}

- (id) initWithSession: (PNSession *) session {
    if ((self = [super init])) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setSuspended: NO];
        _cancelledEvents = [[PNConcurrentQueue alloc] init];
        _session = session;
        _running = YES;
    }
    return self;
}

-(void) dealloc {
    [_operationQueue release];
    _session = nil;
    [super dealloc];
}

-(void) enqueueEvent:(PNEvent *)event{
    NSString* url = [self getUrlStringForEvent: event];
    [self enqueueEventUrl: url];
}

-(void) enqueueEventUrl: (NSString *) url{
    if(url) {
        PNEventRequestOperation *op = [[PNEventRequestOperation alloc] initWithUrl:url apiClient:self];
        [_operationQueue addOperation: op];
        [op autorelease];
    }
}

-(void) onEventWasCanceled: (NSString *) url{
    [_cancelledEvents enqueue:url];
}

-(NSString *) getUrlStringForEvent:(PNEvent *) event{
    NSMutableString * eventUrl = [NSMutableString stringWithString:_session.getEventsUrl];
    [eventUrl appendString: event.baseUrlPath];
    
    BOOL containsQueryString = [eventUrl rangeOfString:@"?"].location != NSNotFound;
    BOOL firstParam = YES;
    
    for(NSString *key in event.eventParameters){
        NSObject *value = [event.eventParameters valueForKey: key];
        if(!value){ continue; }
    
        if(firstParam && !containsQueryString){
            [eventUrl appendFormat:@"?%@=%@", [PNUtil urlEncodeValue: key], [PNUtil urlEncodeValue: [value description]]];
        } else {
            [eventUrl appendFormat:@"&%@=%@", [PNUtil urlEncodeValue: key], [PNUtil urlEncodeValue: [value description]]];
        }
        firstParam = NO;
    }
    return eventUrl;
}

- (void) start{
    if(_running){ return; }
    _running = YES;
    [_operationQueue setSuspended: NO];
}

-(void) pause{
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
    NSMutableSet * set = [[NSMutableSet alloc] init];
    [set autorelease];
    
    while(!_cancelledEvents.isEmpty){
        [set addObject:[_cancelledEvents dequeue]];
    }
    return set;
}

@end

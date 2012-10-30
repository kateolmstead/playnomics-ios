//
// Created by jmistral on 10/3/12.
//

#import "PlaynomicsSession+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "PlaynomicsFrame+Exposed.h"
#import "PNConstants.h"
#import "PNConfig.h"


@implementation PlaynomicsMessaging {
  @private
    NSMutableDictionary *_actionHandlers;
    id _delegate;
}

@synthesize delegate = _delegate;


+ (PlaynomicsMessaging *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init {
    if (self = [super init]) {
        _actionHandlers = [[NSMutableDictionary dictionary] retain];
    }
    return self;
}

- (void)dealloc {
    [_actionHandlers release];
    [_delegate release];
    [super dealloc];
}

- (void)registerActionHandler:(id <PNAdClickActionHandler>)clickAction withLabel:(NSString *)label {
    
    [_actionHandlers setObject:clickAction forKey:label];
}

- (PlaynomicsFrame *)initFrameWithId:(NSString *)frameId {
    // Get caller for debuging purposes
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSString *caller = [array objectAtIndex:4];
    PlaynomicsFrame *frame = [[PlaynomicsFrame alloc] initWithProperties:[self _retrieveFramePropertiesForId:frameId withCaller:caller]
                                                              forFrameId:frameId];
    return [frame autorelease];
}

- (NSDictionary *)_retrieveFramePropertiesForId:(NSString *)frameId withCaller: (NSString *) caller
{
    NSError *error;
    PlaynomicsSession *pn = [PlaynomicsSession sharedInstance];
    signed long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString *queryString = [NSString stringWithFormat:@"?a=%lld&u=%@&p=%@&t=%lld&b=%@&f=%@", pn.applicationId, pn.userId, caller, time, pn.cookieId, frameId];
    NSString *serverUrl;
    // Check for test mode
    if ([pn testMode]) {
        // TODO: switch from debug when server is ready
        serverUrl = PNPropertyMessagingDebugUrl;
    } else {
        serverUrl = PNPropertyMessagingProdUrl;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverUrl, queryString]];
    
    NSLog(@"calling ad server: %@", url.absoluteString);
    NSMutableData *adResponse = [NSMutableData dataWithContentsOfURL: url];
    NSDictionary *props = [NSJSONSerialization JSONObjectWithData:adResponse options:kNilOptions error:&error];

    return props;
}

- (void)performActionForLabel:(NSString *)label {
    id<PNAdClickActionHandler> handler = [_actionHandlers objectForKey:label];
    if (handler != nil) {
        [handler performAction];
    }
}

- (void)executeActionOnDelegate:(NSString *)action {
    if (self.delegate == nil) {
        NSLog(@"There is currently no delegate to handle the action: %@", action);
        return;
    }

    SEL actionToExecute = NSSelectorFromString(action);
    if (![self.delegate respondsToSelector:actionToExecute]) {
        NSLog(@"The current delegate cannot handle the provided action.  Delegate = %@, action=%@",
                self.delegate, action);
        return;
    }

    @try {
        [self.delegate performSelector:actionToExecute];
    }
    @catch (NSException *e) {
        NSLog(@"There was an exception thrown executing action '%@': [%@] %@", action, e.name, e.reason);
    }
}

@end
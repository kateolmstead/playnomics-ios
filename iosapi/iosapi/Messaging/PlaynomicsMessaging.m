//
// Created by jmistral on 10/3/12.
//

#import "PlaynomicsSession+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "PlaynomicsFrame+Exposed.h"
#import "PNConstants.h"
#import "PNConfig.h"
#import "PNErrorEvent.h"


@implementation PlaynomicsMessaging {
  @private
    NSMutableDictionary *_actionHandlers;
    NSMutableDictionary *_frames;
    id _delegate;
}

@synthesize delegate = _delegate;
@synthesize isTesting = _isTesting;

+ (PlaynomicsMessaging *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init {
    if (self = [super init]) {
        _actionHandlers = [[NSMutableDictionary dictionary] retain];
        _frames = [[NSMutableDictionary dictionary] retain];
        self.isTesting = NO;
#ifdef STUB
        self.isTesting = YES;
#endif
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
    
    NSDictionary *propDict = [self _retrieveFramePropertiesForId:frameId withCaller:caller];
    PlaynomicsFrame *frame = [[PlaynomicsFrame alloc] initWithProperties:propDict
                                                              forFrameId:frameId andDelegate: self];
    [_frames setObject:frame forKey:frameId];
    
    return [frame autorelease];
}

- (NSDictionary *)_retrieveFramePropertiesForId:(NSString *)frameId withCaller: (NSString *) caller
{
    NSError *error = nil;
    PlaynomicsSession *pn = [PlaynomicsSession sharedInstance];
    signed long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int screenWidth = screenRect.size.width;
    int screenHeight = screenRect.size.height;
    
    NSString *queryString = [NSString stringWithFormat:@"?a=%lld&u=%@&p=%@&t=%lld&b=%@&f=%@&c=%d&d=%d&esrc=ios&ever=%@",
                             pn.applicationId, pn.userId, caller, time, pn.cookieId, frameId, screenHeight, screenWidth, PNPropertyVersion];
    NSString *serverUrl;
    
    // Check for test mode
    if ([pn testMode]) {
        serverUrl = PNPropertyMessagingTestUrl;
    } else {
        serverUrl = PNPropertyMessagingProdUrl;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverUrl, queryString]];
    
    //stubbing data here , if isTesting
//    if (self.isTesting) {
//        if ([frameId isEqualToString:@"testCC"]) {
//            url = [NSURL fileURLWithPath:@"/Users/mcconkiee/Desktop/stubs/invalid.json"];
//        }
//        else
//            url = [NSURL fileURLWithPath:@"/Users/mcconkiee/Desktop/stubs/pnx.json"];
//        
//    }

    NSLog(@"calling ad server: %@", url.absoluteString);
    NSMutableData *adResponse = [NSMutableData dataWithContentsOfURL: url];
    
    if (adResponse==nil)
    {
        PNErrorDetail *detail = [PNErrorDetail pNErrorDetailWithType:PNErrorTypeInvalidJson];
        [PlaynomicsSession errorReport:detail];
        return nil;
    }
    
    NSDictionary *props = [NSJSONSerialization JSONObjectWithData:adResponse options:kNilOptions error:&error];

    NSLog(@"NSDictionary %@", props);
    
    if (error!=nil) {
        
        PNErrorDetail *details = [PNErrorDetail pNErrorDetailWithType:PNErrorTypeInvalidJson];
        [PlaynomicsSession errorReport:details];
        
    }
    
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

- (void) refreshFrameWithId: (NSString *) frameId {
    
    // refresh ad
    PlaynomicsFrame *frame = [_frames objectForKey:frameId];
    if (frame != nil) {
        [frame refreshProperties:[self _retrieveFramePropertiesForId:frameId withCaller:nil]];
    }
}

@end
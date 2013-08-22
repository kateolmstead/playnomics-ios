//
// Created by jmistral on 10/3/12.
//

#import "PlaynomicsSession+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "PlaynomicsFrame+Exposed.h"
#import "PNConstants.h"
#import "PNConfig.h"
#import "PNErrorEvent.h"
#import "PNUtil.h"

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

- (PlaynomicsFrame *) createFrameWithId:(NSString*) frameId {
    return [self createFrameWithId:frameId frameDelegate:nil];
}

- (PlaynomicsFrame *)createFrameWithId:(NSString*)frameId frameDelegate: (id<PNFrameDelegate>)frameDelegate {
    // Get caller for debuging purposes
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    // Caller will be the name of the method that called initFrameWithId
    NSString *caller = [array objectAtIndex:4];
    
    NSDictionary *propDict = [self _retrieveFramePropertiesForId:frameId withCaller:caller];
    PlaynomicsFrame *frame = [[PlaynomicsFrame alloc] initWithProperties:propDict
                                                        forFrameId:frameId
                                                        frameDelegate: frameDelegate];
    return frame;
}

// Make an ad request to the PN Ad Servers
- (NSDictionary *)_retrieveFramePropertiesForId:(NSString *)frameId withCaller: (NSString *) caller
{
    PlaynomicsSession *pn = [PlaynomicsSession sharedInstance];
    signed long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    int screenWidth = screenRect.size.width;
    int screenHeight = screenRect.size.height;
    
    NSString *queryString = [NSString stringWithFormat:@"ads?a=%lld&u=%@&p=%@&t=%lld&b=%@&f=%@&c=%d&d=%d&esrc=ios&ever=%@",
                             pn.applicationId, pn.userId, caller, time, pn.cookieId, frameId, screenHeight, screenWidth, pn.sdkVersion];
    
    NSString *serverUrl = [pn getMessagingUrl];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverUrl, queryString]];
    
    NSLog(@"calling ad server: %@", url.absoluteString);
    NSMutableData* adResponse = [NSMutableData dataWithContentsOfURL: url];
    
    NSLog(@"Response data: %@", [[[NSString alloc] initWithData:adResponse encoding:NSUTF8StringEncoding] autorelease]);
    
    if (adResponse == nil){
        PNErrorDetail *detail = [PNErrorDetail pNErrorDetailWithType:PNErrorTypeInvalidJson];
        [pn errorReport:detail];
        return nil;
    }
    
    NSDictionary *props = [PNUtil deserializeJsonData: adResponse];
    return props;
}

- (void)performActionForLabel:(NSString *)label {
    id<PNAdClickActionHandler> handler = [_actionHandlers objectForKey:label];
    if (handler != nil) {
        [handler performActionOnAdClicked];
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
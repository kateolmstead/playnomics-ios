//
// Created by jmistral on 10/3/12.
//

#import "PlaynomicsMessaging+Exposed.h"
#import "PlaynomicsFrame+Exposed.h"
#import "PNConstants.h"


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
    PlaynomicsFrame *frame = [[PlaynomicsFrame alloc] initWithProperties:[self _retrieveFramePropertiesForId:frameId]
                                                              forFrameId:frameId];
    return [frame autorelease];
}

- (NSDictionary *)_retrieveFramePropertiesForId:(NSString *)frameId
{
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample_ad_data" ofType:@"js"];
    NSMutableData *adResponse = [NSMutableData dataWithContentsOfFile:filePath];
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
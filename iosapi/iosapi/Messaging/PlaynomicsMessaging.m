//
// Created by jmistral on 10/3/12.
//
#import "PlaynomicsFrame+Exposed.h"
#import "PNUtil.h"

#import "PNSession.h"

@implementation PlaynomicsMessaging

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
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
    PNSession *pn = [PNSession sharedInstance];
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
@end
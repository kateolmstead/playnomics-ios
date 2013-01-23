//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "FSNConnection.h"
#import "BaseAdComponent.h"
#import "PNActionObjects.h"

#pragma mark - PlaynomicsFrame





@implementation PlaynomicsFrame {
  @private
    NSTimer *_expirationTimer;
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    int _expirationSeconds;
    UIDeviceOrientation _currentOrientation;
    id<PNFrameRefreshHandler> _delegate;
}

@synthesize frameId = _frameId;


#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId andDelegate: (id<PNFrameRefreshHandler>) delegate {
    if (self = [super init]) {
        _frameId = [frameId retain];
        _properties = [properties retain];
        _delegate = delegate;
        
        [self _initOrientationChangeObservers];
        [self _initAdComponents];
    }
    return self;
}

- (void)dealloc {
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    [_frameId release];
    [super dealloc];
}

- (void)_initAdComponents {
    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo]
                                                     forFrame:self
                                             withTouchHandler:nil
                                                  andDelegate:self];

    _adArea = [[BaseAdComponent alloc] initWithProperties:[self _mergeAdInfoProperties]
                                                 forFrame:self
                                         withTouchHandler:@selector(_adClicked)
                                              andDelegate:self];
    
    _closeButton = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseCloseButtonInfo]
                                                      forFrame:self
                                              withTouchHandler:@selector(_stop)
                                                   andDelegate:self];
    
    NSNumber *expNum = [_properties objectForKey:FrameResponseExpiration];
    _expirationSeconds = [expNum intValue];
    
    [_background layoutComponent];
    [_adArea layoutComponent];
    [_closeButton layoutComponent];

    [_background addSubComponent:_adArea];
    [_background addSubComponent:_closeButton];
    _background.imageUI.hidden = YES;
}

- (void)componentDidLoad: (id) component {
    _background.imageUI.hidden = ![self _allComponentsLoaded];
}

- (NSDictionary *)_mergeAdInfoProperties {
    NSDictionary *adInfo = [self _determineAdInfoToUse];
    NSDictionary *adLocationInfo = [_properties objectForKey:FrameResponseAdLocationInfo];

    NSMutableDictionary *mergedDict = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [mergedDict addEntriesFromDictionary:adLocationInfo];
    return mergedDict;
}

- (NSDictionary *)_determineAdInfoToUse {
    return [[_properties objectForKey:FrameResponseAds] objectAtIndex:0];
}


#pragma mark - Orientation handlers
- (void)_initOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void)_destroyOrientationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)_deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIDeviceOrientationFaceUp
            || orientation == UIDeviceOrientationFaceDown
            || orientation == UIDeviceOrientationUnknown
            || _currentOrientation == orientation) {
        return;
    }
    _currentOrientation = orientation;

    NSLog(@"Orientation changed to: %i", orientation);
    [_background layoutComponent];
}


#pragma mark - Ad component click handlers
- (void)_stop {
    NSLog(@"Close button was pressed...");
    [self _closeAd];
    [self _submitAdImpressionToServer:[_adArea.properties objectForKey:FrameResponseAd_CloseUrl]];
}


- (void)_adClicked {
    int x = [[NSNumber numberWithFloat:_background.imageUI.frame.origin.x] intValue];
    int y = [[NSNumber numberWithFloat:_background.imageUI.frame.origin.y] intValue];
    NSString *coordParams = [NSString stringWithFormat:@"&x=%d&y=%d", x, y];
    NSString *preExecuteUrl = [[_adArea.properties objectForKey:FrameResponseAd_PreExecuteUrl] stringByAppendingString:coordParams];
    NSString *postExecuteUrl =  [[_adArea.properties objectForKey:FrameResponseAd_PostExecuteUrl] stringByAppendingString:coordParams];

    NSString *clickTarget = [_adArea.properties objectForKey:FrameResponseAd_ClickTarget];

    AdAction actionType = [PNActionObjects adActionTypeForURL:clickTarget];
    NSString *actionLabel = [PNActionObjects adActionMethodForURLPath:clickTarget];
    
    NSLog(@"Ad clicked with target (action type %i): %@", actionType, actionLabel);

    switch (actionType) {
        case AdActionHTTP: {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickTarget]];
            break;
        }
        case AdActionDefinedAction: {
            [self _submitAdImpressionToServer: preExecuteUrl];
            [[PlaynomicsMessaging sharedInstance] performActionForLabel:actionLabel];
            [self _submitAdImpressionToServer: postExecuteUrl];
            break;
        }
        case AdActionExecuteCode: {
            [self _submitAdImpressionToServer: preExecuteUrl];
            [[PlaynomicsMessaging sharedInstance] executeActionOnDelegate:actionLabel];
            [self _submitAdImpressionToServer: postExecuteUrl];
            break;
        }
        default: {
            NSLog(@"Unsupported ad action specified!");
            break;
        }
    }

    [self _closeAd];
}



- (NSString *)_determineActionLabel:(NSURL *)url {
    NSString *resource = url.resourceSpecifier;
    return [resource stringByReplacingOccurrencesOfString:@"//" withString:@""];
}

- (void)_closeAd {
    [_background hide];
    [self _destroyOrientationObservers];
    [self _stopExpiryTimer];
}


#pragma mark - Public Interface
- (DisplayResult)start {
    NSString *frameResponseURL =[_adArea.properties objectForKey:FrameResponseAd_ImpressionUrl];
    if (frameResponseURL==nil)
    {
        //TODO: send error to server
        // jslog?
        
        PNErrorDetail *details = [PNErrorDetail pNErrorDetailWithType:PNErrorTypeInvalidJson];
        [PlaynomicsSession errorReport:details];
        return DisplayResultFailUnknown;
    }
    
        
    [_background display];
    [self _startExpiryTimer];
    
    [self _submitAdImpressionToServer:frameResponseURL];

    if ([self _allComponentsLoaded]) {
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
}

- (BOOL)_allComponentsLoaded {
    return (_background.status == AdComponentStatusCompleted
            && _adArea.status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
}

- (void)_startExpiryTimer {
    @try {
        [self _stopExpiryTimer];
        
        _expirationTimer = [[NSTimer scheduledTimerWithTimeInterval:_expirationSeconds target:self selector:@selector(_notifyDelegate) userInfo:nil repeats:NO] retain];
    }
    @catch (NSException *exception) {
        NSLog(@"error: %@", exception.description);
    }
    
}

- (void)_stopExpiryTimer {
    
    @try {
        
        if ([_expirationTimer isValid]) {
            [_expirationTimer invalidate];
        }
        
        [_expirationTimer release];
        _expirationTimer = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"error: %@", exception.description);
    }   
}

- (void)_notifyDelegate {
    [_delegate refreshFrameWithId:_frameId];
}

- (void)refreshProperties:(NSDictionary *)properties {
    
    // TODO: should we reset all properties, or just the images?
    NSLog(@"refreshProperties called fro frameId: %@", _frameId);
    [self _closeAd];
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    _properties = [properties retain];
    
    [self _initOrientationChangeObservers];
    [self _initAdComponents];
    [self start];
}

- (void)_submitAdImpressionToServer:(NSString *)impressionUrl {
    if (impressionUrl==nil || impressionUrl.length<=0)
        return;//we will crash here...stop everything
    
    
    NSURL *url = [NSURL URLWithString:impressionUrl];
    NSLog(@"Submitting GET request to impression URL: %@", impressionUrl);

    FSNConnection *connection =
            [FSNConnection withUrl:url
                            method:FSNRequestMethodGET
                           headers:nil
                        parameters:nil
                        parseBlock:^id(FSNConnection *c, NSError **error) {
                            return [c.responseData stringFromUTF8];
                        }
                   completionBlock:^(FSNConnection *c) {
                       NSLog(@"Impression URL complete: error: %@, result: %@", c.error, c.parseResult);
                   }
                     progressBlock:nil];

    [connection start];
}


@end
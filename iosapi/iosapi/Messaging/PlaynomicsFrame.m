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
#import "PNErrorEvent.h"
#import "PlaynomicsCallback.h"
#pragma mark - PlaynomicsFrame

typedef enum {
    AdColony,
    AdUnknown
} AdType;

@interface PlaynomicsFrame()
@property (nonatomic,retain)PlaynomicsCallback *callbackUtil;
@property (nonatomic,retain)NSString *videoViewUrl;
@end

@implementation PlaynomicsFrame {
@private
    NSTimer *_expirationTimer;
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    int _expirationSeconds;
    UIInterfaceOrientation _currentOrientation;
    id<PNFrameRefreshHandler> _delegate;
    AdType _adType;
}

@synthesize frameId = _frameId;

#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId andDelegate: (id<PNFrameRefreshHandler>) delegate {
    if (self = [super init]) {
        _frameId = [frameId retain];
        _properties = [properties retain];
        _delegate = delegate;

        if ([properties objectForKey:FrameResponseAd_AdType] && [[properties objectForKey:FrameResponseAd_AdType] isEqualToString:@"AdColony"]) {
            _adType = AdColony;
            self.videoViewUrl = [properties objectForKey:FrameResponseAd_VideoViewUrl];
        } else {
            _adType = AdUnknown;
        }

        self.callbackUtil = [[[PlaynomicsCallback alloc] init] autorelease];
        
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
                                         withTouchHandler:[[self _mergeAdInfoProperties] valueForKey:FrameResponseAd_ClickTarget] != nil && [[self _mergeAdInfoProperties] valueForKey:FrameResponseAd_ClickTarget] != [NSNull null] ? @selector(_adClicked:) : nil
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

- (BOOL)_allComponentsLoaded {
    
    id displayNameTypeValue = _background.imageUrl;
    
    if (displayNameTypeValue != [NSNull null]){
        if(_background.imageUrl == NULL ||
           [_background.imageUrl isEqualToString:@"null"]){
            [_background setStatus:AdComponentStatusCompleted];
        }
    }
    else{
        [_background setStatus:AdComponentStatusCompleted];
    }
    
    displayNameTypeValue = _closeButton.imageUrl;
    
    if (displayNameTypeValue != [NSNull null]){
        if(_closeButton.imageUrl == NULL || [_closeButton.imageUrl isEqualToString:@"null"]){
            [_closeButton setStatus:AdComponentStatusCompleted];
        }
    }
    else{
        [_closeButton setStatus:AdComponentStatusCompleted];
    }
    
    return (_background.status == AdComponentStatusCompleted
            && _adArea.status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
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
    NSArray *adFrameResponse = [_properties objectForKey:FrameResponseAds];
    if (adFrameResponse==nil || adFrameResponse.count==0)
        return nil;
    return [adFrameResponse objectAtIndex:0];
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
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (_currentOrientation == orientation) {
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
    NSString *callback = [_adArea.properties objectForKey:FrameResponseAd_CloseUrl];
    [self.callbackUtil submitAdImpressionToServer:callback];
}

- (void)_adClicked:(UITapGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:_adArea.imageUI];
    
    int x = location.x;
    int y = location.y;
    
    NSString *coordParams = [NSString stringWithFormat:@"&x=%d&y=%d", x, y];
    
    NSString *preExecuteUrl = [[_adArea.properties objectForKey:FrameResponseAd_PreExecuteUrl] stringByAppendingString:coordParams];
    NSString *postExecuteUrl =  [_adArea.properties objectForKey:FrameResponseAd_PostExecuteUrl];
    NSString *clickTarget = [_adArea.properties objectForKey:FrameResponseAd_ClickTarget];
    
    AdAction actionType = [PNActionObjects adActionTypeForURL:clickTarget];
    NSString *actionLabel = [PNActionObjects adActionMethodForURLPath:clickTarget];
    
    NSLog(@"Preexecute URL %@", preExecuteUrl);
    NSLog(@"Post Execute URL %@", postExecuteUrl);
    
    NSLog(@"Ad clicked with target (action type %i): %@", actionType, actionLabel);
    
    NSInteger c;
    NSString *exc;
    
    switch (actionType) {
        case AdActionHTTP: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickTarget]];
            break;
        }
            
            // each call (exe, perf) should be in a try catch
            
        case AdActionDefinedAction: {
            
            NSString *pre = [NSString stringWithFormat:@"%@&x=%d&y=%d", preExecuteUrl, x, y];
            [self.callbackUtil submitAdImpressionToServer: pre];
            
            @try {
                [[PlaynomicsMessaging sharedInstance] performActionForLabel:actionLabel];
                c = 2;
                exc = @"";
            }
            @catch (NSException *e) {
                c = -6;
                exc = [NSString stringWithFormat:@"%@+%@", e.name, e.reason];
            }
            
            [self.callbackUtil submitAdImpressionToServer: postExecuteUrl];
            
            break;
        }
        case AdActionExecuteCode: {
            NSString *pre = [NSString stringWithFormat:@"%@&x=%d&y=%d", preExecuteUrl, x, y];
            [self.callbackUtil submitAdImpressionToServer: pre];
            
            @try {
                [[PlaynomicsMessaging sharedInstance] executeActionOnDelegate:actionLabel];
                c = 1;
                exc = @"";
            }
            @catch (NSException *e) {
                c = -4;
                exc = [NSString stringWithFormat:@"%@+%@", e.name, e.reason];
            }
            
            NSString *post = [NSString stringWithFormat:@"%@&c=%d&e=%@", postExecuteUrl, c, exc];
            [self.callbackUtil submitAdImpressionToServer: post];
            
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
        //this may happen due to broken JSON
        return DisplayResultFailUnknown;
    }
    
    if (_adType == AdColony) {
        [self.callbackUtil submitAdImpressionToServer:frameResponseURL];
        return DisplayAdColony;
    }
    
    [_background display];
    [self _startExpiryTimer];
    
    [self.callbackUtil submitAdImpressionToServer:frameResponseURL];
    
    if ([self _allComponentsLoaded]) {
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
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

- (void)sendVideoView {
    if (self.videoViewUrl!=nil) {
        [self.callbackUtil submitAdImpressionToServer:self.videoViewUrl];
    }
}

@end
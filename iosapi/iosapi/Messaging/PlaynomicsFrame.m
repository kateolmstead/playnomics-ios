//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame+Exposed.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "FSNConnection.h"
#import "BaseAdComponent.h"
#import "PNErrorEvent.h"
#import "PlaynomicsCallback.h"
#import "PNUtil.h"
#pragma mark - PlaynomicsFrame

typedef enum {
    AdColony,
    AdUnknown
} AdType;

@interface PlaynomicsFrame()
@property (nonatomic,retain) PlaynomicsCallback *callbackUtil;
@property (nonatomic,retain) NSString *videoViewUrl;
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
    id<PNFrameDelegate> _frameDelegate;
}

@synthesize frameId = _frameId;

#pragma mark - Lifecycle/Memory management
- (id) initWithProperties: (NSDictionary *)properties
            forFrameId:(NSString *)frameId
            andDelegate: (id<PNFrameRefreshHandler>) delegate
            frameDelegate: (id<PNFrameDelegate>) frameDelegate {
    
    if (self = [super init]) {
        _frameId = [frameId retain];
        _properties = [properties retain];
        _delegate = delegate;
        _frameDelegate = frameDelegate;
        
        self.callbackUtil = [[[PlaynomicsCallback alloc] init] autorelease];
        
        [self _initOrientationChangeObservers];
        [self _initAdComponents];
    }
    return self;
}

- (void) dealloc {
    
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    [_frameId release];
    
    if(_frameDelegate != nil){
        _frameDelegate = nil;
    }
    _delegate = nil;
    
    [super dealloc];
}

- (void) _initAdComponents {
    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo] delegate:self];
    
    _adArea = [[BaseAdComponent alloc] initWithProperties:[self _mergeAdInfoProperties] delegate:self];
    
    NSDictionary* closeButtonInfo = [_properties objectForKey:FrameResponseCloseButtonInfo];
    if([BaseAdComponent getImageFromProperties:closeButtonInfo] != nil){
        _closeButton = [[BaseAdComponent alloc] initWithProperties:closeButtonInfo delegate:self];
    }

    //NSNumber *expNum = [_properties objectForKey:FrameResponseExpiration];
    //_expirationSeconds = [expNum intValue];
    
    [_background addSubComponent:_adArea];
    if(_closeButton !=  nil){
        [_background addSubComponent:_closeButton];
    }
    _background.imageUI.hidden = YES;
}



- (NSDictionary *) _mergeAdInfoProperties {
    NSDictionary *adInfo = [self _determineAdInfoToUse];
    NSDictionary *adLocationInfo = [_properties objectForKey:FrameResponseAdLocationInfo];
    
    NSMutableDictionary *mergedDict = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [mergedDict addEntriesFromDictionary:adLocationInfo];
    
    if ([mergedDict objectForKey:FrameResponseAd_AdType] && [[mergedDict objectForKey:FrameResponseAd_AdType] isEqualToString:@"AdColony"]) {
        _adType = AdColony;
        self.videoViewUrl = [mergedDict objectForKey:FrameResponseAd_VideoViewUrl];
        NSLog(@"Setting ad type to AdColony");
    } else {
        _adType = AdUnknown;
        NSLog(@"AdType=%@", [mergedDict objectForKey:FrameResponseAd_AdType]);
    }
    
    return mergedDict;
}

- (NSDictionary *) _determineAdInfoToUse {
    NSArray *adFrameResponse = [_properties objectForKey:FrameResponseAds];
    if (adFrameResponse==nil || adFrameResponse.count==0){
        return nil;
    }
    return [adFrameResponse objectAtIndex:0];
}


#pragma mark - Orientation handlers
- (void) _initOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void) _destroyOrientationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void) _deviceOrientationDidChange: (NSNotification *)notification {
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (_currentOrientation == orientation) {
        return;
    }
    _currentOrientation = orientation;
    NSLog(@"Orientation changed to: %i", orientation);
    [_background renderComponent];
}

#pragma mark - Ad component click handlers
- (void) componentDidLoad: (id) component{
    if([self _allComponentsLoaded]){
        UIView *topLevelView = [[[UIApplication sharedApplication] delegate] window].rootViewController.view;
        int lastDisplayIndex = topLevelView.subviews.count;
        [topLevelView insertSubview: _background.imageUI atIndex:lastDisplayIndex + 1];
        _background.imageUI.hidden = NO;
    }
}

- (BOOL) _allComponentsLoaded {
    
    if(_closeButton == nil){
        return (_background.status == AdComponentStatusCompleted
                && _adArea.status == AdComponentStatusCompleted);
    }
    return (_background.status == AdComponentStatusCompleted
            && _adArea.status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
}

- (void) componentDidFailToLoad: (id) component{
    [self _closeAd];
}

- (void) componentDidReceiveTouch:  (id) component touch: (UITouch*) touch{
    if(component == _closeButton){
        [self _stop];
        return;
    }
    
    if(component == _adArea){
        [self _adClicked:touch];
        return;
    }
}


- (void) _stop {
    NSLog(@"Close button was pressed...");
    [self _closeAd];
    NSString *callback = [_adArea.properties objectForKey:FrameResponseAd_CloseUrl];
    [self.callbackUtil submitRequestToServer:callback];
}

- (void) _adClicked: (UITouch *)touch {
    CGPoint location = [touch locationInView: _adArea.imageUI];
    int x = location.x;
    int y = location.y;
    
    NSString* coordParams = [NSString stringWithFormat:@"&x=%d&y=%d", x, y];
    NSString* targetTypeString = [_adArea.properties objectForKey:FrameResponseAd_TargetType];
    AdTarget targetType = [self toAdTarget : targetTypeString];
    
    if(targetType == AdTargetUrl) {
        //url-based target
        
        NSString* clickTarget = [_adArea.properties objectForKey:FrameResponseAd_ClickTarget];
        AdAction actionType = [self toAdAction : clickTarget];
        
        if (actionType == AdActionHTTP) {
            //just redirect to the ad
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickTarget]];
        } else if (actionType == AdActionDefinedAction || actionType == AdActionExecuteCode) {
            NSString* preExecuteUrl = [[_adArea.properties objectForKey:FrameResponseAd_PreExecuteUrl] stringByAppendingString:coordParams];
            NSString* postExecuteUrl =  [_adArea.properties objectForKey:FrameResponseAd_PostExecuteUrl];
            
            NSString* actionLabel = [self adActionMethodForURLPath:clickTarget];
            NSInteger responseCode;
            NSException* exception = nil;
            
            [self.callbackUtil submitRequestToServer: preExecuteUrl];
            if (actionType == AdActionDefinedAction) {
                @try {
                    [[PlaynomicsMessaging sharedInstance] performActionForLabel:actionLabel];
                    responseCode = 2;
                }
                @catch (NSException* e) {
                    responseCode = -6;
                    exception = e;
                }
            } else {
                @try {
                    [[PlaynomicsMessaging sharedInstance] executeActionOnDelegate:actionLabel];
                    responseCode = 1;
                }
                @catch (NSException *e) {
                    responseCode = -4;
                    exception = e;
                }
            }
            [self callPostAction: postExecuteUrl withException: exception andResponseCode: responseCode];
        }
    } else if (targetType == AdTargetData) {
        //handle rich data
        NSString* preExecuteUrl = [[_adArea.properties objectForKey:FrameResponseAd_PreExecuteUrl] stringByAppendingString:coordParams];
        NSString* postExecuteUrl =  [_adArea.properties objectForKey:FrameResponseAd_PostExecuteUrl];

        NSInteger responseCode;
        NSException* exception = nil;
        NSString* targetData = [_adArea.properties objectForKey:FrameResponseAd_TargetData];
        
        [self.callbackUtil submitRequestToServer: preExecuteUrl];
        
        @try {
            if(_frameDelegate == nil || ![_frameDelegate respondsToSelector:@selector(onClick:)]){
                responseCode = -4;
                NSLog(@"Received a click but could not send the data to the frameDelegate");
            } else {
                NSDictionary* jsonData = [PNUtil deserializeJsonString: targetData];
                [_frameDelegate onClick: jsonData];
                responseCode = 1;
            }
        }
        @catch (NSException *e) {
            exception = e;
            responseCode = -4;
        }
        [self callPostAction: postExecuteUrl withException: exception andResponseCode: responseCode];
    }
    [self _closeAd];
}

- (void) _closeAd {
    [_background hide];
    [self _destroyOrientationObservers];
//    [self _stopExpiryTimer];
}

- (NSString*) adActionMethodForURLPath: (NSString*)urlPath{
    NSArray *comps = [urlPath componentsSeparatedByString:@"://"];
    NSString *resource = [comps objectAtIndex:1];
    return [resource stringByReplacingOccurrencesOfString:@"//" withString:@""];
}

-(void) callPostAction:(NSString*) postUrl withException: (NSException*) exception andResponseCode: (NSInteger) code{
    NSString* fullPostActionUrl;
    if(exception != nil){
        NSString* exceptionMessage = [PNUtil urlEncodeValue: [NSString stringWithFormat:@"%@+%@", exception.name, exception.reason]];
        fullPostActionUrl = [NSString stringWithFormat:@"%@&c=%d&e=%@", postUrl, code, exceptionMessage];
    } else {
        fullPostActionUrl = [NSString stringWithFormat:@"%@&c=%d", postUrl, code];
    }
    [self.callbackUtil submitRequestToServer: fullPostActionUrl];
}   

#pragma mark - Public Interface
- (DisplayResult) start {
    NSString *frameResponseURL =[_adArea.properties objectForKey:FrameResponseAd_ImpressionUrl];
    if (frameResponseURL==nil)
    {
        //this may happen due to broken JSON
        return DisplayResultFailUnknown;
    }
    
    if (_adType == AdColony) {
        [self.callbackUtil submitRequestToServer:frameResponseURL];
        NSLog(@"Returning DisplayAdColony");
        return DisplayAdColony;
    } else {
        NSLog(@"AdType is not AdColony");
    }
    
    [_background display];
    //[self _startExpiryTimer];
    
    [self.callbackUtil submitRequestToServer:frameResponseURL];
    
    if ([self _allComponentsLoaded]) {
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
}

/*
- (void) _startExpiryTimer {
    @try {
        [self _stopExpiryTimer];
        
        _expirationTimer = [[NSTimer scheduledTimerWithTimeInterval:_expirationSeconds target:self selector:@selector(_notifyDelegate) userInfo:nil repeats:NO] retain];
    }
    @catch (NSException *exception) {
        NSLog(@"error: %@", exception.description);
    }
    
}

- (void) _stopExpiryTimer {
    
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

- (void) _notifyDelegate {
    [_delegate refreshFrameWithId:_frameId];
}


- (void) refreshProperties: (NSDictionary *)properties {
    
    // TODO: should we reset all properties, or just the images?
    NSLog(@"refreshProperties called for frameId: %@", _frameId);
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
*/

- (void)sendVideoView {
    if (self.videoViewUrl!=nil) {
        [self.callbackUtil submitRequestToServer:self.videoViewUrl];
    }
}


- (AdAction) toAdAction: (NSString*) actionUrl{
    if(actionUrl == (id)[NSNull null]){
        return AdActionNullTarget;
    }
    if([PNUtil isUrl: actionUrl]){
        return AdActionHTTP;
    }
    if([actionUrl hasPrefix: @"pnx://"]){
        return AdActionExecuteCode;
    }
    if([actionUrl hasPrefix: @"pna://" ]){
        return AdActionDefinedAction;
    }
    return AdActionUnknown;
}

- (AdTarget) toAdTarget: (NSString*) adTargetType{
    if(adTargetType == (id)[NSNull null]){
        return AdTargetUnknown;
    }
    if([adTargetType isEqualToString: @"data"]){
        return AdTargetData;
    }
    if([adTargetType isEqualToString:@"url"]){
        return AdTargetUrl;
    }
    return AdTargetUnknown;
}
@end

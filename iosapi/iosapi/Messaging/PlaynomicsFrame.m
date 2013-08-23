//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame+Exposed.h"
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
    AdType _adType;
    id<PNFrameDelegate> _frameDelegate;
    BOOL _shouldRenderFrame;
}

@synthesize frameId = _frameId;

#pragma mark - Lifecycle/Memory management
- (id) initWithProperties: (NSDictionary *)properties
            forFrameId:(NSString *)frameId
            frameDelegate: (id<PNFrameDelegate>) frameDelegate {
    
    if ((self = [super init])) {
        _frameId = [frameId copy];
        _properties = [properties retain];
        _frameDelegate = frameDelegate;
        
        self.callbackUtil = [[[PlaynomicsCallback alloc] init] autorelease];
        
        [self _initOrientationChangeObservers];
        [self _initAdComponents];
        _shouldRenderFrame = NO;
    }
    return self;
}

- (void) dealloc {
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    [_frameId release];
    _frameDelegate = nil;
    [super dealloc];
}

- (void) _initAdComponents {
    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo] delegate:self];
    
    _adArea = [[BaseAdComponent alloc] initWithProperties:[self _mergeAdInfoProperties] delegate:self];
    
    NSDictionary* closeButtonInfo = [_properties objectForKey:FrameResponseCloseButtonInfo];
    if([BaseAdComponent getImageFromProperties:closeButtonInfo] != nil){
        _closeButton = [[BaseAdComponent alloc] initWithProperties:closeButtonInfo delegate:self];
    }

    
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
    if([self _allComponentsLoaded] && _shouldRenderFrame){
        [self showFrameRenderLogImpression];
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

-(void) showFrameRenderLogImpression{
    UIView *topLevelView = [[[UIApplication sharedApplication] delegate] window].rootViewController.view;
    int lastDisplayIndex = topLevelView.subviews.count;
    [topLevelView insertSubview: _background.imageUI atIndex:lastDisplayIndex + 1];
    _background.imageUI.hidden = NO;
    [_background.imageUI setNeedsDisplay];
    
    NSString *impressionUrl =[_adArea.properties objectForKey:FrameResponseAd_ImpressionUrl];
    [self.callbackUtil submitRequestToServer: impressionUrl];
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
    NSString *callback = [_adArea.properties objectForKey:FrameResponseAd_CloseUrl];
    [self.callbackUtil submitRequestToServer:callback];
    
    [self _closeAd];
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
        }
    } else if (targetType == AdTargetData) {
        //handle rich data
        NSString *preExecuteUrl = [[_adArea.properties objectForKey:FrameResponseAd_PreExecuteUrl] stringByAppendingString:coordParams];
        NSString *postExecuteUrl =  [_adArea.properties objectForKey:FrameResponseAd_PostExecuteUrl];

        NSInteger responseCode;
        NSException *exception = nil;
        NSString *targetData = [_adArea.properties objectForKey:FrameResponseAd_TargetData];
        
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
    [self release];
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
    if (frameResponseURL==nil){
        //this may happen due to broken JSON
        return DisplayResultFailUnknown;
    }
    
    _shouldRenderFrame = YES;
    
    if (_adType == AdColony) {
        [self.callbackUtil submitRequestToServer:frameResponseURL];
        NSLog(@"Returning DisplayAdColony");
        return DisplayAdColony;
    }
    
    if ([self _allComponentsLoaded]) {
        [self showFrameRenderLogImpression];
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
}

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

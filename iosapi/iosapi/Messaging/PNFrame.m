//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "FSNConnection.h"
#import "PNUtil.h"
#import "PNWebView.h"
#import "PNSession.h"
#import "PNImage.h"


@implementation PNFrame {
@private
    UIInterfaceOrientation _currentOrientation;
    id<PlaynomicsFrameDelegate> _frameDelegate;
    BOOL _shouldRenderFrame;
    BOOL _frameRenderReady;
    PNSession *_session;
}

@synthesize parentView = _parentView;
@synthesize backgroundInfo = _backgroundInfo;
@synthesize backgroundDimensions = _backgroundDimensions;
@synthesize backgroundImageUrl = _backgroundImageUrl;
@synthesize adInfo = _adInfo;
@synthesize adDimensions = _adDimensions;
@synthesize adType = _adType;
@synthesize creativeType = _creativeType;
@synthesize adTag = _adTag;
@synthesize primaryImageUrl = _primaryImageUrl;
@synthesize rolloverImageUrl = _rolloverImageUrl;
@synthesize tooltipText = _tooltipText;
@synthesize clickTarget = _clickTarget;
@synthesize clickTargetType = _clickTargetType;
@synthesize clickTargetData = _clickTargetData;
@synthesize preClickUrl = _preClickUrl;
@synthesize postClickUrl = _postClickUrl;
@synthesize impressionUrl = _impressionUrl;
@synthesize flagUrl = _flagUrl;
@synthesize closeUrl = _closeUrl;
@synthesize viewUrl = _viewUrl;
@synthesize closeButtonInfo = _closeButtonInfo;
@synthesize closeButtonImageUrl = _closeButtonImageUrl;
@synthesize closeButtonDimensions = _closeButtonDimensions;
@synthesize adObject = _adObject;


#pragma mark - Lifecycle/Memory management
- (id) initWithProperties: (NSDictionary *)adResponse
            frameDelegate: (id<PlaynomicsFrameDelegate>) frameDelegate
                  session: (PNSession *) session {
    
    if (self = [super init]) {
        _session = session;
        _frameDelegate = frameDelegate;
        _shouldRenderFrame = NO;
        _frameRenderReady = NO;
        [self _initOrientationChangeObservers];
        [self _parseAdResponse:adResponse];
        
        if (_adType == WebView) {
            _adObject = [[PNWebView alloc] initWithFrameData:self];
        } else if (_adType == Image) {
            _adObject = [[PNImage alloc] initWithFrameData:self];
        }
    }
    return self;
}

- (void) dealloc {
    _parentView = nil;
    _frameDelegate = nil;
    [_backgroundImageUrl release];
    [_primaryImageUrl release];
    [_rolloverImageUrl release];
    [_tooltipText release];
    [_impressionUrl release];
    [_flagUrl release];
    [_closeUrl release];
    [_clickTarget release];
    [_clickTargetType release];
    [_clickTargetData release];
    [_preClickUrl release];
    [_postClickUrl release];
    [_creativeType release];
    [_adTag release];
    [_viewUrl release];
    [_closeButtonImageUrl release];
    _session = nil;
    [super dealloc];
}

-(void) _parseAdResponse:(NSDictionary*) adResponse {
    // Get the background details, which are in the key "b" and is a dictionary of data
    _backgroundInfo = [adResponse objectForKey:FrameResponseBackgroundInfo];
    _backgroundDimensions = [self getViewDimensions:_backgroundInfo];
    _backgroundImageUrl = [[self getImageFromProperties:_backgroundInfo] retain];
    
    NSDictionary *adLocationInfo = [adResponse objectForKey:FrameResponseAdLocationInfo];
    _adDimensions = [self getViewDimensions:adLocationInfo];
    
    NSArray *adFrameResponse = [adResponse objectForKey:FrameResponseAds];
    if (adFrameResponse==nil || adFrameResponse.count==0){
        _adInfo = nil;
    } else {
        _adInfo = [adFrameResponse objectAtIndex:0];
        _primaryImageUrl = [[self getImageFromProperties:_adInfo] retain];
        _rolloverImageUrl = [[_adInfo objectForKey:FrameResponseAd_RolloverImage] retain];
        _tooltipText = [[_adInfo objectForKey:FrameResponseAd_ToolTipText] retain];
        _impressionUrl = [[_adInfo objectForKey:FrameResponseAd_ImpressionUrl] retain];
        _flagUrl = [[_adInfo objectForKey:FrameResponseAd_FlagUrl] retain];
        _closeUrl = [[_adInfo objectForKey:FrameResponseAd_CloseUrl] retain];
        
        _clickTargetType = [[_adInfo objectForKey:FrameResponseAd_TargetType] retain];
        _clickTarget = [[_adInfo objectForKey:FrameResponseAd_ClickTarget] retain];
        _preClickUrl = [[_adInfo objectForKey:FrameResponseAd_PreExecuteUrl] retain];
        _postClickUrl =  [[_adInfo objectForKey:FrameResponseAd_PostExecuteUrl] retain];
        _clickTargetData = [[_adInfo objectForKey:FrameResponseAd_TargetData] retain];
        
        NSString* adType = [_adInfo objectForKey:FrameResponseAd_AdType];
        if (adType) {
            if ([adType isEqualToString:@"html"]) {
                _adType = WebView;
                _creativeType = [[_adInfo objectForKey:FrameResponseAd_CreativeType] retain];
                _adTag = [[_adInfo objectForKey:FrameResponseAd_AdTag] retain];
            } else if ([adType isEqualToString:@"video"]) {
                if ([[_adInfo objectForKey:FrameResponseAd_AdProvider] isEqualToString:@"AdColony"]) {
                    NSLog(@"Setting ad type to AdColony");
                    _adType = AdColony;
                } else {
                    _adType = Video;
                }
                _viewUrl = [[_adInfo objectForKey:FrameResponseAd_VideoViewUrl] retain];
            } else if ([adType isEqualToString:@"image"]) {
                _adType = Image;
            } else {
                _adType = AdUnknown;
                NSLog(@"Encountered Unknown AdType %@", adType);
            }
        } else {
            _adType = Image;
        }
    }
    
    _closeButtonInfo = [adResponse objectForKey:FrameResponseCloseButtonInfo];
    _closeButtonImageUrl = [[self getImageFromProperties:_closeButtonInfo] retain];
    if (_closeButtonImageUrl != nil) {
        _closeButtonDimensions = [self getViewDimensions:_closeButtonInfo];
    }
}


#pragma mark "Parse Location"
-(PNViewDimensions) getViewDimensions:(NSDictionary*) componentInfo {
    float height = [self getFloatValue:[componentInfo objectForKey:FrameResponseHeight]];
    float width = [self getFloatValue:[componentInfo objectForKey:FrameResponseWidth]];
    
    NSDictionary *coordinateProps = [self extractCoordinateProps:componentInfo];
    float x = [self getFloatValue:[coordinateProps objectForKey:FrameResponseXOffset]];
    float y = [self getFloatValue:[coordinateProps objectForKey:FrameResponseYOffset]];
    
    PNViewDimensions dimensions = {.width = width, .height = height, .x = x, .y = y};
    return dimensions;
}

-(NSDictionary*) extractCoordinateProps:(NSDictionary*) componentInfo {
    // This is dumb, but the reason for this if statement is because ad and close components
    // both have the size and offset locations in the same dictionary whereas the background
    // component has the coordinates in a sub-dictionary called 'l' for landscape mode and
    // 'p' for portrait mode. This is also because the ad and close components are offsets to
    // the background image whereas the background is just a raw location
    if ([componentInfo objectForKey:FrameResponseBackground_Landscape] == nil) {
        return componentInfo;
    }
    
    // By default, return portrait
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return [componentInfo objectForKey:FrameResponseBackground_Portrait];
    } else if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        return [componentInfo objectForKey:FrameResponseBackground_Landscape];
    } else {
        return [componentInfo objectForKey:FrameResponseBackground_Portrait];
    }
}

-(float) getFloatValue:(NSNumber*) n {
    @try {
        return [n floatValue];
    } @catch (NSException * exception) {
        //
    }
    return 0;
}

-(NSString*) getImageFromProperties: (NSDictionary*) properties{
    NSString* imageUrl = [properties objectForKey:FrameResponseImageUrl];
    if(imageUrl == nil || imageUrl == (id)[NSNull null] ){
        return nil;
    }
    return imageUrl;
}


#pragma mark - Orientation handlers
-(void) _initOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

-(void) _destroyOrientationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

-(void) _deviceOrientationDidChange: (NSNotification *)notification {
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (_currentOrientation == orientation) {
        return;
    }
    _currentOrientation = orientation;
    NSLog(@"Orientation changed to: %i", orientation);
    //[_background renderComponent];
}

-(void) render {
    [_session pingUrlForCallback: _impressionUrl];
    [_adObject renderAdInView:_parentView];
}

#pragma mark - Ad component click handlers
-(void) didLoad {
    _frameRenderReady = YES;
    
    if(_shouldRenderFrame) {
        [self render];
    }
}

-(void) didFailToLoadWithError: (NSError*) error {
    NSLog(@"Frame failed to load due to error: %@", error.debugDescription);
}

-(void) didFailToLoadWithException: (NSException*) exception {
    NSLog(@"Frame failed to load due to exception: %@", exception.debugDescription);
}

-(void) adClosed {
    [_session pingUrlForCallback: _closeUrl];
    [self _destroyOrientationObservers];
}

-(void) adClicked {
    AdTarget targetType = [self toAdTarget : _clickTargetType];
    
    if(targetType == AdTargetUrl) {
        //url-based target
        AdAction actionType = [self toAdAction : _clickTarget];
        if (actionType == AdActionHTTP) {
            //just redirect to the ad
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_clickTarget]];
        }
    } else if (targetType == AdTargetData) {
        //handle rich data
        NSInteger responseCode;
        NSException* exception = nil;
        
        [_session pingUrlForCallback: _preClickUrl];
        @try {
            if(_frameDelegate == nil || ![_frameDelegate respondsToSelector:@selector(onClick:)]){
                responseCode = -4;
                NSLog(@"Received a click but could not send the data to the frameDelegate");
            } else {
                NSDictionary* jsonData = [PNUtil deserializeJsonString: _clickTargetData];
                [_frameDelegate onClick: jsonData];
                responseCode = 1;
            }
        }
        @catch (NSException *e) {
            exception = e;
            responseCode = -4;
        }
        [self callPostAction: _postClickUrl withException: exception andResponseCode: responseCode];
    }
}

-(NSString*) adActionMethodForURLPath: (NSString*)urlPath{
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
    [_session pingUrlForCallback: fullPostActionUrl];
}


-(AdAction) toAdAction:(NSString*) actionUrl {
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

-(AdTarget) toAdTarget:(NSString*) adTargetType {
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

#pragma mark - Public Interface
-(DisplayResult) startInView:(UIView*) parentView {
    if (_impressionUrl==nil){
        //this may happen due to broken JSON
        return DisplayResultFailUnknown;
    }
    
    _shouldRenderFrame = YES;
    _parentView = parentView;
    
    if (_adType == AdColony) {
        [_session pingUrlForCallback: _impressionUrl];
        NSLog(@"Returning DisplayAdColony");
        return DisplayAdColony;
    }
    
    if (_frameRenderReady) {
        [self render];
        return DisplayResultDisplayed;
    } else {
        return DisplayResultDisplayPending;
    }
}

-(void) sendVideoView {
    if (_viewUrl!=nil) {
        [_session pingUrlForCallback: _viewUrl];
    }
}

@end
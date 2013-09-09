//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PNFrame.h"
#import "PNUtil.h"
#import "PNWebView.h"
#import "PNSession.h"
#import "PNImage.h"
#import "PNFrameResponse.h"

@implementation PNFrame {
@private
    UIInterfaceOrientation _currentOrientation;
    id<PlaynomicsFrameDelegate> _frameDelegate;
    BOOL _shouldRenderFrame;
    BOOL _frameRenderReady;
    PNSession *_session;
    PNFrameResponse *_response;
    PNMessaging *_messaging;
}

@synthesize parentView = _parentView;
@synthesize adObject = _adObject;
@synthesize state;

#pragma mark - Lifecycle/Memory management
- (id) initWithFrameId: (NSString *) frameId session: (PNSession *) session messaging: (PNMessaging *) messaging{
    
    if (self = [super init]) {
        self.state = PNFrameStateNotLoaded;
        _session = session;
        _messaging = messaging;
        _shouldRenderFrame = NO;
        _frameRenderReady = NO;
        _frameId = [frameId retain];
    }
    return self;
}

- (void) dealloc {

    [_frameId release];
    
    _parentView = nil;
    _frameDelegate = nil;
    _session = nil;
    [super dealloc];
}

-(void) updateFrameResponse:(PNFrameResponse *)frameResponse{
    _shouldRenderFrame = NO;
    _frameRenderReady = NO;
    
    if(_adObject){
        [_adObject release];
    }

    if(_response){
        [_response release];
    }
    _response = [frameResponse retain];

    if (_response.adType == WebView) {
        _adObject = [[PNWebView alloc] initWithResponse: _response delegate:self];
    } else if (_response.adType == Image) {
        _adObject = [[PNImage alloc] initWithResponse: _response delegate:self];
    }
    
    [self _initOrientationChangeObservers];
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
    [_session pingUrlForCallback: _response.impressionUrl];
    [_adObject renderAdInView:_parentView];
}

#pragma mark - Ad component click handlers
-(void) didLoad {
    _frameRenderReady = YES;
    
    if(_shouldRenderFrame) {
        [self render];
    }
}

-(void) didFailToLoad{
    
}

-(void) didFailToLoadWithError: (NSError*) error {
    NSLog(@"Frame failed to load due to error: %@", error.debugDescription);
}

-(void) didFailToLoadWithException: (NSException*) exception {
    NSLog(@"Frame failed to load due to exception: %@", exception.debugDescription);
}

-(void) adClosed {
    [_session pingUrlForCallback: _response.closeUrl];
    [self _destroyOrientationObservers];
    //refresh the frame when the ad has been clicked
    [_messaging fetchDataForFrame:_frameId];
}

-(void) adClicked {
    AdTarget targetType = [self toAdTarget : _response.clickTargetType];
    
    if(targetType == AdTargetUrl) {
        //url-based target
        AdAction actionType = [self toAdAction : _response.clickTarget];
        if (actionType == AdActionHTTP) {
            // If we have a WebView, the click target will be the Playnomics click tracking URL
            if (_response.adType == WebView) {
                [_session pingUrlForCallback:_response.clickTarget];
            } else {
                //just redirect to the ad
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_response.clickTarget]];
            }
        }
    } else if (targetType == AdTargetData) {
        //handle rich data
        NSInteger responseCode;
        NSException* exception = nil;
        
        [_session pingUrlForCallback: _response.preClickUrl];
        @try {
            if(_frameDelegate == nil || ![_frameDelegate respondsToSelector:@selector(onClick:)]){
                responseCode = -4;
                NSLog(@"Received a click but could not send the data to the frameDelegate");
            } else {
                NSDictionary* jsonData = [PNUtil deserializeJsonString: _response.clickTargetData];
                [_frameDelegate onClick: jsonData];
                responseCode = 1;
            }
        }
        @catch (NSException *e) {
            exception = e;
            responseCode = -4;
        }
        [self callPostAction: _response.postClickUrl withException: exception andResponseCode: responseCode];
    }
    //refresh the frame when the ad has been clicked
    [_messaging fetchDataForFrame:_frameId];
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
-(void) showInView:(UIView*) parentView withDelegate:(id<PlaynomicsFrameDelegate>) delegate {
    _delegate = delegate;
    _shouldRenderFrame = YES;
    _parentView = parentView;
    
    if (_frameRenderReady) {
        [self render];
    }
}


@end
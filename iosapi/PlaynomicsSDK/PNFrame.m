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
    PNSession *_session;
    PNFrameResponse *_response;
    PNMessaging *_messaging;
}

@synthesize parentView = _parentView;
@synthesize adView = _adView;
@synthesize state;

#pragma mark - Lifecycle/Memory management
- (id) initWithFrameId: (NSString *) frameId
               session: (PNSession *) session
             messaging: (PNMessaging *) messaging{
    
    if ((self = [super init])) {
        self.state = PNFrameStateNotLoaded;
        _session = session;
        _messaging = messaging;
        _shouldRenderFrame = NO;
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
    
    if(_adView){
        [_adView release];
    }

    if(_response){
        [_response release];
    }
    _response = [frameResponse retain];

    if (_response.adType == WebView) {
        _adView = [[PNWebView alloc] initWithResponse: _response delegate:self];
    } else if (_response.adType == Image) {
        _adView = [[PNImage alloc] initWithResponse: _response delegate:self];
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
    [PNLogger log:PNLogLevelDebug format: @"Orientation changed to: %i", orientation];
    //[_background renderComponent];
}

-(void) render {
    [_session pingUrlForCallback: _response.impressionUrl];
    [_adView renderAdInView:_parentView];
    if(_frameDelegate && [_frameDelegate respondsToSelector:@selector(onShow:)]){
        [_frameDelegate onShow: [_response getJSONTargetData]];
    }
}

#pragma mark - Ad component click handlers
-(void) didLoad {
    self.state = PNFrameStateLoadingComplete;
    if(_shouldRenderFrame) {
        [self render];
    }
}

-(void) didFailToLoad{
    [PNLogger log: PNLogLevelWarning format:@"Frame failed to load."];
    [self handleFailure];
}

-(void) didFailToLoadWithError: (NSError*) error {
    [PNLogger log: PNLogLevelWarning error:error format:@"Frame failed to load due to error."];
    [self handleFailure];
}

-(void) didFailToLoadWithException: (NSException*) exception {
    [PNLogger log: PNLogLevelWarning exception:exception format:@"Frame failed to load due to exception."];
    [self handleFailure];
}

-(void) handleFailure{
    self.state = PNFrameStateLoadingFailed;
    if(_frameDelegate && [_frameDelegate respondsToSelector:@selector(onDidFailToRender)]){
        [_frameDelegate onDidFailToRender];
    }
}

-(void) adClosed:(BOOL) closedByUser {
    if(closedByUser){
        [_session pingUrlForCallback: _response.closeUrl];
        
        if(_frameDelegate && [_frameDelegate respondsToSelector:@selector(onClose:)]){
            //notify the delegate
            [_frameDelegate onClose: [_response getJSONTargetData]];
        }
    }
    
    [self _destroyOrientationObservers];
    //refresh the frame when the ad has been closed
    [_messaging fetchDataForFrame:_frameId];
}

-(void) adClicked {
    if(_response.targetType == AdTargetUrl) {
        //url-based target
        if (_response.actionType == AdActionHTTP) {
            // If we have a WebView, the click target will be the Playnomics click tracking URL
            if (_response.adType == WebView) {
                [_session pingUrlForCallback:_response.clickTarget];
            } else {
                //just redirect to the ad
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_response.clickTarget]];
            }
        }
    } else if (_response.targetType == AdTargetData) {
        //handle rich data
        NSInteger responseCode;
        NSException* exception = nil;
        
        [_session pingUrlForCallback: _response.preClickUrl];
        @try {
            if(_frameDelegate == nil || ![_frameDelegate respondsToSelector:@selector(onTouch:)]){
                responseCode = -4;
                [PNLogger log:PNLogLevelDebug format:@"Received a click but could not send the data to the frameDelegate"];
            } else {
                NSDictionary* jsonData = [PNUtil deserializeJsonString: _response.clickTargetData];
                [_frameDelegate onTouch: jsonData];
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

#pragma mark - Public Interface
-(void) showInView:(UIView*) parentView withDelegate:(id<PlaynomicsFrameDelegate>) delegate {
    _frameDelegate = delegate;
    _shouldRenderFrame = YES;
    _parentView = parentView;
    
    if(self.state == PNFrameStateLoadingFailed && _frameDelegate){
        [_frameDelegate onDidFailToRender];
    } else if (self.state == PNFrameStateLoadingComplete) {
        [self render];
    }
}

- (void) hide{
    [_adView hide];
}
@end

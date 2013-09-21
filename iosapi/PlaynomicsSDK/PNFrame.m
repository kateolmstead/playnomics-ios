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
    BOOL _statusBar;
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
    [_adView rotate];
}

-(void) render {
    [_session pingUrlForCallback: _response.impressionUrl];
    [_adView renderAdInView:_parentView];
    
    _statusBar = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden : YES];
    if(_frameDelegate && [_frameDelegate respondsToSelector:@selector(onShow:)]){
        [_frameDelegate onShow: [_response getJSONTargetData]];
    }
    
}

-(void) reloadFrame{
    _shouldRenderFrame = NO;
    [_messaging fetchDataForFrame:_frameId];
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

-(void) didFailToLoadWithError: (NSError *) error {
    [PNLogger log: PNLogLevelWarning error:error format:@"Frame failed to load due to error."];
    [self handleFailure];
}

-(void) didFailToLoadWithException: (NSException *) exception {
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
    [[UIApplication sharedApplication] setStatusBarHidden : _statusBar];
    //refresh the frame when the ad has been closed
    [self reloadFrame];
}

-(void) adClicked {
    if(_response.clickUrl){
        [_session pingUrlForCallback:_response.clickUrl];
    }
    
    if(_response.targetType == AdTargetUrl ) {
        //url-based target
        if (_response.actionType == AdActionHTTP
            && _response.clickTargetUrl
            && _response.clickTargetUrl != (id)[NSNull null] ) {

            NSURL *url = [NSURL URLWithString:_response.clickTargetUrl];
            if([[UIApplication sharedApplication] canOpenURL:url]){
                 [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    
    //always notify the delegate that there was a touch event
    if(_frameDelegate && [_frameDelegate respondsToSelector:@selector(onTouch:)]){
        [_frameDelegate onTouch: [_response getJSONTargetData]];
    }
    //refresh the frame when the ad has been clicked
    
    [[UIApplication sharedApplication] setStatusBarHidden : _statusBar];
    [self reloadFrame];
}

#pragma mark - Public Interface
-(void) showInView:(UIView *) parentView
      withDelegate:(id<PlaynomicsFrameDelegate>) delegate {
    
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

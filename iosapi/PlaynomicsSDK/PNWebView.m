//
//  PNWebView.m
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import "PNWebView.h"

@implementation PNWebView {
@private
    CGRect _backgroundDimensions;
    PNViewComponent *_closeButton;
    id<PNFrameDelegate> _delegate;
    PNFrameResponse *_response;
}

@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
-(id) initWithResponse:(PNFrameResponse *) response delegate:(id<PNFrameDelegate>) delegate {
    if (self = [super init]) {
        [self setUserInteractionEnabled: YES];
        [self setExclusiveTouch: YES];
        _response = [response retain];
        _delegate = delegate;
        
        [super setDelegate:self];
        
        if(_response.htmlContent != nil && _response.htmlContent != (id)[NSNull null]){
            _status = AdComponentStatusPending;
            
            if (_response.fullscreen && [_response.fullscreen boolValue] == YES) {
                [super setFrame:[[UIScreen mainScreen] bounds]];
            } else {
                [super setFrame:_backgroundDimensions];
            }
            
            // Close button should only be non-nil for 3rd party ads
            if(_response.closeButtonImageUrl != nil){
                CGRect dimensions = [self getFrameForCloseButton];
                _closeButton = [[PNViewComponent alloc] initWithDimensions:dimensions delegate:self image:_response.closeButtonImageUrl];
                if(_closeButton !=  nil){
                    [self addSubview:_closeButton];
                }
            }
            
            self.scrollView.scrollEnabled = NO;
            self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [self loadHTMLString:_response.htmlContent baseURL:nil];
        }
    }
    
    return self;
}

-(CGRect) getFrameForCloseButton{
    //always place the close button in the top right of the web view
    return CGRectMake([super frame].origin.x + [super frame].size.width - _response.closeButtonDimensions.size.width,
                      [super frame].origin.y,
                      _response.closeButtonDimensions.size.width,
                      _response.closeButtonDimensions.size.height);
}

-(void) renderAdInView:(UIView *)parentView {
    int lastDisplayIndex = parentView.subviews.count;
    [parentView insertSubview:self atIndex:lastDisplayIndex+1];
}

-(void) hide{
    [self removeFromSuperview];
    [_delegate adClosed:NO];
}

-(void) rotate{
    if(_closeButton){
        _closeButton.frame = [self getFrameForCloseButton];
    }
}

-(void)dealloc{
    _delegate = nil;
    [_response release];
    [_closeButton release];
    [super dealloc];
}

#pragma mark "Helper Methods"
// Returns TRUE if all instantiated components are done loading. FALSE otherwise
- (BOOL) _allComponentsLoaded {
    return _status == AdComponentStatusCompleted && _closeButton.status == AdComponentStatusCompleted;
}

-(void) _closeAd {
    [self removeFromSuperview];
    [_delegate adClosed:YES];
}

#pragma mark "Delegate Handlers"
-(BOOL) webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request
 navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *URL = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([URL.scheme isEqualToString:FrameResponseAd_WebViewClickProtocol]) {
            [PNLogger log:PNLogLevelDebug format:@"PN Web View was clicked and the type of click (host) is %@", URL.host ];
            if ([URL.host isEqualToString:FrameResponseAd_WebViewAdClosed]) {
                [PNLogger log:PNLogLevelDebug format:@"PN Web View Close button was clicked"];
                [self _closeAd];
                return NO;
            } else if ([URL.host isEqualToString:FrameResponseAd_WebViewAdClicked]) {
                [PNLogger log:PNLogLevelDebug format:@"PN Web View Ad was clicked"];
                [self removeFromSuperview];
                [_delegate adClicked];
                return NO;
            }
        } else {
            [PNLogger log:PNLogLevelDebug format:@"Web View was clicked"];
            [[UIApplication sharedApplication] openURL:URL];
            [self removeFromSuperview];
            [_delegate adClicked];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _status = AdComponentStatusCompleted;
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
    [_delegate didLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _status = AdComponentStatusError;
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load the webview for HTML Content %@", _response.htmlContent];
    [_delegate didFailToLoadWithError:error];
}
// Only notify the delegate if all the components have been loaded successfully
- (void) componentDidLoad {
    if([self _allComponentsLoaded]){
        [_delegate didLoad];
    }
}

- (void)componentDidFailToLoad{
    [self removeFromSuperview];
    [_delegate didFailToLoad];
}

// Close the ad in case of an error and notify the delegate
-(void) componentDidFailToLoadWithError: (NSError*) error {
    [self removeFromSuperview];
    [_delegate didFailToLoadWithError:error];
}

// Close the ad in case of an exception and notify the delegate
-(void) componentDidFailToLoadWithException: (NSException*) exception {
    [self removeFromSuperview];
    [_delegate didFailToLoadWithException:exception];
}

// If the close button component was clicked, close the ad and notify the delegate
// If the ad was clicked, also close the ad and notify the delegate
-(void) component: (id) component didReceiveTouch: (UITouch*) touch {
    if (component == _closeButton) {
        [PNLogger log: PNLogLevelDebug format: @"Close button was pressed..."];
        [self _closeAd];
    }
}

@end

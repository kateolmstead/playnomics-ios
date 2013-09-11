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
    PNViewDimensions _backgroundDimensions;
    id<PNFrameDelegate> _delegate;
    PNFrameResponse *_response;
}

@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
-(id) initWithResponse:(PNFrameResponse *) response delegate:(id<PNFrameDelegate>) delegate {
    if (self = [super init]) {
        _response = [response retain];
        _delegate = delegate;
        
        [super setDelegate:self];
        
        if(_response.adTag != nil && _response.adTag != (id)[NSNull null] ){
            _status = AdComponentStatusPending;
            [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_response.adTag]]];
        }
    }
    
    return self;
}

-(void) renderAdInView:(UIView *)parentView {
    if (_response.creativeType && [_response.creativeType isEqualToString:@"banner"]) {
        [super setFrame:CGRectMake(_backgroundDimensions.x,
                                   _backgroundDimensions.y,
                                   _backgroundDimensions.width,
                                   _backgroundDimensions.height)];
    } else {
        [super setFrame:parentView.bounds];
    }
    
    int lastDisplayIndex = parentView.subviews.count;
    [parentView insertSubview:self atIndex:lastDisplayIndex+1];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - 30,
                              self.frame.origin.y,
                              30, 30);
    [button addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
}

-(void) hide{
    [self removeFromSuperview];
     [_delegate adClosed:NO];
}

-(void)dealloc{
    _delegate = nil;
    [_response release];
    [super dealloc];
}

-(void) closeButtonClicked {
    [self removeFromSuperview];
    [_delegate adClosed:YES];
}

#pragma mark "Delegate Handlers"
-(BOOL) webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request
 navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *URL = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:URL];
        [self removeFromSuperview];
        [_delegate adClicked];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _status = AdComponentStatusCompleted;
    [_delegate didLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _status = AdComponentStatusError;
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load the webview for url %@", _response.adTag];
    [_delegate didFailToLoadWithError:error];
}

@end

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
    PNFrame *_frame;
}

@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
-(id) initWithFrameData:(PNFrame*) frame {
    if (self = [super init]) {
        _frame = frame;
        [super setDelegate:self];
        
        if(_frame.adTag != nil && _frame.adTag != (id)[NSNull null] ){
            _status = AdComponentStatusPending;
            [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_frame.adTag]]];
        }
    }
    
    return self;
}

-(void) renderAdInView:(UIView *)parentView {
    if (_frame.creativeType && [_frame.creativeType isEqualToString:@"banner"]) {
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

-(void)dealloc{
    _frame = nil;
    [super dealloc];
}

-(void) closeButtonClicked {
    [self removeFromSuperview];
    [_frame adClosed];
}

#pragma mark "Delegate Handlers"
-(BOOL) webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request
 navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *URL = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:URL];
        [self removeFromSuperview];
        [_frame adClicked];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _status = AdComponentStatusCompleted;
    [_frame didLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _status = AdComponentStatusError;
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load the webview for url %@", _frame.adTag];
    NSLog(@"Web View failed to load with error %@",error.debugDescription);
    [_frame didFailToLoadWithError:error];
}

@end

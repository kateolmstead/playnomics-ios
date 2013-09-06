//
//  PNWebView.m
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import "PNWebView.h"
#import "FSNConnection.h"

@implementation PNWebView {
@private
    PNViewDimensions _backgroundDimensions;
    NSString *_creativeType;
}

@synthesize frameDelegate = _frameDelegate;
@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
-(id) createWithMessageAndDelegate:(PlaynomicsFrame*) adDetails {
    if (self = [super init]) {
        _frameDelegate = adDetails;
        _creativeType = adDetails.creativeType;
        [super setDelegate:self];
        
        if(adDetails.adTag != nil && adDetails.adTag != (id)[NSNull null] ){
            _status = AdComponentStatusPending;
            [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:adDetails.adTag]]];
        }
    }
    
    return self;
}

-(void) renderAdInView:(UIView *)parentView {
    NSLog(@"Window2=%@",NSStringFromCGRect(parentView.bounds));
    if (_creativeType && [_creativeType isEqualToString:@"banner"]) {
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
    NSLog(@"Rendering close button at %@",NSStringFromCGRect(button.frame));
    [button addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
}

-(void)dealloc{
    _frameDelegate = nil;
    [super dealloc];
}

-(void) closeButtonClicked {
    [self removeFromSuperview];
    [self.frameDelegate adClosed];
}

#pragma mark "Delegate Handlers"
-(BOOL) webView:(UIWebView*) webView shouldStartLoadWithRequest:(NSURLRequest *) request
 navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *URL = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:URL];
        [self removeFromSuperview];
        [self.frameDelegate adClicked];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _status = AdComponentStatusCompleted;
    [self.frameDelegate didLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _status = AdComponentStatusError;
    NSLog(@"Web View failed to load with error %@",error.debugDescription);
    [self.frameDelegate didFailToLoadWithError:error];
}

@end

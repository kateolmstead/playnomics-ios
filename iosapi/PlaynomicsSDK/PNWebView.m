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
    PNViewComponent *_closeButton;
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
            _closeButton = [PNViewComponent alloc];
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
    
    PNViewDimensions closeButtonDimensions = {
        .width = self.frame.origin.x + self.frame.size.width - 30,
        .height = self.frame.origin.y,
        .x = 30,
        .y = 30
    };
    [_closeButton initWithDimensions:closeButtonDimensions
                            delegate:self
                               image:@"rounded-close-button-30x30"];
    [self addSubview:_closeButton];
    
    int lastDisplayIndex = parentView.subviews.count;
    [parentView insertSubview:self atIndex:lastDisplayIndex+1];
}

-(void)dealloc{
    _frame = nil;
    [_closeButton release];
    [super dealloc];
}

-(void) closeAd {
    NSLog(@"Close button was pressed...");
    [self removeFromSuperview];
    [_frame adClosed];
}

- (BOOL) _allComponentsLoaded {
    return (_status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
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
    if([self _allComponentsLoaded]){
        [_frame didLoad];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _status = AdComponentStatusError;
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load the webview for url %@", _frame.adTag];
    NSLog(@"Web View failed to load with error %@",error.debugDescription);
    [_frame didFailToLoadWithError:error];
}

// Only notify the delegate if all the components have been loaded successfully
- (void) componentDidLoad {
    if([self _allComponentsLoaded]){
        [_frame didLoad];
    }
}

- (void)componentDidFailToLoad{
    [self closeAd];
    [_frame didFailToLoad];
}

// Close the ad in case of an error and notify the delegate
-(void) componentDidFailToLoadWithError: (NSError*) error {
    [self closeAd];
    [_frame didFailToLoadWithError:error];
}

// Close the ad in case of an exception and notify the delegate
-(void) componentDidFailToLoadWithException: (NSException*) exception {
    [self closeAd];
    [_frame didFailToLoadWithException:exception];
}

// If the close button component was clicked, close the ad and notify the delegate
// If the ad was clicked, also close the ad and notify the delegate
-(void) component: (id) component didReceiveTouch: (UITouch*) touch {
    [self closeAd];
}

@end

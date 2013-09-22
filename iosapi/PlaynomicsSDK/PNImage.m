//
//  PNImage.m
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import "PNImage.h"
#import "PNViewComponent.h"
#import "PNFrame.h"

@implementation PNImage {
@private
    PNViewComponent* _background;
    PNViewComponent* _adArea;
    PNViewComponent* _closeButton;
    PNFrameResponse* _response;
    id<PNFrameDelegate> _delegate;
}
#pragma mark - Lifecycle/Memory management
-(id) initWithResponse:(PNFrameResponse *) response delegate:(id<PNFrameDelegate>) delegate {
    
    self = [super init];
    
    _response = [response retain];
    _delegate = delegate;
    
    _background = [[PNViewComponent alloc] initWithDimensions:_response.backgroundDimensions delegate:self image:_response.backgroundImageUrl];
    _adArea = [[PNViewComponent alloc] initWithDimensions:_response.adDimensions delegate:self image:_response.primaryImageUrl];
    
    if(_response.closeButtonType == CloseButtonNative && _response.closeButtonImageUrl != nil){
        _closeButton = [[PNViewComponent alloc] initWithDimensions:_response.closeButtonDimensions delegate:self image:_response.closeButtonImageUrl];
    }
    
    [_background addSubComponent:_adArea];
    if(_closeButton !=  nil){
        [_background addSubComponent:_closeButton];
    }
    _background.hidden = YES;
    
    return self;
}

-(void) dealloc {
    [_response release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    _delegate = nil;
    [super dealloc];
}

#pragma mark "Public Interface"
-(void) renderAdInView:(UIView*) parentView {
    int lastDisplayIndex = parentView.subviews.count;
    [parentView insertSubview: _background atIndex:lastDisplayIndex + 1];
    _background.hidden = NO;
    [_background setNeedsDisplay];
}


- (void) hide{
    [self closeAd];
    [_delegate adClosed: NO];
}

-(void) rotate{
    _background.frame = [_response backgroundDimensions];
}

#pragma mark "Helper Methods"
// Returns TRUE if all instantiated components are done loading. FALSE otherwise
- (BOOL) _allComponentsLoaded {
    if(_closeButton == nil){
        return (_background.status == AdComponentStatusCompleted
                && _adArea.status == AdComponentStatusCompleted);
    }
    return (_background.status == AdComponentStatusCompleted
            && _adArea.status == AdComponentStatusCompleted
            && _closeButton.status == AdComponentStatusCompleted);
}

#pragma mark "Delegate Handlers"

// Hide the background and since all other components are attached to the background,
// everything else will also be hidden
-(void) closeAd{
    [_background hide];
}

// Only notify the delegate if all the components have been loaded successfully
- (void) componentDidLoad {
    if([self _allComponentsLoaded]){
        [_delegate didLoad];
    }
}

- (void)componentDidFailToLoad{
    [self closeAd];
    [_delegate didFailToLoad];
}

// Close the ad in case of an error and notify the delegate
-(void) componentDidFailToLoadWithError: (NSError *) error {
    [self closeAd];
    [_delegate didFailToLoadWithError:error];
}

// Close the ad in case of an exception and notify the delegate
-(void) componentDidFailToLoadWithException: (NSException *) exception {
    [self closeAd];
    [_delegate didFailToLoadWithException:exception];
}

// If the close button component was clicked, close the ad and notify the delegate
// If the ad was clicked, also close the ad and notify the delegate
-(void) component: (id) component didReceiveTouch: (UITouch*) touch {
    if (component == _closeButton) {
        [PNLogger log:PNLogLevelVerbose format:@"Close button was pressed on PNImage"];
        [self closeAd];
        [_delegate adClosed: YES];
    } else if (component == _adArea) {
        CGPoint location = [touch locationInView: _adArea];
        int x = location.x;
        int y = location.y;
        [PNLogger log:PNLogLevelVerbose format:@"Ad area was clicked on at location %d,%d", x, y];
        [self closeAd];
        [_delegate adClicked];
    }
}

@end

//
//  PNImage.m
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import "PNImage.h"
#import "PNViewComponent.h"
#import "FSNConnection.h"
#import "PNFrame.h"

@implementation PNImage {
@private
    PNViewComponent* _background;
    PNViewComponent* _adArea;
    PNViewComponent* _closeButton;
    PNFrame* _frame;
}
#pragma mark - Lifecycle/Memory management
-(id) initWithFrameData:(PNFrame*) adDetails {
    _frame = adDetails;
    
    _background = [[PNViewComponent alloc] initWithDimensions:adDetails.backgroundDimensions delegate:self image:adDetails.backgroundImageUrl];
    _adArea = [[PNViewComponent alloc] initWithDimensions:adDetails.adDimensions delegate:self image:adDetails.primaryImageUrl];
    if(adDetails.closeButtonImageUrl != nil){
        _closeButton = [[PNViewComponent alloc] initWithDimensions:adDetails.closeButtonDimensions delegate:self image:adDetails.closeButtonImageUrl];
    }
    
    [_background addSubComponent:_adArea];
    if(_closeButton !=  nil){
        [_background addSubComponent:_closeButton];
    }
    _background.hidden = YES;
    
    return self;
}

-(void) dealloc {
    _frame = nil;
    [_background release];
    [_adArea release];
    [_closeButton release];
    [super dealloc];
}

#pragma mark "Public Interface"
-(void) renderAdInView:(UIView*) parentView {
    int lastDisplayIndex = parentView.subviews.count;
    [parentView insertSubview: _background atIndex:lastDisplayIndex + 1];
    _background.hidden = NO;
    [_background setNeedsDisplay];
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

// Hide the background and since all other components are attached to the background,
// everything else will also be hidden
-(void) _closeAd {
    [_background hide];
}

#pragma mark "Delegate Handlers"
// Only notify the delegate if all the components have been loaded successfully
- (void) componentDidLoad {
    if([self _allComponentsLoaded]){
        [_frame didLoad];
    }
}

// Close the ad in case of an error and notify the delegate
-(void) componentDidFailToLoadWithError: (NSError*) error {
    [self _closeAd];
    [_frame didFailToLoadWithError:error];
}

// Close the ad in case of an exception and notify the delegate
-(void) componentDidFailToLoadWithException: (NSException*) exception {
    [self _closeAd];
    [_frame didFailToLoadWithException:exception];
}

// If the close button component was clicked, close the ad and notify the delegate
// If the ad was clicked, also close the ad and notify the delegate
-(void) component: (id) component didReceiveTouch: (UITouch*) touch {
    if (component == _closeButton) {
        NSLog(@"Close button was pressed...");
        [self _closeAd];
        [_frame adClosed];
    } else if (component == _adArea) {
        CGPoint location = [touch locationInView: _adArea];
        int x = location.x;
        int y = location.y;
        NSLog(@"Ad area was clicked on at location %d,%d", x, y);
        
        [self _closeAd];
        [_frame adClicked];
    }
}

@end

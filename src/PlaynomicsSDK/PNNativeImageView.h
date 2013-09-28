//
//  PNImage.h
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import <UIKit/UIKit.h>
#import "PNFrame.h"
#import "PNNativeViewComponent.h"

@interface PNNativeImageView : NSObject <PNViewComponentDelegate, PNAdView>

-(id) initWithAd:(PNNativeImageAd *) staticAd
      background:(PNBackground *) background
        delegate:(id<PNFrameDelegate>) delegate;

-(id) initWithAd:(PNNativeImageAd *) staticAd
      background:(PNBackground *) background
     closeButton:(PNNativeCloseButton *) closeButton
        delegate:(id<PNFrameDelegate>) delegate;

@end

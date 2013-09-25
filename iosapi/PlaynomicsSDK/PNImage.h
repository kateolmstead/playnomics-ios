//
//  PNImage.h
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import <UIKit/UIKit.h>
#import "PNFrame.h"
#import "PNViewComponent.h"

@interface PNImage : NSObject <PNViewComponentDelegate, PNAdView>

-(id) initWithAd:(PNStaticAd *) staticAd
      background:(PNBackground *) background
        delegate:(id<PNFrameDelegate>) delegate;

-(id) initWithAd:(PNStaticAd *) staticAd
      background:(PNBackground *) background
     closeButton:(PNNativeCloseButton *) closeButton
        delegate:(id<PNFrameDelegate>) delegate;

@end

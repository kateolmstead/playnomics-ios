//
//  PNWebView.h
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import <UIKit/UIKit.h>
#import "PNFrame.h"
#import "PNNativeViewComponent.h"

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@interface PNWebView : UIWebView <UIWebViewDelegate, PNAdView, PNViewComponentDelegate>

-(id)     initWithAd:(PNHtmlAd *) ad
     htmlCloseButton:(PNHtmlCloseButton *) htmlCloseButton
            delegate:(id<PNFrameDelegate>) delegate;

-(id)  initWithAd:(PNHtmlAd *) ad
nativeCloseButton:(PNNativeCloseButton *)nativeCloseButton
         delegate:(id<PNFrameDelegate>)delegate;

@property (readonly) AdComponentStatus status;

@end

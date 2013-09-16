//
//  PNWebView.h
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import <UIKit/UIKit.h>
#import "PNFrame.h"
#import "PNViewComponent.h"

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@interface PNWebView : UIWebView <UIWebViewDelegate, PNAdView, PNViewComponentDelegate>

@property (readonly) AdComponentStatus status;

@end

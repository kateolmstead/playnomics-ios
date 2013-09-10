//
//  PNWebView.h
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import <UIKit/UIKit.h>
#import "PNFrame.h"

@interface PNWebView : UIWebView <UIWebViewDelegate, PNAdView>
@property (readonly) AdComponentStatus status;
@end

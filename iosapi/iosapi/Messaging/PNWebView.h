//
//  PNWebView.h
//  iosapi
//
//  Created by Shiraz Khan on 8/26/13.
//
//

#import <UIKit/UIKit.h>
#import "PlaynomicsFrame.h"

@interface PNWebView : UIWebView <UIWebViewDelegate>

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@property (assign) id<PlaynomicsFrameDelegate> frameDelegate;
@property (readonly) AdComponentStatus status;

-(id) createWithMessageAndDelegate:(PlaynomicsFrame*) adDetails;
-(void) renderAdInView: (UIView*) parentView;
@end

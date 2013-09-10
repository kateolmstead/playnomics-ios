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

@interface PNWebView : UIWebView <UIWebViewDelegate, PNViewComponentDelegate>

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@property (readonly) AdComponentStatus status;

-(id) initWithFrameData:(PNFrame*) adDetails;
-(void) renderAdInView: (UIView*) parentView;
@end

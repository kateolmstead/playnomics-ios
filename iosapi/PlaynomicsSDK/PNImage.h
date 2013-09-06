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

@interface PNImage : NSObject <PNViewComponentDelegate>
- (id) initWithFrameData:(PNFrame*) adDetails;
- (void) renderAdInView:(UIView*) parentView;
@end

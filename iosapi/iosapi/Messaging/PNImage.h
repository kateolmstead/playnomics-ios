//
//  PNImage.h
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import <UIKit/UIKit.h>
#import "PlaynomicsFrame.h"

@protocol PNBaseAdComponentDelegate
@required
-(void) componentDidLoad;
-(void) componentDidFailToLoadWithError: (NSError*) error;
-(void) componentDidFailToLoadWithException: (NSException*) exception;
-(void) component: (id) component didReceiveTouch: (UITouch*) touch;
@end

@interface PNImage : NSObject <PNBaseAdComponentDelegate>

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@property (assign) PlaynomicsFrame *frame;

-(id) createWithMessageAndDelegate:(PlaynomicsFrame*) adDetails;
-(void) renderAdInView:(UIView*) parentView;
@end

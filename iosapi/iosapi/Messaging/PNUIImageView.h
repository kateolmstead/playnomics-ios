//
//  PNUIImageView.h
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import <UIKit/UIKit.h>

typedef struct {
    int width;
    int height;
    int x;
    int y;
} PNViewDimensions;

@protocol PNUIImageDelegate
-(void) didLoad;
-(void) didFailToLoad;
-(void) didFailToLoadWithError: (NSError*) error;
-(void) didFailToLoadWithException: (NSException*) exception;
-(void) didReceiveTouch: (UITouch*) touch;
@end

@interface PNUIImageView : UIImageView

@property PNViewDimensions dimensions;

//make a copy of the String, to ensure that it's value can't change
@property (copy, readonly) NSString* imageUrl;

//assign, makes this reference weak. This because we aren't creating our delegate object, this prevents
//strong references cycles.
@property (assign) id<PNUIImageDelegate> delegate;

-(id) initWithDimensions: (PNViewDimensions) dimensions delegate: (id<PNUIImageDelegate>) delegate;
-(id) initWithDimensions: (PNViewDimensions) dimensions delegate: (id<PNUIImageDelegate>) delegate imageUrl:(NSString*) imageUrl;

@end

//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "PNFrame.h"
#import "PNAssetRequest.h"

@protocol PNViewComponentDelegate
@required
-(void) componentDidLoad;
-(void) componentDidFailToLoad;
-(void) componentDidFailToLoadWithError: (NSError*) error;
-(void) componentDidFailToLoadWithException: (NSException*) exception;
-(void) component: (id) component didReceiveTouch: (UITouch*) touch;
@end

@interface PNViewComponent : UIImageView<PNAssetRequestDelegate>
@property (assign) id<PNViewComponentDelegate> delegate;
@property (assign) NSString* imageUrl;
@property (assign) PNViewComponent *parentComponent;
@property (readonly) AdComponentStatus status;
- (id) initWithDimensions:(PNViewDimensions) dimensions delegate:(id<PNViewComponentDelegate>) delegate image:(NSString*) imageUrl;
- (void) addSubComponent:(PNViewComponent *)subView;
- (void) hide;
@end

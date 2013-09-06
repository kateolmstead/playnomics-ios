//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "PNImage.h"


@interface BaseAdComponent : UIImageView

@property (assign) id<PNBaseAdComponentDelegate> delegate;
@property (assign) NSString* imageUrl;
@property (assign) BaseAdComponent *parentComponent;
@property (readonly) AdComponentStatus status;
- (id) createComponentViewWithDimensions:(PNViewDimensions) dimensions delegate:(id<PNBaseAdComponentDelegate>) delegate image:(NSString*) imageUrl;
- (void) addSubComponent:(BaseAdComponent *)subView;
- (void) hide;
@end

//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "PNUIImageView.h"

typedef enum {
    AdComponentStatusPending,   // Component is waiting for image download to complete
    AdComponentStatusCompleted, // Component has completed image download and is ready to be displayed
    AdComponentStatusError      // Component experienced an error retrieving image
} AdComponentStatus;

@protocol BaseAdComponentDelegate
- (void) componentDidLoad: (id) component;
- (void) componentDidFailToLoad: (id) component;
- (void) componentDidReceiveTouch:  (id) component touch: (UITouch*) touch;
@end

@interface BaseAdComponent : NSObject<PNUIImageDelegate>

@property (retain, readonly) NSDictionary* properties;
@property (retain, readonly) PNUIImageView* imageUI;

@property (assign) BaseAdComponent *parentComponent;
@property (assign) id<BaseAdComponentDelegate> delegate;

@property (readonly) AdComponentStatus status;

@property float xOffset;
@property float yOffset;
@property float height;
@property float width;

- (id)initWithProperties:(NSDictionary *)properties delegate:(id<BaseAdComponentDelegate>)delegate;
- (void)renderComponent;
- (void)addSubComponent:(BaseAdComponent*)subView;
- (void)display;
- (void)hide;

+ (NSString*) getImageFromProperties: (NSDictionary*) properties;
@end

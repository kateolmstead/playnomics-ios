//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "PlaynomicsFrame+Exposed.h"

typedef NS_ENUM(NSInteger , AdComponentStatus) {
    AdComponentStatusPending,   // Component is waiting for image download to complete
    AdComponentStatusCompleted, // Component has completed image download and is ready to be displayed
    AdComponentStatusError      // Component experienced an error retrieving image
};

@interface BaseAdComponent : NSObject<NSURLConnectionDelegate>

@property (retain) NSDictionary *properties;
@property (retain) UIImageView *imageUI;
@property (retain) NSString *imageUrl;
@property (retain) BaseAdComponent *parentComponent;
@property (retain) PlaynomicsFrame *frame;


@property AdComponentStatus status;
@property float xOffset;
@property float yOffset;
@property float height;
@property float width;
@property SEL touchHandler;

- (id)initWithProperties:(NSDictionary *)aProperties
                forFrame:(PlaynomicsFrame *)aFrame
        withTouchHandler:(SEL)aTouchHandler;

- (id)layoutComponent;

- (id)addSubComponent:(BaseAdComponent*)subView;

- (void)display;

- (void)hide;

@end

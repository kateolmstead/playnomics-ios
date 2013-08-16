//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BaseAdComponent.h"
#import "PlaynomicsFrame.h"
#import "PlaynomicsMessaging.h"

/**
 * Protocol describing the methods an frame delegate should handle
 */
@protocol PNFrameRefreshHandler
- (void)refreshFrameWithId: (NSString *) frameId;
@end

@interface PlaynomicsFrame (Exposed) <BaseAdComponentDelegate>
// Initialize a frame with the provided properties describing the ad meta data (images, action URL's, etc.).
- (id) initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId andDelegate: (id<PNFrameRefreshHandler>) delegate frameDelegate: (id<PNFrameDelegate>)frameDelegate;
- (void) refreshProperties: (NSDictionary *)properties;
@end
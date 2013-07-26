//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PlaynomicsFrame.h"
#import "PlaynomicsMessaging.h"

/**
 * Protocol describing the methods an frame delegate should handle
 */
@protocol PNFrameRefreshHandler
- (void)refreshFrameWithId: (NSString *) frameId;
@end

@protocol PNBaseAdComponentDelegate <NSObject>
- (void)componentDidLoad: (id) component;
@end

@interface PlaynomicsFrame (Exposed)<PNBaseAdComponentDelegate>
// Initialize a frame with the provided properties describing the ad meta data (images, action URL's, etc.).
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId andDelegate: (id<PNFrameRefreshHandler>) delegate frameDelegate: (id<PNFrameDelegate>)frameDelegate;
- (void)refreshProperties: (NSDictionary *)properties;
@end
//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BaseAdComponent.h"
#import "PlaynomicsFrame.h"
#import "PlaynomicsMessaging.h"

@interface PlaynomicsFrame (Exposed) <PNBaseAdComponentDelegate>
- (id) initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId frameDelegate: (id<PNFrameDelegate>)frameDelegate;
- (void) refreshProperties: (NSDictionary *)properties;
@end
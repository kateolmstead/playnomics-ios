//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PlaynomicsFrame.h"

@interface PlaynomicsFrame (Exposed)

// Initialize a frame with the provided properties describing the ad meta data (images,
//  action URL's, etc.).
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId;

@end
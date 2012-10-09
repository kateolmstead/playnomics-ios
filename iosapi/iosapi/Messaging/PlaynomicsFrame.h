        //
// Created by jmistral on 10/3/12.
//
//
#import <Foundation/Foundation.h>


// Represents the container for the ad image.
//
// This frame frame will be responsible for displaying the ad image and capturing all of
// clicks within the ad area.
@interface PlaynomicsFrame : NSObject

// Frame ID as provided by the developer when retrieving the frame
@property NSString *frameId;

// Initialize a frame with the provided properties describing the ad meta data (images,
//  action URL's, etc.).  NOTE:  This should NOT BE USED to directly instantiate
//  a frame.  Instead, PlaynomicsMessaging.initFrameWithId should be used.
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)frameId;

// Called to display the ad frame and to begin capturing clicks within the frame.
- (void)start;

@end
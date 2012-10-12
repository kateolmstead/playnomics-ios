//
// Created by jmistral on 10/3/12.
//

#import <Foundation/Foundation.h>


// Represents the container for the ad image.
//
// This frame frame will be responsible for displaying the ad image and capturing all of
// clicks within the ad area.
@interface PlaynomicsFrame : NSObject

// Frame ID as provided by the developer when retrieving the frame
@property (retain) NSString *frameId;

// Called to display the ad frame and to begin capturing clicks within the frame.
- (void)start;

@end
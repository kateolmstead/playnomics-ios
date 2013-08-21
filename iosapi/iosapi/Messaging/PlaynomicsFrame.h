//
// Created by jmistral on 10/3/12.
//

#import <Foundation/Foundation.h>

typedef enum {
    DisplayResultNoInternetPermission,  // Communication with the ad server is impossible
    DisplayResultStartNotCalled,  // Data collection API was not initialized
    DisplayResultUnableToConnect,  // No successful connections to the ad server have occurred
    DisplayResultFailUnknown,  // Any other problem (included bad responses from the ad server)
    DisplayResultDisplayPending,  // Ad server has been reached, but assets not ready yet, will display when ready
    DisplayAdColony,  // Show an AdColony video ad
    DisplayResultDisplayed  // Success
} DisplayResult;

@interface PlaynomicsFrame : NSObject
@property (copy) NSString *frameId;
- (DisplayResult) start;
- (void) sendVideoView;
@end

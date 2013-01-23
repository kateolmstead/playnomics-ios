//
//  AdActionTests.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "PlaynomicsMessaging.h"
#import "PlaynomicsMessaging+Testing.h"
#import "PlaynomicsMessaging+Exposed.h"
#import "PlaynomicsFrame+Testing.h"
@interface AdActionTests : SenTestCase<PNAdClickActionHandler,PNFrameRefreshHandler>
@property (nonatomic) BOOL isDone;
-(void) onPNXSuccess;//test method to show this works
@end

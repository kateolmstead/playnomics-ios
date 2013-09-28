//
//  PNMessagingApiClient.h
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/6/13.
//
//

#import <Foundation/Foundation.h>
#import "PNSession.h"
#import "PNFrame.h"
#import "PNFrameRequest.h"

@interface PNMessagingApiClient : NSObject<PNFrameRequestDelegate>
-(id) initWithSession:(PNSession *) session;
-(void) loadDataForFrame:(PNFrame *) frame;
@end

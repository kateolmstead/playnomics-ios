//
//  PNFrameRequest.h
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/6/13.
//
//

#import <Foundation/Foundation.h>
#import "PNFrame.h"
#import "PNAssetRequest.h"
#import "PNGameSessionInfo.h"

@interface PNFrameRequest : NSObject<PNAssetRequestDelegate>
-(id) initWithFrame:(PNFrame *) frame screenSize:(CGRect) screenSize session:(PNSession *) session;
-(void) fetchFrameData;
@end

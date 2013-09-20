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

@protocol PNFrameRequestDelegate <NSObject>
-(void) onFrameUrlCompleted:(NSString *) url;
@end

@interface PNFrameRequest : NSObject<PNAssetRequestDelegate>
-(id) initWithFrame:(PNFrame *) frame
                url:(NSString *) requestUrl
          delegate:(id<PNFrameRequestDelegate>) delegate;

-(void) fetchFrameData;

@end

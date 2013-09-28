//
//  PNFrameResponse.h
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/9/13.
//
//
#import "PNAdData.h"
@interface PNFrameResponse : NSObject
@property (readonly) PNAd *ad;
@property (readonly) PNBackground *background;
@property (readonly) id closeButton;
- (id) initWithJSONData:(NSData *) jsonData;
@end

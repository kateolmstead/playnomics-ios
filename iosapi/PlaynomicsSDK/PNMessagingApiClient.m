//
//  PNMessagingApiClient.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/6/13.
//
//


#import "PNMessagingApiClient.h"
#import "PNFrameRequest.h"

@implementation PNMessagingApiClient{
    PNSession *_session;
}

-(id) initWithSession:(PNSession *) session{
    self = [super init];
    if(self){
        _session = session;
    }
    return self;
}

-(void) loadDataForFrame:(PNFrame *) frame{
    CGRect screenRect = [PNUtil getScreenDimensions];
    PNFrameRequest *request = [[PNFrameRequest alloc] initWithFrame:frame
                                                         screenSize:screenRect
                                                            session:_session];
    [request fetchFrameData];
}
@end

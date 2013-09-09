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

@interface PNMessagingApiClient : NSObject

-(id) initWithSession:(PNSession *) session;

-(void) loadDataForFrame:(PNFrame *) frame;


@end

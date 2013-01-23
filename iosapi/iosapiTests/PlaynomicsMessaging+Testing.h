//
//  PlaynomicsMessaging+Testing.h
//  iosapi
//
//  Created by Eric McConkie on 1/23/13.
//
//

#import <Foundation/Foundation.h>
#import "PlaynomicsMessaging.h"
@interface PlaynomicsMessaging (Testing)
- (NSDictionary *)_retrieveFramePropertiesForId:(NSString *)frameId withCaller: (NSString *) caller;
@end

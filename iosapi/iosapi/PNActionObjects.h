//
//  PNActionObjects.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import <Foundation/Foundation.h>

#define HTTP_ACTION_PREFIX          @"http"
#define HTTPS_ACTION_PREFIX         @"https"
#define PNACTION_ACTION_PREFIX      @"pna"
#define PNEXECUTE_ACTION_PREFIX     @"pnx"



@interface PNActionObjects : NSObject
+(NSString*)adActionMethodForURLPath:(NSString*)resource;
@end

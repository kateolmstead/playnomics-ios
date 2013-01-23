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

typedef enum {
    AdActionHTTP,            // Standard HTTP/HTTPS page to open in a browser
    AdActionDefinedAction,   // Defined selector to execute on a registered delegate
    AdActionExecuteCode,     // Submit the action on the delegate
    AdActionUnknown          // Unknown ad action specified
} AdAction;



@interface PNActionObjects : NSObject
+(AdAction)adActionTypeForURL:(NSString*)urlPath;
+(NSString*)adActionMethodForURLPath:(NSString*)resource;

@end

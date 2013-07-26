//
//  NSString+Util.h
//  iosapi
//
//  Created by Jared Jenkins on 7/26/13.
//
//

#ifndef iosapi_NSString_Util_h
#define iosapi_NSString_Util_h

#import <Foundation/Foundation.h>

typedef enum{
    AdTargetUrl,
    AdTargetData,
    AdTargetUnknown
} AdTarget;

typedef enum {
    AdActionHTTP,           // Standard HTTP/HTTPS page to open in a browser
    AdActionDefinedAction,  // Defined selector to execute on a registered delegate
    AdActionExecuteCode,    // Submit the action on the delegate
    AdActionUnknown,        // Unknown ad action specified
    AdActionNullTarget,     // No target was specified
} AdAction;

@interface NSString(Extension)
- (BOOL) isUrl;
- (AdAction) toAdAction;
- (AdTarget) toAdTarget;
@end

#endif

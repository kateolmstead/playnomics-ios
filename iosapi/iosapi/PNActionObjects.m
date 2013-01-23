//
//  PNActionObjects.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNActionObjects.h"



@implementation PNActionObjects


+(AdAction)adActionTypeForURL:(NSString*)urlPath
{
    NSArray *comps = [urlPath componentsSeparatedByString:@"://"];
    NSString *protocol = [comps objectAtIndex:0];
    if ([protocol isEqualToString:HTTP_ACTION_PREFIX] || [protocol isEqualToString:HTTPS_ACTION_PREFIX]) {
        return AdActionHTTP;
    } else if ([protocol isEqualToString:PNACTION_ACTION_PREFIX]) {
        return AdActionDefinedAction;
    } else if ([protocol isEqualToString:PNEXECUTE_ACTION_PREFIX]) {
        return AdActionExecuteCode;
    } else {
        NSLog(@"An unknown protocol was received, can't determine action type: %@", protocol);
        return AdActionUnknown;
    }
    
    return AdActionUnknown;
}

+(NSString*)adActionMethodForURLPath:(NSString*)urlPath
{
    NSArray *comps = [urlPath componentsSeparatedByString:@"://"];
    NSString *resource = [comps objectAtIndex:1];
    return [resource stringByReplacingOccurrencesOfString:@"//" withString:@""];
}


@end

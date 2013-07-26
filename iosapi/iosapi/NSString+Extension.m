//
//  NSString.m
//  iosapi
//
//  Created by Jared Jenkins on 7/26/13.
//
//

#import "NSString+Extension.h"

@implementation NSString(Extension)

- (BOOL) isUrl{
    if([self length] == 0){
        return NO;
    }
    return [self hasPrefix:@"https://"] || [self hasPrefix: @"http://"];
}

- (AdAction) toAdAction{
    if([self length] == 0){
        return AdActionNullTarget;
    }
    if([self isUrl]){
        return AdActionHTTP;
    }
    if([self hasPrefix: @"pnx://"]){
        return AdActionExecuteCode;
    }
    if([self hasPrefix: @"pna://" ]){
        return AdActionDefinedAction;
    }
    return AdActionUnknown;
}

- (AdTarget) toAdTarget{
    if([self length] == 0){
        return AdTargetUnknown;
    }
    if([self isEqualToString: @"data"]){
        return AdTargetData;
    }
    if([self isEqualToString:@"url"]){
        return AdTargetUrl;
    }
    return AdTargetUnknown;
}


@end

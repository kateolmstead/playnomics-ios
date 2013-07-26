//
//  PNActionObjects.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNActionObjects.h"



@implementation PNActionObjects

+(NSString*)adActionMethodForURLPath:(NSString*)urlPath
{
    NSArray *comps = [urlPath componentsSeparatedByString:@"://"];
    NSString *resource = [comps objectAtIndex:1];
    return [resource stringByReplacingOccurrencesOfString:@"//" withString:@""];
}
@end

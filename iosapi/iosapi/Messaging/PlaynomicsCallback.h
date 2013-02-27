//
//  PlaynomicsCallback.h
//  iosapi
//
//  Created by Eric McConkie on 2/26/13.
//
//

#import <Foundation/Foundation.h>

#define kPushCallbackUrl         @"t"//push payloads will carry this var

@interface PlaynomicsCallback : NSObject
- (void)submitAdImpressionToServer:(NSString *)impressionUrl ;
@end

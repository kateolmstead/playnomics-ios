//
//  MockDeviceToken.h
//  iosapi
//
//  Created by Jared Jenkins on 8/30/13.
//
//

#import <Foundation/Foundation.h>

@interface StubDeviceToken : NSData
- (id) initWithToken: (NSString *) token cleanToken: (NSString *) cleanToken;
- (NSString*) cleanToken;
@end

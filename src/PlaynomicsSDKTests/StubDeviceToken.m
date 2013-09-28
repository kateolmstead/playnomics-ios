//
//  MockDeviceToken.m
//  iosapi
//
//  Created by Jared Jenkins on 8/30/13.
//
//

#import "StubDeviceToken.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OCMock.h"
#import "OCMockObject.h"
#import "OCMArg.h"

@implementation StubDeviceToken{
    NSString* _token;
    NSString* _cleanToken;
}

- (id) initWithToken: (NSString *) token cleanToken: (NSString *) cleanToken{
    if((self = [super init])){
        _token = [token copy];
        _cleanToken = [cleanToken copy];
    }
    return self;
}

-(void) dealloc{
    [_token release];
    [_cleanToken release];
    [super dealloc];
}

- (NSString *) description{
    return _token;
}

- (NSString*) cleanToken{
    return _cleanToken;
}
@end

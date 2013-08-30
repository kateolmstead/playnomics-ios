//
//  StubPNEventApiClient.h
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import <Foundation/Foundation.h>

// The purpose of this class is stub out with a fake queue. Events
// won't be sent to the server.
@interface StubPNEventApiClient : NSObject
@property (readonly)  NSMutableArray *events;
-(id) getMockClient;
@end

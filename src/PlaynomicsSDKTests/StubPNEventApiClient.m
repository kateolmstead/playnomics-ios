//
//  StubPNEventApiClient.m
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import "StubPNEventApiClient.h"
#import "PNEventApiClient.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OCMock.h"
#import "OCMockObject.h"
#import "OCMArg.h"

@implementation StubPNEventApiClient{
    PNEventApiClient* _client;
    id _mock;
}

@synthesize events=_events;
-(id) init{
    if((self = [super init])){
        _events = [[NSMutableArray alloc] init];
        _client = [[PNEventApiClient alloc] init];
    }
    return self;
}

-(void) dealloc{
    [_events release];
    [super dealloc];
}

-(void) enqueueEvent: (id) event{
    [_events addObject: event];
}

-(void) enqueueEventUrl: (NSString *) url{
    [_events addObject: url];
}

-(id) getMockClient{
    if(!_mock){
        _mock = [OCMockObject partialMockForObject:_client];
        //stubs out the IO related calls for testing
        [[[_mock stub] andCall:@selector(enqueueEvent:) onObject:self] enqueueEvent: [OCMArg any]];
        [[[_mock stub] andCall:@selector(enqueueEventUrl:) onObject:self] enqueueEventUrl: [OCMArg any]];
    }
    return _mock;
}

@end

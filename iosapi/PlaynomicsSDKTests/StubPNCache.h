//
//  MockPNCache.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "PNGeneratedHexId.h"
#import "StubDeviceToken.h"


@interface StubPNCache : NSObject

-(id) initWithBreadcrumbID: (NSString *) breadcrumb idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv limitAdvertising: (BOOL) limitAdvertising;

-(id) initWithBreadcrumbID: (NSString *) breadcrumb idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv limitAdvertising: (BOOL) limitAdvertising
             lastEventTime: (NSTimeInterval) lastEventTime lastUserId: (NSString *)lastUserId lastSessionId: (PNGeneratedHexId *) sessionId;

-(id) initWithBreadcrumbID: (NSString *) breadcrumb idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv limitAdvertising: (BOOL) limitAdvertising deviceToken:(StubDeviceToken *) token;

-(void) loadDataFromCache;
-(void) writeDataToCache;
-(id) getMockCache;
@end

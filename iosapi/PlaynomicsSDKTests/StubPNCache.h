//
//  MockPNCache.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import <Foundation/Foundation.h>

@interface StubPNCache : NSObject
-(id) initWithBreadcrumbID: (NSString *) breadcrumb idfa: (NSString *) idfa idfv: (NSString *) idfv limitAdvertising: (BOOL) limitAdvertising;
-(void) loadDataFromCache;
-(void) writeDataToCache;
-(id) getMockCache;
@end

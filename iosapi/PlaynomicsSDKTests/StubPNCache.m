//
//  MockPNCache.m
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "StubPNCache.h"
#import "PNCache.h"
#import "PnCache+Private.h"

@implementation StubPNCache{
    NSString *_initBreadcrumbId;
    NSUUID *_initIdfa;
    NSUUID *_initIdfv;
    BOOL _initLimitAdvertising;

    //these values exist in the PNCache class
    id _mock;
    PNCache *_cache;
}

-(id) initWithBreadcrumbID: (NSString *) breadcrumb idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv limitAdvertising: (BOOL) limitAdvertising{
  
    if((self = [super init])){
        _cache = [[PNCache alloc] init];
        
        _initBreadcrumbId = breadcrumb;
        _initIdfa = idfa;
        _initIdfv = idfv;
        _initLimitAdvertising = limitAdvertising;
    }
    return self;
}

-(void) dealloc {
    [_mock stopMocking];
    [_cache release];
    [super dealloc];
}

-(void) loadDataFromCache{
    //mock out the calls for actually loading the data
    _cache.breadcrumbID = _initBreadcrumbId;
    _cache.idfa = _initIdfa;
    _cache.idfv = _initIdfv;
    _cache.limitAdvertising = _initLimitAdvertising;
}

-(void) writeDataToCache{
    //this does nothing
}

-(id) getMockCache{
    if(!_mock){
        _mock = [OCMockObject partialMockForObject:_cache];
        //stubs out the IO related calls for testing
        [[[_mock stub] andCall:@selector(loadDataFromCache) onObject:self] loadDataFromCache];
        [[[_mock stub] andCall:@selector(writeDataToCache) onObject:self] writeDataToCache];
    }
    return _mock;
}
@end

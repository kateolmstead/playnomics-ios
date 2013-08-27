//
//  PlaynomicsSDKTests.m
//  PlaynomicsSDKTests
//
//  Created by Jared Jenkins on 8/22/13.
//
//


#import "PNDeviceInfoTests.h"
#import "StubPNCache.h"

#import <AdSupport/AdSupport.h>

#import "PNConstants.h"
#import "PNDeviceInfo.h"
#import "PNDeviceInfo+Private.h"


@implementation PNDeviceInfoTests

-(void) setUp
{
    [super setUp];
}

-(void) tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(id) mockCurrentDeviceInfo:(PNDeviceInfo*) deviceInfo idfa: (NSUUID *) currentIdfa limitAdvertising : (BOOL) limitAdvertising idfv: (NSUUID *) currentIdfv {
    
    id mock = [OCMockObject partialMockForObject:deviceInfo];
    
    BOOL isAdvertisingEnabled = !limitAdvertising;
    [[[mock stub] andReturnValue: OCMOCK_VALUE(isAdvertisingEnabled)] isAdvertisingTrackingEnabledFromDevice];
    [[[mock stub] andReturn: currentIdfa] getAdvertisingIdentifierFromDevice];
    [[[mock stub] andReturn: currentIdfv] getVendorIdentifierFromDevice];
    return mock;
}


- (void) testGetDeviceInfoFromDevice {
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    StubPNCache *cache = [[StubPNCache  alloc] initWithBreadcrumbID:breadcrumbId idfa:[idfa UUIDString] idfv:[idfv UUIDString] limitAdvertising:limitAdvertising];
    id mockCache = [cache getMockCache];
    [cache loadDataFromCache];

    //the device settings have not changed
    
    PNDeviceInfo *info = [[PNDeviceInfo alloc] initWithCache: mockCache];
    info = [self mockCurrentDeviceInfo: info idfa: idfa limitAdvertising: limitAdvertising idfv: idfv];
    
    BOOL dataChanged = [info syncDeviceSettingsWithCache];
    //Verify no data has changed
    STAssertFalse(dataChanged, @"No data should have changed");
    
    STAssertEquals([mockCache getBreadcrumbID], breadcrumbId , @"Breadcrumb should be loaded from cache");
    //use isEqualToString for string comparison
    STAssertTrue([[mockCache getIdfa] isEqualToString: [idfa UUIDString]], @"IDFA should be loaded from cache");
    STAssertTrue([[mockCache getIdfv] isEqualToString: [idfv UUIDString]], @"IDFV should be loaded from cache");
    
    STAssertEquals([mockCache getLimitAdvertising], limitAdvertising, @"Limit advertising should be loaded from cache");
}

- (void) testDeviceInfoGetsCache{
        
}


- (void) testDeviceInfoSetsCache{
    
}


- (void) testDeviceInfoUpdatesCache{
    
}

@end

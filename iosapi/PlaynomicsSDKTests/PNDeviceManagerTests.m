//
//  PlaynomicsSDKTests.m
//  PlaynomicsSDKTests
//
//  Created by Jared Jenkins on 8/22/13.
//
//


#import "StubPNCache.h"

#import <AdSupport/AdSupport.h>

#import "PNConstants.h"
#import "PNDeviceManager.h"
#import "PNDeviceManager+Private.h"

#import <XCTest/XCTest.h>
@interface PNDeviceManagerTests : XCTestCase
@end

@implementation PNDeviceManagerTests

-(void) setUp
{
    [super setUp];
}

-(void) tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(id) mockCurrentDeviceInfo:(PNDeviceManager*) deviceInfo idfa: (NSUUID *) currentIdfa limitAdvertising : (BOOL) limitAdvertising idfv: (NSUUID *) currentIdfv generatedBreadcrumbID: (NSString*) breadcrumbId {
    
    id mock = [OCMockObject partialMockForObject:deviceInfo];
    
    BOOL isAdvertisingEnabled = !limitAdvertising;
    [[[mock stub] andReturnValue: OCMOCK_VALUE(isAdvertisingEnabled)] isAdvertisingTrackingEnabledFromDevice];
    [[[mock stub] andReturn: currentIdfa] getAdvertisingIdentifierFromDevice];
    [[[mock stub] andReturn: currentIdfv] getVendorIdentifierFromDevice];
    
    if(breadcrumbId){
        [[[mock stub] andReturn: breadcrumbId] generateBreadcrumbId];
    }
    return mock;
}


- (void) testGetDeviceInfoFromDevice {
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    StubPNCache *cache = [[StubPNCache  alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising];
    id mockCache = [cache getMockCache];
    [cache loadDataFromCache];

    //the device settings have not changed
    PNDeviceManager *info = [[PNDeviceManager alloc] initWithCache: mockCache];
    info = [self mockCurrentDeviceInfo: info idfa: idfa limitAdvertising: limitAdvertising idfv: idfv generatedBreadcrumbID:nil];
    
    BOOL dataChanged = [info syncDeviceSettingsWithCache];
    //Verify no data has changed
    XCTAssertFalse(dataChanged, @"No data should have changed");
    
    XCTAssertEqual([mockCache getBreadcrumbID], breadcrumbId , @"Breadcrumb should be loaded from cache");
    XCTAssertFalse([mockCache breadcrumbIDChanged], @"Breadcrumb should not have changed.");
    //use isEqualToString for string comparison
    XCTAssertTrue([[mockCache getIdfa] isEqual: idfa], @"IDFA should be loaded from cache");
    XCTAssertFalse([mockCache idfaChanged], @"IDFA should not have changed.");

    XCTAssertTrue([[mockCache getIdfv] isEqual: idfv], @"IDFV should be loaded from cache");
    XCTAssertFalse([mockCache idfvChanged], @"IDFA should not have changed.");

    XCTAssertEqual([mockCache getLimitAdvertising], limitAdvertising, @"Limit advertising should be loaded from cache");
    XCTAssertFalse([mockCache limitAdvertisingChanged], @"Limit advertising should not have changed.");
}

- (void) testDeviceInfoWithNewDevice{
    NSString *breadcrumbId = nil;
    NSUUID *idfa = nil;
    BOOL limitAdvertising = NO;
    NSUUID *idfv = nil;
    
    StubPNCache *cache = [[StubPNCache  alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising];
    id mockCache = [cache getMockCache];
    [cache loadDataFromCache];

    NSUUID *currentIdfa = [[NSUUID alloc] init];
    NSUUID *currentIdfv = [[NSUUID alloc] init];
    BOOL newlimitAdvertising  = YES;

    PNDeviceManager *info = [[PNDeviceManager alloc] initWithCache: mockCache];
    NSString *newBreadcrumb = [info generateBreadcrumbId];

    info = [self mockCurrentDeviceInfo: info idfa: currentIdfa limitAdvertising: newlimitAdvertising idfv: currentIdfv generatedBreadcrumbID:newBreadcrumb];
    
    
    BOOL dataChanged = [info syncDeviceSettingsWithCache];
    //Verify no data has changed
    XCTAssertTrue(dataChanged, @"Cached device data should have changed");
    
    XCTAssertTrue([[mockCache getBreadcrumbID] isEqualToString: newBreadcrumb], @"Breadcrumb should be newly generated.");
    //use isEqualToString for string comparison
    XCTAssertTrue([[mockCache getIdfa] isEqual: currentIdfa], @"IDFA should be set from device.");
    XCTAssertTrue([mockCache idfaChanged], @"IDFA should have changed.");
    
    XCTAssertTrue([[mockCache getIdfv] isEqual: currentIdfv], @"IDFV should be set from device.");
    XCTAssertTrue([mockCache idfvChanged], @"IDFA should have changed.");
    
    XCTAssertEqual([mockCache getLimitAdvertising], newlimitAdvertising, @"Limit advertising should be set from device.");
    XCTAssertTrue([mockCache idfvChanged], @"Limit advertising should have changed.");
}

-(void) testDeviceInfoUpdatesStaleValues{
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    StubPNCache *cache = [[StubPNCache  alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising];
    id mockCache = [cache getMockCache];
    [cache loadDataFromCache];
    
    NSUUID *currentIdfa = [[NSUUID alloc] init];
    NSUUID *currentIdfv = [[NSUUID alloc] init];
    BOOL newlimitAdvertising  = YES;
    
    PNDeviceManager *info = [[PNDeviceManager alloc] initWithCache: mockCache];
    
    info = [self mockCurrentDeviceInfo: info idfa: currentIdfa limitAdvertising: newlimitAdvertising idfv: currentIdfv generatedBreadcrumbID:nil];
    
    BOOL dataChanged = [info syncDeviceSettingsWithCache];
    //Verify no data has changed
    XCTAssertTrue(dataChanged, @"Cached device data should have changed");
    
    XCTAssertFalse([mockCache breadcrumbIDChanged], @"Breadcrumb did not change");
    XCTAssertTrue([[mockCache getBreadcrumbID] isEqualToString: breadcrumbId], @"Breadcrumb value is still the initial cache value.");
    XCTAssertFalse([mockCache breadcrumbIDChanged], @"Breadcrumb should not have changed.");
    
    XCTAssertTrue([[mockCache getIdfa] isEqual: currentIdfa], @"IDFA should be updated.");
    XCTAssertTrue([mockCache idfaChanged], @"IDFA should be updated.");
    
    XCTAssertTrue([[mockCache getIdfv] isEqual: currentIdfv], @"IDFV should be updated.");
    XCTAssertTrue([mockCache idfvChanged], @"IDFA should be updated.");
    
    XCTAssertEqual([mockCache getLimitAdvertising], newlimitAdvertising, @"Limit advertising should be updated.");
    XCTAssertTrue([mockCache limitAdvertisingChanged], @"Limit advertising should be updated.");
}


@end

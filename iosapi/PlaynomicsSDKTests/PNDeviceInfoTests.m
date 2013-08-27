//
//  PlaynomicsSDKTests.m
//  PlaynomicsSDKTests
//
//  Created by Jared Jenkins on 8/22/13.
//
//

#import <AdSupport/AdSupport.h>

#import "OCMock.h"
#import "OCMockObject.h"

#import "PNConstants.h"
#import "PNDeviceInfo.h"
#import "PNDeviceInfoTests.h"

@implementation PNDeviceInfoTests{
    UIPasteboard *_pastboard;
    NSMutableDictionary *_userDefaults;
    id _mockUserDefaults;
    id _mockPasteboard;
    id _mockAdvertisingSettings;
    id _mockDevice;
    
    UIPasteboard *_advertisingBoard;
    UIPasteboard *_breadcrumbBoard;
}

- (void)setUp
{
    [super setUp];
    // Set-up code here, called before each method
    _userDefaults = [NSMutableDictionary dictionary];
    
    //this mock needs to be partial because the NSUserDefaults class already exists
    _mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    //use NSMutableDictionary to mock out NSUserDefaults
    [[[_mockUserDefaults stub] andCall:@selector(setObject:forKey:) onObject:self] setObject:[OCMArg any] forKey:[OCMArg any]];
    [[[_mockUserDefaults stub] andCall:@selector(valueForKey:) onObject:self] objectForKey: [OCMArg any]];
    [[[_mockUserDefaults stub] andCall:@selector(dictionaryForKey:) onObject:self] dictionaryForKey:[OCMArg any]];
    [[[_mockUserDefaults stub] andCall:@selector(arrayForKey:) onObject:self] arrayForKey:[OCMArg any]];
    [[[_mockUserDefaults stub] andCall:@selector(stringForKey:) onObject:self] stringForKey:[OCMArg any]];
    
    _mockPasteboard = [OCMockObject mockForClass:[UIPasteboard class]];
    
    _mockAdvertisingSettings = [OCMockObject partialMockForObject:[ASIdentifierManager sharedManager]];

    _mockDevice = [OCMockObject partialMockForObject:[UIDevice currentDevice]];
    
    _breadcrumbBoard = [[UIPasteboard alloc] init];
    _advertisingBoard = [[UIPasteboard alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    [_mockUserDefaults stopMocking];
    [_mockAdvertisingSettings stopMocking];
    [_mockPasteboard stopMocking];
    [_mockDevice stopMocking];
    
    [_breadcrumbBoard release];
    [_advertisingBoard release];
    [super tearDown];
}

#pragma mark "Mocking selectors"
-(void) setObject:(id)value forKey:(NSString *)key
{
    [_userDefaults setValue:value forKey:key];
}

- (id) valueForKey:(NSString *)key
{
    return [_userDefaults valueForKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [(NSArray *) self valueForKey: key];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [(NSDictionary *) self valueForKey: key];
}

-(NSString*) stringForKey: (NSString *) key {
    return [(NSString *) self valueForKey:key];
}

#pragma mark "Mocking tests"
- (void) testNSUserDefaultsIsMocked
{
    NSString* value = @"value";
    NSString* key = @"key";
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey: key];
    STAssertEquals([_userDefaults valueForKey:key], value, @"String should be in mocking object");
    STAssertEquals([[NSUserDefaults standardUserDefaults] objectForKey:key], value, @"String value should be in NSUserDefaults");
    STAssertEquals([[NSUserDefaults standardUserDefaults] stringForKey:key], value, @"String should be in NSUserDefaults");
    
    NSDictionary* dict = [NSDictionary dictionary];
    key = @"dictionary";
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:key];
    STAssertEquals([_userDefaults valueForKey:key], dict, @"Dictionary should be in mocking object");
    STAssertEquals([[NSUserDefaults standardUserDefaults] dictionaryForKey:key], dict, @"Dictionary should be in NSUserDefaults");
}

-(void) setInitialCache: (NSString*) breadcrumbId idfa: (NSUUID*) idfa idfv: (NSUUID*) idfv limitAdvertising: (BOOL) limitAdvertising
{
    if(breadcrumbId && idfa && limitAdvertising){
        //if there is initial data it will be stored on the pasteboard
        NSString* limitAdvertisingString = limitAdvertising ? @"true" : @"false";
        
        NSDictionary *pasteboardData =  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:breadcrumbId, limitAdvertisingString, [idfa UUIDString], nil]
                                                                    forKeys:[NSArray arrayWithObjects:PNPasteboardLastBreadcrumbID, PNPasteboardLastLimitAdvertising, PNPasteboardLastIDFA, nil]];
        _advertisingBoard.items = [NSArray arrayWithObject : pasteboardData];
    }

    if(breadcrumbId){
        [_breadcrumbBoard setString: breadcrumbId];
    }

    [[[_mockPasteboard stub] andReturn:_advertisingBoard] pasteboardWithName:PNPasteboardName create: YES ];
    [[[_mockPasteboard stub] andReturn:_breadcrumbBoard] pasteboardWithName:PNUserDefaultsLastDeviceID create: NO];
    
    if(idfv){
        [[NSUserDefaults standardUserDefaults] setValue:[idfv UUIDString]  forKey:PNUserDefaultsLastIDFV];
    }
}

-(void) setAdvertisingSettings : (NSUUID*) currentIdfa limitAdvertising :  (BOOL) limitAdvertising {
    BOOL isAdvertisingEnabled = !limitAdvertising;
    [[[_mockAdvertisingSettings stub] andReturnValue:OCMOCK_VALUE(isAdvertisingEnabled)] isAdvertisingTrackingEnabled];
    [[[_mockAdvertisingSettings stub] andReturn:currentIdfa] advertisingIdentifier];
}


- (void) testGetDeviceInfoFromDevice {
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = FALSE;
    
    NSString* limitAdvertisingString = limitAdvertising ? @"true" : @"false";
    
    NSUUID *idfv = [[NSUUID alloc] init];
    
    //just load the data from the cache, no changes
    [self setInitialCache: breadcrumbId idfa: idfa idfv:idfv limitAdvertising:limitAdvertising];
    //the device settings have not changed
    [self setAdvertisingSettings:idfa limitAdvertising: limitAdvertising];
    
    PNDeviceInfo *deviceInfo = [[PNDeviceInfo alloc] init];
    
    //verify all data was correctly loaded from the cache
    STAssertEquals(breadcrumbId, deviceInfo.breadcrumbId, @"Breadcrumb should be loaded from cache");
    STAssertEquals(idfa, deviceInfo.idfa, @"IDFA should be loaded from cache");
    STAssertEquals(idfv, deviceInfo.idfa, @"IDFV should be loaded from cache");
    STAssertEquals(limitAdvertising, deviceInfo.limitAdvertising, @"Limit advertising should be loaded from cache");
    STAssertEquals(false, deviceInfo.infoChanged, @"No device info was updated.");
    //verify all data is still in the cache with no changes
    
    STAssertTrue(_advertisingBoard.items && _advertisingBoard.items.count == 1, @"Only 1 item should be in the pasteboard");
    
    NSDictionary *pasteboardData = _advertisingBoard.items[0];
    
    STAssertEquals([pasteboardData valueForKey:PNPasteboardLastBreadcrumbID], breadcrumbId, @"Breadcrumb cache value should not change");
    STAssertEquals([pasteboardData valueForKey:PNPasteboardLastIDFA], [idfa UUIDString], @"IDFA cache value should not change");
    STAssertEquals([pasteboardData valueForKey:PNPasteboardLastLimitAdvertising], limitAdvertisingString, @"Limit Advertising cache value should not change");
}



- (void) testDeviceInfoGetsCache{
        
}


- (void) testDeviceInfoSetsCache{
    
}


- (void) testDeviceInfoUpdatesCache{
    
}

@end

//
//  PlaynomicsSDKTests.h
//  PlaynomicsSDKTests
//
//  Created by Jared Jenkins on 8/22/13.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface PNDeviceInfoTests : SenTestCase

- (void) testGetDeviceInfoFromNSUserDefaults;

- (void) testNSUserDefaultsDoesCacheData;

- (void) testDeviceInfoGetsUpdated;

@end

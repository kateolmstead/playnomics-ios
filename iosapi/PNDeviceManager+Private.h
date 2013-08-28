//
//  PNDeviceInfo+Private.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

@interface PNDeviceManager(Private)
- (BOOL) isAdvertisingTrackingEnabledFromDevice;
- (NSUUID *) getAdvertisingIdentifierFromDevice;
- (NSUUID *) getVendorIdentifierFromDevice;
- (NSString *) generateBreadcrumbId;
@end

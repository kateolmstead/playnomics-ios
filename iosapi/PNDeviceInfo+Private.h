//
//  PNDeviceInfo+Private.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

@interface PNDeviceInfo(Private)
-(BOOL) isAdvertisingTrackingEnabledFromDevice;
-(NSUUID *) getAdvertisingIdentifierFromDevice;
-(NSUUID *) getVendorIdentifierFromDevice;
@end

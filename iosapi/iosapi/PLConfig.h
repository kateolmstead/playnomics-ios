//
//  PLConfig.h
//  iosapi
//
//  Created by Martin Harkins on 6/25/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#ifndef iosapi_PLConfig_h
#define iosapi_PLConfig_h

// TODO update PLCollectionMode to that of iOS
#define PLSettingCollectionMode (int) 8;

#define PLUpdateTimeInterval (NSTimeInterval) 10
#define PLSessionTimeout (NSTimeInterval) 180

#define PLFileEventArchive [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: @"PlaynomicsEvents.archive"]

#ifdef DEBUG

#define PLPropertyVersion @"0.0.1"
#define PLPropertyBaseUrl @"https://test.b.playnomics.net/v1/"
#define PLPropertyConnectionTimeout 5000

#elif



#endif

#endif

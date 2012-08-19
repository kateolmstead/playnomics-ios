//
//  PNConfig.h
//  iosapi
//
//  Created by Martin Harkins on 6/25/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#ifndef iosapi_PNConfig_h
#define iosapi_PNConfig_h

// TODO update PNCollectionMode to that of iOS
#define PNSettingCollectionMode (int) 8;

#define PNFileEventArchive [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: @"PlaynomicsEvents.archive"]

#define PNPropertyBaseTestUrl @"https://test.b.playnomics.net/v1/"
#define PNPropertyBaseProdUrl @"https://e.a.playnomics.net/"
#define PNPropertyVersion @"1"
#define PNPropertyConnectionTimeout 2000

#ifdef DEBUG

#define PNUpdateTimeInterval (NSTimeInterval) 10
#define PNSessionTimeout (NSTimeInterval) 20

#else

#define PNUpdateTimeInterval (NSTimeInterval) 60
#define PNSessionTimeout (NSTimeInterval) 180

#endif

#endif

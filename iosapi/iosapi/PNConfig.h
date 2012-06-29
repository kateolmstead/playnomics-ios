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

#ifdef DEBUG

#define PNUpdateTimeInterval (NSTimeInterval) 10
#define PNSessionTimeout (NSTimeInterval) 20

#define PNPropertyVersion @"0.0.1"
#define PNPropertyBaseUrl @"https://test.b.playnomics.net/v1/"
#define PNPropertyConnectionTimeout 5000

#elif

#define PNUpdateTimeInterval (NSTimeInterval) 60
#define PNSessionTimeout (NSTimeInterval) 180
#define PNPropertyConnectionTimeout 5000

#endif

#endif

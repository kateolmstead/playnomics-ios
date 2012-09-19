//
//  PNConfig.h
//  iosapi
//
//  Created by Martin Harkins on 6/25/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#ifndef iosapi_PNConfig_h
#define iosapi_PNConfig_h

#define PNSettingCollectionMode (int) 8;

#define PNFileEventArchive [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: @"PlaynomicsEvents.archive"]
// Playnomics server urls
#define PNPropertyBaseTestUrl @"https://test.b.playnomics.net/v1/"
#define PNPropertyBaseProdUrl @"https://e.a.playnomics.net/v1/"

#define PNPropertyVersion @"6"
// Connection timeout in seconds
#define PNPropertyConnectionTimeout 5

#ifdef DEBUG

#define PNUpdateTimeInterval (NSTimeInterval) 10
#define PNSessionTimeout (NSTimeInterval) 20

#else

#define PNUpdateTimeInterval (NSTimeInterval) 60
#define PNSessionTimeout (NSTimeInterval) 180
// DEBUG
#endif
// iosapi_PNConfig_h
#endif

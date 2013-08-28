//
//  PNCache+Testing.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#ifndef iosapi_PNCache_Testing_h
#define iosapi_PNCache_Testing_h

@interface PNCache()
@property (copy) NSString *breadcrumbID;
@property (copy) NSUUID *idfa;
@property (copy) NSUUID *idfv;
@property (assign) BOOL limitAdvertising;
@end

#endif

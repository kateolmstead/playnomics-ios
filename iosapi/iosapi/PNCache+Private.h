//
//  PNCache+Testing.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

@interface PNCache()
@property (copy) NSString *breadcrumbID;
@property (copy) NSUUID *idfa;
@property (copy) NSUUID *idfv;
@property (assign) BOOL limitAdvertising;
@property (retain) PNGeneratedHexId *lastSessionId;
@property (copy) NSString *lastUserId;
@property (assign) NSTimeInterval lastEventTime;
@end
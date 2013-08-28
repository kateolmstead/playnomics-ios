//
//  PNCache.h
//  iosapi
//
//  Created by Jared Jenkins on 8/26/13.
//
//

#import <Foundation/Foundation.h>

@interface PNCache : NSObject

@property (readonly) BOOL  breadcrumbIDChanged;
@property (readonly) BOOL  idfaChanged;
@property (readonly) BOOL  idfvChanged;
@property (readonly) BOOL  limitAdvertisingChanged;

- (NSString *) getBreadcrumbID;
- (void) updateBreadcrumbID: (NSString*) value;

- (NSUUID *) getIdfa;
- (void) updateIdfa: (NSUUID *) value;

- (NSUUID *) getIdfv;
- (void) updateIdfv : (NSUUID *) value;

- (BOOL) getLimitAdvertising;
- (void) updateLimitAdvertising : (BOOL) value;

// I/O cache methods
- (void) loadDataFromCache;
- (void) writeDataToCache;
@end

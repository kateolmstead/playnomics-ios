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
- (void) setBreadcrumbID: (NSString*) breadcrumbID;
- (BOOL) breadcrumbIDChanged;

- (NSString *) getIdfa;
- (void) setIdfa: (NSString *) idfa;
- (BOOL) idfaChanged;

- (NSString *) getIdfv;
- (void) setIdfv : (NSString *) idfv;
- (BOOL) idfvChanged;

- (BOOL) limitAdvertising;
- (void) setLimitAdvertising : (BOOL) limitAdvertising;

// I/O cache methods
- (void) loadDataFromCache;
- (void) writeDataToCache;
@end

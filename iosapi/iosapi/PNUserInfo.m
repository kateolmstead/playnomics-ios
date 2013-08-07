//
//  PNUserInfo.m
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import "PNUserInfo.h"

@implementation PNUserInfo

@synthesize breadcrumbId=_breadcrumbId;
@synthesize limitAdvertising=_limitAdvertising;
@synthesize idfa=_idfa;
@synthesize idfv=_idfv;

- (id) init: (id<PNUserInfoChangeActionHandler>) actionHandler {
    if ((self = [super init])) {
        _breadcrumbId = @"";
        _limitAdvertising = @"";
        _idfa = @"";
        _idfv = @"";
        
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PNPasteboardName create:YES];
        pasteboard.persistent = YES;
        NSArray *pasteboardData = [pasteboard items];
        NSString *oldLimitAdvertising = @"";
        NSString *oldIDFA = @"";
        
        // If the pasteboard doesn't have a Playnomics breadcrumbId, then generate one
        if (pasteboardData == nil || [pasteboardData count] == 0) {
            _breadcrumbId = [[PNUtil getDeviceUniqueIdentifier] retain];
        } else {
            NSDictionary *pnData = [pasteboardData objectAtIndex:0];
            _breadcrumbId = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastBreadcrumbID] encoding:NSUTF8StringEncoding];
            if ([pnData valueForKey:PNPasteboardLastLimitAdvertising]) {
                oldLimitAdvertising = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastLimitAdvertising] encoding:NSUTF8StringEncoding];
            }
            if ([pnData valueForKey:PNPasteboardLastIDFA]) {
                oldIDFA = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastIDFA] encoding:NSUTF8StringEncoding];
            }
        }
        
        NSDictionary *newAdvertisingInfo = [[PNUtil getAdvertisingInfo] retain];
        _limitAdvertising = [newAdvertisingInfo valueForKey:PNPasteboardLastLimitAdvertising];
        _idfa = [newAdvertisingInfo valueForKey:PNPasteboardLastIDFA];
        
        NSString *oldIDFV = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastIDFV];
        _idfv = [[PNUtil getVendorIdentifier] retain];
        
        if (![oldLimitAdvertising isEqualToString:_limitAdvertising] || ![oldIDFA isEqualToString:_idfa] || ![oldIDFV isEqualToString:_idfv]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:_idfv forKey:PNUserDefaultsLastIDFV];
            NSDictionary *pnData = [NSDictionary dictionaryWithObjects:
                                    [NSArray
                                     arrayWithObjects:_breadcrumbId, _limitAdvertising, _idfa, nil]
                                    forKeys:[NSArray arrayWithObjects:PNPasteboardLastBreadcrumbID, PNPasteboardLastLimitAdvertising, PNPasteboardLastIDFA, nil]];
            [actionHandler performActionOnIdsChangedWithBreadcrumbId:_breadcrumbId andLimitAdvertising: _limitAdvertising andIDFA:_idfa andIDFV:_idfv];
            pasteboard.items = [NSArray arrayWithObject:pnData];
        }
    }
    return self;
}

- (void) dealloc {
    [_breadcrumbId release];
	[_limitAdvertising release];
	[_idfa release];
	[_idfv release];
    
    [super dealloc];
}

@end
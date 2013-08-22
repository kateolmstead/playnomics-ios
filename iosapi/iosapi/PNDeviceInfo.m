//
//  PNUserInfo.m
//  iosapi
//
//  Created by Shiraz Khan on 8/6/13.
//
//

#import "PNDeviceInfo.h"
#import <AdSupport/AdSupport.h>

@implementation PNDeviceInfo

@synthesize breadcrumbId=_breadcrumbId;
@synthesize limitAdvertising=_limitAdvertising;
@synthesize idfa=_idfa;
@synthesize idfv=_idfv;
@synthesize infoChanged=_infoChanged;

- (id) init{
    if ((self = [super init])) {
        _infoChanged = false;
        
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PNPasteboardName create:YES];
        pasteboard.persistent = YES;
        NSArray* pasteboardData = [pasteboard items];
        NSString* oldLimitAdvertising = nil;
        NSString* oldIDFA = nil;
        
        
        // If the pasteboard doesn't have a Playnomics breadcrumbId, then generate one
        if ( [pasteboardData count] == 0) {
            _breadcrumbId = [[self getDeviceUniqueIdentifier] retain];
        } else {
            NSDictionary *pnData = [pasteboardData objectAtIndex:0];
            _breadcrumbId = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastBreadcrumbID] encoding: NSUTF8StringEncoding];
            
            if ([pnData valueForKey:PNPasteboardLastLimitAdvertising]) {
                oldLimitAdvertising = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastLimitAdvertising] encoding:NSUTF8StringEncoding];
            }
            if ([pnData valueForKey:PNPasteboardLastIDFA]) {
                oldIDFA = [[NSString alloc] initWithData:[pnData valueForKey:PNPasteboardLastIDFA] encoding:NSUTF8StringEncoding];
            }
        }
        
        NSDictionary *newAdvertisingInfo = [[self getAdvertisingInfo] retain];
        _limitAdvertising = [newAdvertisingInfo valueForKey:PNPasteboardLastLimitAdvertising];
        _idfa = [newAdvertisingInfo valueForKey:PNPasteboardLastIDFA];
        
        NSString *oldIDFV = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastIDFV];
        _idfv = [[self getVendorIdentifier] retain];
        
        _infoChanged = !(oldLimitAdvertising && [oldLimitAdvertising isEqualToString:_limitAdvertising]) ||
                    !(oldIDFA && [oldIDFA isEqualToString:_idfa]) ||
                    !(oldIDFV && [oldIDFV isEqualToString:_idfv]);
        
        if (_infoChanged) {
            
            [[NSUserDefaults standardUserDefaults] setObject:_idfv forKey:PNUserDefaultsLastIDFV];
            
            NSDictionary *pnData = [NSMutableDictionary dictionary];
            if (NSClassFromString(@"ASIdentifierManager")) {
            
                pnData = [NSDictionary dictionaryWithObjects:
                          [NSArray arrayWithObjects:_breadcrumbId, _limitAdvertising, _idfa, nil]
                                                     forKeys:[NSArray arrayWithObjects:PNPasteboardLastBreadcrumbID, PNPasteboardLastLimitAdvertising, PNPasteboardLastIDFA, nil]];
            
            } else {
                pnData = [NSDictionary dictionaryWithObject:_breadcrumbId forKey:PNPasteboardLastBreadcrumbID];
            }
            
            pasteboard.items = [NSArray arrayWithObject:pnData];
        }
    }
    return self;
}

- (NSString *) getDeviceUniqueIdentifier {
    // First check the old pasteboard (pre v8.2) to see if the Playnomics breadcrumbId exists
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:PNUserDefaultsLastDeviceID create:NO];
    NSString *storedUUID = [pasteBoard string];
    
    // If it doesn't exist, create a new Playnomics breadcrumbId, but don't save it anywhere
    // The calling method will save it
    if ([storedUUID length] == 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        storedUUID = [(NSString *)CFUUIDCreateString(NULL,uuidRef) autorelease];
        CFRelease(uuidRef);
    }
    
    return storedUUID;
}

// Unique to an app group, which is tied by the organization deploying the apps to the AppStore
- (NSString *) getVendorIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSLog(@"Latest IDFV is:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        NSLog(@"No IDFV so this must be a pre-iOS 6 device");
        return @"";
    }
}

- (NSDictionary *) getAdvertisingInfo {
    NSMutableDictionary *advertisingInfo = [NSMutableDictionary dictionary];
    if (NSClassFromString(@"ASIdentifierManager")) {
        ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
        
        [advertisingInfo setValue:(manager.isAdvertisingTrackingEnabled ? @"false" : @"true") forKey:PNPasteboardLastLimitAdvertising];
        [advertisingInfo setValue:[manager.advertisingIdentifier UUIDString] forKey:PNPasteboardLastIDFA];
        
        NSLog(@"Latest Advertising Information is:%@", advertisingInfo);
    } else {
        NSLog(@"No Advertising Information available so this must be a pre-iOS 6 device");
    }
    return advertisingInfo;
}

- (void) dealloc {
    [_breadcrumbId release];
	[_limitAdvertising release];
	[_idfa release];
	[_idfv release];
    [super dealloc];
}

@end
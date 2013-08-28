//
//  PNCache.m
//  iosapi
//
//  Created by Jared Jenkins on 8/26/13.
//
//

#import "PNCache.h"
#import "PNCache+Private.h"
#import <UIKit/UIKit.h>

@implementation PNCache

@synthesize idfa;
@synthesize idfv;
@synthesize limitAdvertising;
@synthesize breadcrumbID;

@synthesize idfaChanged = _idfaChanged;
@synthesize idfvChanged = _idfvChanged;
@synthesize limitAdvertisingChanged = _limitAdvertisingChanged;
@synthesize breadcrumbIDChanged = _breadcrumbIDChanged;

- (void)dealloc{
    if(self.breadcrumbID){
        [self.breadcrumbID release];
    }
    
    if(self.idfa){
        [self.idfa release];
    }

    if(self.idfv){
        [self.idfv release];
    }
    
    [super dealloc];
}

-(void) loadDataFromCache {
    UIPasteboard *playnomicsPasteboard = [self getPlaynomicsPasteboard];
    if([[playnomicsPasteboard items] count] == 0){
        UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:PNUserDefaultsLastDeviceID create:NO];
        self.breadcrumbID = [pasteBoard string];
    
    } else {
        NSDictionary *data = [playnomicsPasteboard items][0];
        self.breadcrumbID = [self deserializeStringFromData: data key: PNPasteboardLastBreadcrumbID];
        
        NSString * idfaString =  [self deserializeStringFromData:data key:PNPasteboardLastIDFA];
        if(idfaString){
            self.idfa = [[[NSUUID alloc] initWithUUIDString: idfaString] autorelease];
        }
        
        self.limitAdvertising = [PNUtil stringAsBool: [self deserializeStringFromData:data key:PNPasteboardLastLimitAdvertising]];
    }
    
    if(self.breadcrumbID && [self.breadcrumbID length] == 0){
        //it's possible that we get back a false positive
        [self.breadcrumbID release];
    }
    
    NSString* idfvString = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastIDFV];
    if(idfvString){
        self.idfv = [[[NSUUID alloc] initWithUUIDString: idfvString] autorelease];
    }
    
}

-(void) writeDataToCache {

    if(_breadcrumbIDChanged || _idfaChanged || _limitAdvertisingChanged){
        UIPasteboard *playnomicsPasteboard = [self getPlaynomicsPasteboard];
        NSMutableDictionary *pasteboardData = ([[playnomicsPasteboard items] count] == 1) ?
                                    [playnomicsPasteboard items][0] :
                                    [NSMutableDictionary new];

        if(_idfaChanged){
            [pasteboardData setValue:[self.idfa UUIDString] forKey:PNPasteboardLastIDFA];
        }
        if(_breadcrumbIDChanged){
            [pasteboardData setValue:self.breadcrumbID forKey:PNPasteboardLastBreadcrumbID];
        }
        if(_limitAdvertisingChanged){
            [pasteboardData setValue:[PNUtil boolAsString: self.limitAdvertising] forKey: PNPasteboardLastLimitAdvertising];
        }
    }
    
    if(_idfvChanged){
        [[NSUserDefaults standardUserDefaults] setValue:[self.idfv UUIDString] forKey:PNUserDefaultsLastIDFV];
    }
}

- (UIPasteboard *) getPlaynomicsPasteboard {
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PNPasteboardName create:YES];
    pasteboard.persistent = YES;
    return pasteboard;
}

- (NSString *) getBreadcrumbID {
    return self.breadcrumbID;
}

-(void)updateBreadcrumbID:(NSString *)value{
    if(!(self.breadcrumbID && [value isEqualToString:self.breadcrumbID])){
        self.breadcrumbID = value;
        _breadcrumbIDChanged = TRUE;
    }
}

- (NSUUID *) getIdfa{
    return self.idfa;
}

- (void) updateIdfa: (NSUUID *) value{
    if(!(self.idfa && [value isEqual:self.idfa])){
        self.idfa = value;
        _idfaChanged = TRUE;
    }
}

- (NSUUID *) getIdfv {
    return self.idfv;
}

- (void) updateIdfv : (NSUUID *) value{
    if(!(self.idfv && [value isEqual: self.idfv])){
        self.idfv = value;
        _idfvChanged = TRUE;
    }
}

- (BOOL) getLimitAdvertising{
    return self.limitAdvertising;
}

- (void) updateLimitAdvertising : (BOOL) value{
    if(self.limitAdvertising != value){
        self.limitAdvertising = value;
        _limitAdvertisingChanged = TRUE;
    }
}

- (NSString *) deserializeStringFromData : (NSDictionary*) dict key:(NSString*) key{
    return [[[NSString alloc] initWithData:[dict valueForKey:key] encoding: NSUTF8StringEncoding] autorelease];
}
@end

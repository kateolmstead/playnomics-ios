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
@synthesize deviceToken=_deviceToken;

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
    
    if(self.lastSessionId){
        [self.lastSessionId release];
    }
    
    if(self.deviceToken){
        [self.deviceToken release];
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
        
        NSString *idfaString =  [self deserializeStringFromData:data key:PNPasteboardLastIDFA];
        if(idfaString){
            self.idfa = [[[NSUUID alloc] initWithUUIDString: idfaString] autorelease];
        }
        
        self.limitAdvertising = [PNUtil stringAsBool: [self deserializeStringFromData:data key:PNPasteboardLastLimitAdvertising]];
    }
    
    if(self.breadcrumbID && [self.breadcrumbID length] == 0){
        //it's possible that we get back a false positive
        [self.breadcrumbID release];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *idfvString = [defaults stringForKey:PNUserDefaultsLastIDFV];
    if(idfvString){
        self.idfv = [[[NSUUID alloc] initWithUUIDString: idfvString] autorelease];
    }
    
    NSString *lastSessionIdHex = [defaults stringForKey:PNUserDefaultsLastSessionID];
    if (lastSessionIdHex) {
        self.lastSessionId = [[[PNGeneratedHexId alloc] initWithValue: lastSessionIdHex] autorelease];
    }
    
    self.lastUserId = [defaults stringForKey:PNUserDefaultsLastUserID];
    self.lastEventTime = [defaults doubleForKey:PNUserDefaultsLastSessionEventTime];
    self.deviceToken = [defaults stringForKey:PNUserDefaultsLastDeviceToken];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(_idfvChanged){
        [defaults setValue:[self.idfv UUIDString] forKey: PNUserDefaultsLastIDFV];
    }
    
    [defaults setValue:[ self.lastSessionId toHex] forKey: PNUserDefaultsLastSessionID];
    [defaults setValue: self.lastUserId forKey: PNUserDefaultsLastUserID];
    [defaults setDouble: self.lastEventTime forKey: PNUserDefaultsLastSessionEventTime];
    [defaults setValue: self.deviceToken forKey: PNUserDefaultsLastDeviceToken];
    [defaults synchronize];
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

- (PNGeneratedHexId *) getLastSessionId{
    return self.lastSessionId;
}

- (void) updateLastSessionId: (PNGeneratedHexId *) value{
    if(self.lastSessionId != value){
        self.lastSessionId = value;
    }
}

- (NSString *) getLastUserId{
    return self.lastUserId;
}

- (void) updateLastUserId: (NSString *) value{
    if(!(self.lastUserId && [value isEqualToString:self.lastUserId])){
        self.lastUserId = value;
    }
}

- (NSTimeInterval) getLastEventTime{
    return self.lastEventTime;
}

- (void) updateLastEventTimeToNow {
    self.lastEventTime = [[NSDate date] timeIntervalSince1970];
}

- (NSString *) getDeviceToken{
    return self.deviceToken;
}

- (void) updateDeviceToken: (NSString *) value{
    self.deviceToken =  value;
}

- (NSString *) deserializeStringFromData : (NSDictionary*) dict key:(NSString*) key{
    return [[[NSString alloc] initWithData:[dict valueForKey:key] encoding: NSUTF8StringEncoding] autorelease];
}
@end

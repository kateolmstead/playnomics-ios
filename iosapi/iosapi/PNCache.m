//
//  PNCache.m
//  iosapi
//
//  Created by Jared Jenkins on 8/26/13.
//
//

#import "PNCache.h"
#import <UIKit/UIKit.h>

@implementation PNCache{
    NSString *_breadcrumbId;
    NSString *_idfa;
    NSString *_idfv;
    BOOL _limitAdvertising;
}

@synthesize idfaChanged = _idfaChanged;
@synthesize idfvChanged = _idfvChanged;
@synthesize limitAdvertisingChanged = _limitAdvertisingChanged;
@synthesize breadcrumbIDChanged = _breadcrumbIDChanged;

- (void)dealloc{
    if(_breadcrumbId){
        [_breadcrumbId release];
    }
    
    if(_idfa){
        [_idfa release];
    }

    if(_idfv){
        [_idfv release];
    }
    
    [super dealloc];
}

-(void) loadDataFromCache {
    UIPasteboard *playnomicsPasteboard = [self getPlaynomicsPasteboard];
    if([[playnomicsPasteboard items] count] == 0){
        UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:PNUserDefaultsLastDeviceID create:NO];
        _breadcrumbId = [[pasteBoard string] copy];
    
    } else {
        NSDictionary *data = [playnomicsPasteboard items][0];
        _breadcrumbId = [[self deserializeStringFromData: data key: PNPasteboardLastBreadcrumbID] copy];
        _idfa = [[self deserializeStringFromData:data key:PNPasteboardLastIDFA] copy];
        _limitAdvertising = [self stringAsBool: [self deserializeStringFromData:data key:PNPasteboardLastLimitAdvertising]];
    }
    
    if(_breadcrumbId && [_breadcrumbId length] == 0){
        //it's possible that we get back a false positive
        [_breadcrumbId release];
    }
    
    _idfv = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastIDFV];
}

-(void) writeDataToCache {

    if(_breadcrumbIDChanged || _idfaChanged || _limitAdvertisingChanged){
        UIPasteboard *playnomicsPasteboard = [self getPlaynomicsPasteboard];
        NSMutableDictionary *pasteboardData = ([[playnomicsPasteboard items] count] == 1) ?
                                    [playnomicsPasteboard items][0] :
                                    [NSMutableDictionary new];

        if(_idfaChanged){
            [pasteboardData setValue:_idfa forKey:PNPasteboardLastIDFA];
        }
        if(_breadcrumbIDChanged){
            [pasteboardData setValue:_breadcrumbId forKey:PNPasteboardLastBreadcrumbID];
        }
        if(_limitAdvertisingChanged){
            [pasteboardData setValue:[self boolAsString: _limitAdvertising] forKey: PNPasteboardLastLimitAdvertising];
        }
    }
    
    if(_idfvChanged){
        [[NSUserDefaults standardUserDefaults] setValue:_idfv forKey:PNUserDefaultsLastIDFV];
    }
}

- (UIPasteboard *) getPlaynomicsPasteboard {
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PNPasteboardName create:YES];
    pasteboard.persistent = YES;
    return pasteboard;
}

- (NSString *) getBreadcrumbID {
    return _breadcrumbId;
}

-(void)setBreadcrumbID:(NSString *)breadcrumbID{
    if(!(_breadcrumbId && [breadcrumbID isEqualToString:_breadcrumbId])){
        _breadcrumbId = [breadcrumbID copy];
        _breadcrumbIDChanged = TRUE;
    }
}

- (NSString *) getIdfa{
    return _idfa;
}

- (void) setIdfa: (NSString *) idfa{
    if(!(_idfa && [idfa isEqualToString:_idfa])){
        _idfa = [idfa copy];
        _idfaChanged = TRUE;
    }
}

- (NSString *) getIdfv {
    return _idfv;
}

- (void) setIdfv : (NSString *) idfv{
    if(!(_idfv && [idfv isEqualToString:_idfv])){
        _idfv = [idfv copy];
        _idfvChanged = TRUE;
    }
}

- (BOOL) limitAdvertising{
    return _limitAdvertising;
}

- (void) setLimitAdvertising : (BOOL) limitAdvertising{
    if(_limitAdvertising != limitAdvertising){
        _limitAdvertising = limitAdvertising;
        _limitAdvertisingChanged = TRUE;
    }
}

- (NSString *) deserializeStringFromData : (NSDictionary*) dict key:(NSString*) key{
    return [[NSString alloc] initWithData:[dict valueForKey:key] encoding: NSUTF8StringEncoding];
}

-(BOOL) stringAsBool : (NSString*)value{
    return value && [value isEqualToString:@"true"];
}

-(NSString*) boolAsString : (BOOL) value{
    return value ? @"true" : @"false";
}
@end

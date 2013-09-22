//
//  PNFrameResponse.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/9/13.
//
//

#import "PNFrameResponse.h"

@implementation PNFrameResponse

@synthesize backgroundInfo = _backgroundInfo;
@synthesize backgroundImageUrl = _backgroundImageUrl;
@synthesize adInfo = _adInfo;
@synthesize adDimensions = _adDimensions;
@synthesize adType = _adType;
@synthesize fullscreen = _fullscreen;
@synthesize htmlContent = _htmlContent;
@synthesize primaryImageUrl = _primaryImageUrl;
@synthesize clickUrl = _clickUrl;
@synthesize clickTargetData = _clickTargetData;
@synthesize clickLink = _clickLink;
@synthesize impressionUrl = _impressionUrl;
@synthesize closeUrl = _closeUrl;
@synthesize viewUrl = _viewUrl;
@synthesize closeButtonInfo = _closeButtonInfo;
@synthesize closeButtonImageUrl = _closeButtonImageUrl;
@synthesize closeButtonDimensions = _closeButtonDimensions;
@synthesize closeButtonType = _closeButtonType;

@synthesize targetType=_targetType;
@synthesize actionType=_actionType;

- (id) initWithJSONData:(NSData *) jsonData {
    self = [super init];
    if(self){
        NSDictionary* jsonDict = [PNUtil deserializeJsonData: jsonData];
        [self parseFrameResponse: jsonDict];
    }
    return self;
}

-(void) parseFrameResponse:(NSDictionary *)frameResponse {
    if(frameResponse == nil){
        return;
    }
    // Get the background details, which are in the key "b" and is a dictionary of data
    _backgroundInfo = [[frameResponse objectForKey:FrameResponseBackgroundInfo] retain];
    _backgroundImageUrl = [[self getImageFromProperties:_backgroundInfo] retain];
    
    NSDictionary *adLocationInfo = [frameResponse objectForKey:FrameResponseAdLocationInfo];
    _adDimensions = [self getViewDimensions:adLocationInfo];
    
    NSArray *adResponse = [frameResponse objectForKey:FrameResponseAds];
    if (!adResponse || adResponse.count == 0){
        _adInfo = nil;
    } else {
        _adInfo = [adResponse objectAtIndex:0];
        _primaryImageUrl = [[self getImageFromProperties:_adInfo] retain];
        _impressionUrl = [[_adInfo objectForKey:FrameResponseAd_ImpressionUrl] retain];
        _closeUrl = [[_adInfo objectForKey:FrameResponseAd_CloseUrl] retain];
        
        _clickUrl = [[_adInfo objectForKey:FrameResponseAd_ClickUrl] retain];
        _clickTargetData = [[_adInfo objectForKey:FrameResponseAd_TargetData] retain];
        _clickTargetUrl = [[_adInfo objectForKey:FrameResponseAd_TargetUrl] retain];
        _clickLink = [_adInfo objectForKey:FrameResponseAd_ClickLink] != (id)[NSNull null]
                            ? [[_adInfo objectForKey:FrameResponseAd_ClickLink] retain]
                            : nil;
        
        _actionType = [self toAdAction : _clickUrl];
        _targetType = [self toAdTarget: [_adInfo objectForKey:FrameResponseAd_TargetType]];
        
        NSString* adType = [_adInfo objectForKey:FrameResponseAd_AdType];
        if (adType) {
            if ([adType isEqualToString:@"html"]) {
                _adType = WebView;
                _fullscreen = (NSNumber *)[[_adInfo objectForKey:FrameResponseAd_Fullscreen] retain];
                _htmlContent = [[_adInfo objectForKey:FrameResponseAd_HtmlContent] retain];
            } else if ([adType isEqualToString:@"video"]) {
                if ([[_adInfo objectForKey:FrameResponseAd_AdProvider] isEqualToString:@"AdColony"]) {
                    [PNLogger log:PNLogLevelWarning format:@"Setting ad type to AdColony"];
                    _adType = AdColony;
                } else {
                    _adType = Video;
                }
                _viewUrl = [[_adInfo objectForKey:FrameResponseAd_VideoViewUrl] retain];
            } else if ([adType isEqualToString:@"image"]) {
                _adType = Image;
            } else {
                _adType = AdUnknown;
                [PNLogger log:PNLogLevelWarning format:@"Encountered Unknown AdType %@", adType];
            }
        } else {
            _adType = Image;
        }
    }
    
    _closeButtonType = [self toCloseButtonType:[frameResponse objectForKey:FrameResponseAd_CloseButtonType]];
    _closeButtonLink = [[frameResponse objectForKey:FrameResponseAd_CloseButtonLink] retain];
    _closeButtonInfo = [frameResponse objectForKey:FrameResponseCloseButtonInfo];
    if(_closeButtonInfo){
        _closeButtonImageUrl = [[self getImageFromProperties:_closeButtonInfo] retain];
        if (_closeButtonImageUrl != nil) {
            _closeButtonDimensions = [self getViewDimensions:_closeButtonInfo];
        }
    }
}

-(CGRect) backgroundDimensions{
    return [self getViewDimensions:_backgroundInfo];
}


-(CGRect) getViewDimensions:(NSDictionary*) componentInfo {
    float height = [self getFloatValue:[componentInfo objectForKey:FrameResponseHeight]];
    float width = [self getFloatValue:[componentInfo objectForKey:FrameResponseWidth]];
    
    NSDictionary *coordinateProps = [self extractCoordinateProps:componentInfo];
    float x = [self getFloatValue:[coordinateProps objectForKey:FrameResponseXOffset]];
    float y = [self getFloatValue:[coordinateProps objectForKey:FrameResponseYOffset]];
    CGRect rect = CGRectMake(x, y, width, height);
    return rect;
}

-(NSDictionary *) extractCoordinateProps:(NSDictionary*) componentInfo {
    // This is dumb, but the reason for this if statement is because ad and close components
    // both have the size and offset locations in the same dictionary whereas the background
    // component has the coordinates in a sub-dictionary called 'l' for landscape mode and
    // 'p' for portrait mode. This is also because the ad and close components are offsets to
    // the background image whereas the background is just a raw location
    if ([componentInfo objectForKey:FrameResponseBackground_Landscape] == nil) {
        return componentInfo;
    }
    
    // By default, return portrait
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return [componentInfo objectForKey:FrameResponseBackground_Portrait];
    } else if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        return [componentInfo objectForKey:FrameResponseBackground_Landscape];
    } else {
        return [componentInfo objectForKey:FrameResponseBackground_Portrait];
    }
}

-(float) getFloatValue:(NSNumber *) n {
    @try {
        return [n floatValue];
    }
    @catch (NSException * exception) {
        //
    }
    return 0;
}

-(NSString *) getImageFromProperties: (NSDictionary *) properties{
    NSString *imageUrl = [properties objectForKey:FrameResponseImageUrl];
    if(imageUrl == nil || imageUrl == (id)[NSNull null] ){
        return nil;
    }
    return imageUrl;
}

-(NSDictionary *) getJSONTargetData{
    if( !(_targetType == AdTargetData && _clickTargetData) ){
        return nil;
    }
    return [PNUtil deserializeJsonString: _clickTargetData];
}

-(AdAction) toAdAction:(NSString*) actionUrl {
    if(actionUrl == (id)[NSNull null]){
        return AdActionNullTarget;
    }
    if([PNUtil isUrl: actionUrl]){
        return AdActionHTTP;
    }
    return AdActionUnknown;
}

-(AdTarget) toAdTarget:(NSString *) adTargetType {
    if(adTargetType == (id)[NSNull null]){
        return AdTargetUnknown;
    }
    if([adTargetType isEqualToString: @"data"]){
        return AdTargetData;
    }
    if([adTargetType isEqualToString:@"url"]){
        return AdTargetUrl;
    }
    if([adTargetType isEqualToString:@"external"]){
        return AdTargetExternal;
    }
    return AdTargetUnknown;
}

-(CloseButtonType) toCloseButtonType:(NSString *) closeButtonType{
    if(closeButtonType == (id)[NSNull null]){
        return CloseButtonUnknown;
    }
    
    if([closeButtonType isEqualToString:@"html"]){
        return CloseButtonHtml;
    }
    
    if([closeButtonType isEqualToString:@"native"]){
        return CloseButtonNative;
    }
    
    return CloseButtonUnknown;
}

@end

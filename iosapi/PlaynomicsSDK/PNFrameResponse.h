//
//  PNFrameResponse.h
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/9/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    AdColony,
    Image,
    Video,
    WebView,
    AdUnknown
} AdType;

typedef enum{
    CloseButtonHtml,
    CloseButtonNative,
    CloseButtonUnknown
}CloseButtonType;
//we should just make this into CGRect, no point in having our own type definition

@interface PNFrameResponse : NSObject

@property (readonly) NSDictionary* backgroundInfo;
@property (readonly) CGRect backgroundDimensions;
@property (readonly) NSString* backgroundImageUrl;

@property (readonly) NSDictionary* adInfo;
@property (readonly) CGRect adDimensions;
@property (readonly) AdType adType;
@property (readonly) NSNumber* fullscreen;
@property (readonly) NSString* htmlContent;
@property (readonly) NSString* primaryImageUrl;

@property (readonly) NSString* clickUrl;
@property (readonly) NSString* clickLink;

@property (readonly) NSString* clickTargetData;
@property (readonly) NSString* clickTargetUrl;
@property (readonly) NSString* impressionUrl;
@property (readonly) NSString* closeUrl;
@property (readonly) NSString* viewUrl;


@property (readonly) AdTarget targetType;
@property (readonly) AdAction actionType;

@property (readonly) CloseButtonType closeButtonType;
@property (readonly) NSString* closeButtonLink;

@property (readonly) NSDictionary* closeButtonInfo;
@property (readonly) NSString* closeButtonImageUrl;
@property (readonly) CGRect closeButtonDimensions;

- (id) initWithJSONData:(NSData *) jsonData;

- (NSDictionary *) getJSONTargetData;
@end

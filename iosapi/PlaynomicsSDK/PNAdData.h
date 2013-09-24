//
//  PNAdInfo.h
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/24/13.
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

@interface PNBackground : NSObject
@property (assign) CGRect landscapeDimensions;
@property (assign) CGRect portraitDimensions;
@property (retain) NSString *imageUrl;
@end

@interface PNAd : NSObject

@property (assign) CGRect dimensions;

@property (retain) NSString *closeUrl;

@property (retain) NSString *impressionUrl;

@property (retain) NSString *clickUrl;
@property (retain) NSDictionary *targetData;
@property (readonly) AdTarget targetType;
@property (readonly) AdAction actionType;

@property (assign) BOOL fullscreen;
@end

@interface PNHtmlAd : PNAd
@property (retain) NSString *htmlContent;
@property (retain) NSString *clickLink;
@end

@interface PNStaticAd : PNAd
@property (retain) NSString *imageUrl;
@end

@interface PNCloseButton : NSObject
@property (assign) CGRect dimensions;
@end

@interface PNNativeCloseButton : PNCloseButton
@property (retain) NSString *imageUrl;
@end

@interface PNHtmlCloseButton : PNCloseButton
@property (assign) CGRect closeButtonLink;
@end
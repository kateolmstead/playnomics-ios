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

//we should just make this into CGRect, no point in having our own type definition
typedef struct {
    float width;
    float height;
    float x;
    float y;
} PNViewDimensions;


@interface PNFrameResponse : NSObject

@property (readonly) NSDictionary* backgroundInfo;
@property (readonly) PNViewDimensions backgroundDimensions;
@property (readonly) NSString* backgroundImageUrl;

@property (readonly) NSDictionary* adInfo;
@property (readonly) PNViewDimensions adDimensions;
@property (readonly) AdType adType;
@property (readonly) NSNumber* fullscreen;
@property (readonly) NSString* htmlContent;
@property (readonly) NSString* primaryImageUrl;
@property (readonly) NSString* rolloverImageUrl;
@property (readonly) NSString* tooltipText;

@property (readonly) NSString* clickTarget;
@property (readonly) NSString* clickTargetData;

@property (readonly) NSString* preClickUrl;
@property (readonly) NSString* postClickUrl;
@property (readonly) NSString* impressionUrl;
@property (readonly) NSString* flagUrl;
@property (readonly) NSString* closeUrl;
@property (readonly) NSString* viewUrl;

@property (readonly) AdTarget targetType;
@property (readonly) AdAction actionType;


@property (readonly) NSDictionary* closeButtonInfo;
@property (readonly) NSString* closeButtonImageUrl;
@property (readonly) PNViewDimensions closeButtonDimensions;

- (id) initWithJSONData:(NSData *) jsonData;

- (NSDictionary *) getJSONTargetData;
@end

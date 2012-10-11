//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame.h"
#import "PNUtil.h"
#import "FSNConnection.h"


#pragma mark - Base ad component:  UI + properties
@interface BaseAdComponent : NSObject<NSURLConnectionDelegate>

@property (retain) NSDictionary *properties;
@property (retain) UIImageView *imageUI;
@property (retain) NSString *imageUrl;
@property (retain) BaseAdComponent *parentComponent;
@property (retain) PlaynomicsFrame *frame;

@property float xOffset;
@property float yOffset;
@property float height;
@property float width;
@property SEL touchHandler;

- (id)initWithProperties:(NSDictionary *)aProperties
                forFrame:(PlaynomicsFrame *)aFrame
        withTouchHandler:(SEL)aTouchHandler;
- (id)layoutComponent;
- (id)addSubComponent:(BaseAdComponent*)subView;
- (void)display;
- (void)hide;

@end


@implementation BaseAdComponent {
  @private
    NSMutableArray *_subComponents;
}

@synthesize properties = _properties;
@synthesize imageUI = _imageUI;
@synthesize imageUrl = _imageUrl;
@synthesize parentComponent = _parentComponent;
@synthesize frame = _frame;
@synthesize xOffset = _xOffset;
@synthesize yOffset = _yOffset;
@synthesize height = _height;
@synthesize width = _width;
@synthesize touchHandler = _touchHandler;

#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)aProperties
                forFrame:(PlaynomicsFrame *)aFrame
        withTouchHandler:(SEL)aTouchHandler {
    self = [super init];
    if (self) {
        NSLog(@"Creating ad component with properties: %@", aProperties);
        _subComponents = [NSMutableArray array];
        _properties = [aProperties retain];
        _frame = [aFrame retain];
        _touchHandler = aTouchHandler;
    }
    return self;
}

- (void)dealloc {
    [_subComponents release];
    [_properties release];
    [_imageUI release];
    [_imageUrl release];
    [_parentComponent release];
    [_frame release];
    [super dealloc];
}

#pragma mark - Public Interface
- (void)layoutComponent {
    [self _initCoordinateValues];
    [self _createBackgroundUI];
    [self _setupTapRecognizer];
    [self.imageUI setNeedsDisplay];
}

- (void)_initCoordinateValues {
    self.imageUrl = [self.properties objectForKey:FrameResponseImageUrl];
    self.height = [[self.properties objectForKey:FrameResponseHeight] floatValue];
    self.width = [[self.properties objectForKey:FrameResponseWidth] floatValue];

    NSDictionary *coordinateProps = [self _extractCoordinateProps];
    self.xOffset = [[coordinateProps objectForKey:FrameResponseXOffset] floatValue];
    self.yOffset = [[coordinateProps objectForKey:FrameResponseYOffset] floatValue];
}

- (NSDictionary *)_extractCoordinateProps {
    if ([self.properties objectForKey:FrameResponseBackground_Landscape] == nil) {
        return self.properties;
    }

    UIDeviceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == 0 || orientation == UIDeviceOrientationPortrait) {
        return [self.properties objectForKey:FrameResponseBackground_Portrait];
    } else {
        return [self.properties objectForKey:FrameResponseBackground_Landscape];
    }
}

- (void)_createBackgroundUI {
    CGRect backgroundRect = CGRectMake(self.xOffset, self.yOffset, self.width, self.height);
    NSLog(@"Frame for component image view (%@): %@", self.imageUrl, NSStringFromCGRect(backgroundRect));
    UIImage *image = [self _loadImage];

    if (self.imageUI == nil) {
        UIImageView *newImageView = [[UIImageView alloc] init];
        newImageView.userInteractionEnabled = YES;

        self.imageUI = newImageView;
        [newImageView release];
    }

    self.imageUI.frame = backgroundRect;
    if (image) {
        [self.imageUI setImage:image];
    }
}

- (UIImage *)_loadImage {
    NSURL *url = [NSURL URLWithString:self.imageUrl];
    NSError *error = nil;

    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error) {
        NSLog(@"Error occurred retrieving image from URL '%@': %@", self.imageUrl, error.description);
        return nil;
    }
    return [UIImage imageWithData:imageData];
}

-(void)_setupTapRecognizer {
    if (self.touchHandler != nil) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.frame action:self.touchHandler];
        [self.imageUI addGestureRecognizer:tap];
    }
}

- (void)addSubComponent:(BaseAdComponent *)subComponent {
    subComponent.parentComponent = self;
    [_subComponents addObject:subComponent];
    [self.imageUI addSubview:subComponent.imageUI];
}

- (void)display {
    UIView *topLevelView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    int lastDisplayIndex = topLevelView.subviews.count;
    [topLevelView insertSubview:self.imageUI atIndex:lastDisplayIndex + 1];
}

- (void)hide {
    [self.imageUI removeFromSuperview];
}

@end


#pragma mark - PlaynomicsFrame
typedef NS_ENUM(NSInteger, AdAction) {
    AdActionHTTP,            // Standard HTTP/HTTPS page to open in a browser
    AdActionDefinedAction,   // Defined selector to execute on a registered delegate
    AdActionExecuteCode,     // Submit the action on the delegate
    AdActionUnknown          // Unknown ad action specified
};


const NSString *HTTP_ACTION_PREFIX = @"http";
const NSString *HTTPS_ACTION_PREFIX = @"https";


@implementation PlaynomicsFrame {
  @private
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    UIDeviceOrientation _currentOrientation;

    FSNConnection *_adImpressionConnection;
}

@synthesize frameId;


#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)aFrameId {
    if (self = [super init]) {
        self.frameId = aFrameId;
        _properties = [properties retain];

        [self _initOrientationChangeObservers];
        [self _initAdComponents];
        [self _initAdImpressionConnection];
    }
    return self;
}

- (void)dealloc {
    [_properties release];
    [_background release];
    [_adArea release];
    [_closeButton release];
    [_adImpressionConnection release];

    [super dealloc];
}


- (void)_initAdComponents {
    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo]
                                                     forFrame:self
                                             withTouchHandler:nil];

    _adArea = [[BaseAdComponent alloc] initWithProperties:[self _mergeAdInfoProperties]
                                                 forFrame:self
                                         withTouchHandler:@selector(_adClicked)];

    _closeButton = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseCloseButtonInfo]
                                                      forFrame:self
                                              withTouchHandler:@selector(_stop)];

    [_background layoutComponent];
    [_adArea layoutComponent];
    [_closeButton layoutComponent];

    [_background addSubComponent:_adArea];
    [_background addSubComponent:_closeButton];
}

- (NSDictionary *)_mergeAdInfoProperties {
    NSDictionary *adInfo = [self _determineAdInfoToUse];
    NSDictionary *adLocationInfo = [_properties objectForKey:FrameResponseAdLocationInfo];

    NSMutableDictionary *mergedDict = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [mergedDict addEntriesFromDictionary:adLocationInfo];
    return mergedDict;
}

- (NSDictionary *)_determineAdInfoToUse {
    return [[_properties objectForKey:FrameResponseAds] objectAtIndex:0];
}

- (void)_initAdImpressionConnection {
    NSString *impressionUrl = [_adArea.properties objectForKey:FrameResponseAd_ImpressionUrl];
    NSURL *url = [NSURL URLWithString:impressionUrl];
    NSLog(@"Submitting GET request to impression URL: %@", impressionUrl);

    FSNConnection *connection =
            [FSNConnection withUrl:url
                            method:FSNRequestMethodGET
                           headers:nil
                        parameters:nil
                        parseBlock:^id(FSNConnection *c, NSError **error) {
                            return [c.responseData stringFromUTF8];
                        }
                   completionBlock:^(FSNConnection *c) {
                       NSLog(@"Impression URL complete: error: %@, result: %@", c.error, c.parseResult);
                   }
                     progressBlock:nil];

    _adImpressionConnection = connection;
}


#pragma mark - Orientation handlers
- (void)_initOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void)_destroyOrientationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)_deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation *orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIDeviceOrientationFaceUp
            || orientation == UIDeviceOrientationFaceDown
            || orientation == UIDeviceOrientationUnknown
            || _currentOrientation == orientation) {
        return;
    }
    _currentOrientation = orientation;

    NSLog(@"Orientation changed to: %i", orientation);
    [_background layoutComponent];
}


#pragma mark - Ad component click handlers
- (void)_stop {
    NSLog(@"Close button was pressed...");
    [_background hide];
    [self _destroyOrientationObservers];
}

- (void)_adClicked {
    NSString *clickTarget = [_adArea.properties objectForKey:FrameResponseAd_ClickTarget];
    AdAction actionType = [self _determineActionType:clickTarget];
    NSLog(@"Ad clicked with target (action type %i): %@", actionType, clickTarget);

    switch (actionType) {
        case AdActionHTTP: {
            NSURL *clickTargetUrl = [NSURL URLWithString:clickTarget];
            [[UIApplication sharedApplication] openURL:clickTargetUrl];
            break;
        }
        default: {
            NSLog(@"Unsupported ad action specified!");
            break;
        }
    }

}

- (AdAction)_determineActionType: (NSString *)actionUrl {
    if ([actionUrl hasPrefix:HTTP_ACTION_PREFIX] || [actionUrl hasPrefix:HTTPS_ACTION_PREFIX]) {
        return AdActionHTTP;
    } else {
        return AdActionUnknown;
    }
}

#pragma mark - Public Interface
- (void)start {
    [_background display];
    [_adImpressionConnection start];
}

@end
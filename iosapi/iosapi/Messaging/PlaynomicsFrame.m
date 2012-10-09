//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame.h"
#import "PNUtil.h"


#pragma mark - Base ad component:  UI + properties
@interface BaseAdComponent : NSObject<NSURLConnectionDelegate>

@property NSDictionary *properties;
@property UIImageView *imageUI;
@property NSString *imageUrl;
@property BaseAdComponent *parentComponent;
@property float xOffset;
@property float yOffset;
@property float height;
@property float width;
@property PlaynomicsFrame *frame;
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

@synthesize properties;
@synthesize imageUI;
@synthesize imageUrl;
@synthesize xOffset;
@synthesize yOffset;
@synthesize height;
@synthesize width;
@synthesize parentComponent;
@synthesize frame;
@synthesize touchHandler;

#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)aProperties
                forFrame:(PlaynomicsFrame *)aFrame
        withTouchHandler:(SEL)aTouchHandler {
    self = [super init];
    if (self) {
        NSLog(@"Creating ad component with properties: %@", aProperties);
        _subComponents = [[NSMutableArray array] retain];
        self.properties = [aProperties retain];
        self.frame = aFrame;
        self.touchHandler = aTouchHandler;

        [self layoutComponent];
        [self _setupTapRecognizer];
    }
    return self;
}

- (void)dealloc {
    [_subComponents release];
    [self.properties release];
    [super dealloc];
}

-(void)_setupTapRecognizer {
    if (self.touchHandler != nil) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.frame action:self.touchHandler];
        [self.imageUI addGestureRecognizer:tap];
    }
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
        self.imageUI = [[[UIImageView alloc] init] retain];
        self.imageUI.userInteractionEnabled = YES;
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


#pragma mark - Public Interface
- (void)layoutComponent {
    [self _initCoordinateValues];
    [self _createBackgroundUI];

    for (BaseAdComponent *subComponent in _subComponents) {
        [subComponent layoutComponent];
    }

    [self.imageUI setNeedsDisplay];
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


#pragma mark - PlaynomicsFrame implementation
@implementation PlaynomicsFrame {
  @private
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    UIDeviceOrientation _currentOrientation;
}

@synthesize frameId;


#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)aFrameId {
    if (self = [super init]) {
        self.frameId = aFrameId;
        _properties = [properties retain];

        [self _setupOrientationChangeObservers];
        [self _initAdComponents];
    }
    return self;
}

- (void)dealloc {
    [_properties release];
    [super dealloc];
}

#pragma mark - Orientation handlers
- (void)_setupOrientationChangeObservers {
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

    [_background addSubComponent:_adArea];
    [_background addSubComponent:_closeButton];
}

- (NSDictionary *)_mergeAdInfoProperties {
    NSDictionary *adInfo = [[_properties objectForKey:FrameResponseAds] objectAtIndex:0];
    NSDictionary *adLocationInfo = [_properties objectForKey:FrameResponseAdLocationInfo];

    NSMutableDictionary *mergedDict = [NSMutableDictionary dictionaryWithDictionary:adInfo];
    [mergedDict addEntriesFromDictionary:adLocationInfo];
    return mergedDict;
}


#pragma mark - Ad component click handlers
- (void)_stop {
    NSLog(@"Close button was pressed...");
    [_background hide];
    [self _destroyOrientationObservers];
}

- (void)_adClicked {
    NSLog(@"Ad was clicked...");
}


#pragma mark - Public Interface
- (void)start {
    [_background display];
}



@end
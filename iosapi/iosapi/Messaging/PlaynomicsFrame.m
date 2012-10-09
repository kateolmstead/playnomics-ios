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

- (id)initWithProperties:(NSDictionary *)properties;
- (id)layoutComponent;
- (id)addSubComponent:(BaseAdComponent*)subView;
- (void)display;

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

- (id)initWithProperties:(NSDictionary *)aProperties {
    self = [super init];
    if (self) {
        NSLog(@"Creating ad component with properties: %@", aProperties);
        _subComponents = [[NSMutableArray array] retain];
        self.properties = [aProperties retain];
        [self layoutComponent];
    }
    return self;
}

- (void)dealloc {
    [_subComponents release];
    [self.properties release];
    [super dealloc];
}

- (void)layoutComponent {
    [self _initCoordinateValues];
    [self _createBackgroundUI];

    for (BaseAdComponent *subComponent in _subComponents) {
        [subComponent layoutComponent];
    }

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
        self.imageUI = [[[UIImageView alloc] init] retain];
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

@end


@implementation PlaynomicsFrame {
  @private
    NSDictionary *_properties;
    BaseAdComponent *_background;
    BaseAdComponent *_adArea;
    BaseAdComponent *_closeButton;
    UIDeviceOrientation _currentOrientation;
}

@synthesize frameId;

- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)aFrameId {
    if (self = [super init]) {
        self.frameId = aFrameId;
        _properties = [properties retain];

        [self _setupOrientationChangeObservers];
        [self _initAdComponents];
    }
    return self;
}

- (void)_setupOrientationChangeObservers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object: nil];
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

- (void)dealloc {
    [_properties release];
    [super dealloc];
}
- (void)_initAdComponents {
    NSDictionary *adAreaInfo = [self _mergeAdInfoProperties];

    _background = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo]];
    _adArea = [[BaseAdComponent alloc] initWithProperties:adAreaInfo];
    _closeButton = [[BaseAdComponent alloc] initWithProperties:[_properties objectForKey:FrameResponseCloseButtonInfo]];

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

- (void)start {
    [_background display];
}



@end
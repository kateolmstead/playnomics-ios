//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BaseAdComponent.h"
#import "PNUtil.h"


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
        _subComponents = [[NSMutableArray array] retain];
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
    if (orientation == UIDeviceOrientationUnknown || UIDeviceOrientationIsPortrait(orientation)) {
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
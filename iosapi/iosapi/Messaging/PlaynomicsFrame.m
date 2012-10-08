//
// Created by jmistral on 10/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PlaynomicsFrame.h"
#import "PNConstants.h"

#pragma mark - Sub-View Interfaces
@interface BaseAdComponent : NSObject<NSURLConnectionDelegate>

@property NSDictionary *properties;
@property UIImageView *imageUI;
@property NSString *imageUrl;
@property float xOffset;
@property float yOffset;
@property float height;
@property float width;

- (id)initWithProperties:(NSDictionary *)properties;
- (void)display;

@end


@interface AdArea : BaseAdComponent
@end


@interface Background : BaseAdComponent
@property AdArea *adArea;
@end


#pragma mark - Sub-View Implementations
@implementation BaseAdComponent

@synthesize properties;
@synthesize imageUI;
@synthesize imageUrl;
@synthesize xOffset;
@synthesize yOffset;
@synthesize height;
@synthesize width;

- (id)initWithProperties:(NSDictionary *)aProperties {
    self = [super init];
    if (self) {
        self.properties = [aProperties retain];
        [self _initCoordinateValues];
        [self _createBackgroundUI];
    }
    return self;
}

- (void)_initCoordinateValues {
    self.xOffset = [[self.properties objectForKey:FrameResponseXOffset] floatValue];
    self.yOffset = [[self.properties objectForKey:FrameResponseYOffset] floatValue];

    self.height = [[self.properties objectForKey:FrameResponseHeight] floatValue];
    self.width = [[self.properties objectForKey:FrameResponseWidth] floatValue];
    self.imageUrl = [self.properties objectForKey:FrameResponseImageUrl];
}

- (void)_createBackgroundUI {
    CGRect backgroundRect = CGRectMake(self.xOffset, self.yOffset, self.width, self.height);
    UIImage *image = [self _loadImage];
    NSLog(@"Creating background image UI: [%@] %@", self.imageUrl, backgroundRect);

    self.imageUI = [[[UIImageView alloc] initWithFrame:backgroundRect] retain];
    if (image) {
        [self.imageUI setImage:image];
        [image release];
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

- (void)display {
    // Should be overriden by sub-classes
}

@end


@implementation Background

@synthesize adArea;

- (void)display {
    UIView *topLevelView = [[UIApplication sharedApplication] keyWindow];
    int lastDisplayIndex = topLevelView.subviews.count;
    [topLevelView insertSubview:self.imageUI atIndex:lastDisplayIndex + 1];
}

@end


#pragma mark - Frame Implementation
@implementation PlaynomicsFrame {
  @private
    NSDictionary *_properties;
    Background *_background;
    AdArea *_adArea;
}

@synthesize frameId;

#pragma mark - Initialization
- (id)initWithProperties:(NSDictionary *)properties forFrameId:(NSString *)aFrameId {
    if (self = [super init]) {
        self.frameId = aFrameId;
        _properties = properties;
        [self _initBackground];
    }
    return self;
}

- (void)_initBackground {
    _background = [[Background alloc] initWithProperties:[_properties objectForKey:FrameResponseBackgroundInfo]];
}

- (void)start {
    [_background display];
}

@end
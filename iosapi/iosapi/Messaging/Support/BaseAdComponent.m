//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "BaseAdComponent.h"
#import "FSNConnection.h"
#import "PNUIImageView.h"

@implementation BaseAdComponent {
@private
    NSMutableArray *_subComponents;
    id<BaseAdComponentDelegate> _delegate;
    PNUIImageView* _imageUI;
}

@synthesize properties = _properties;
@synthesize imageUI = _imageUI;
@synthesize parentComponent = _parentComponent;
@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
- (id)initWithProperties:(NSDictionary *)properties delegate:(id<BaseAdComponentDelegate>)delegate {
    self = [super init];
    if (self) {
        NSLog(@"Creating ad component with properties: %@", properties);
        _subComponents = [[NSMutableArray array] retain];
        _properties = [properties retain];
        _status = AdComponentStatusPending;
        _delegate = delegate;
        
        [self renderComponent];
    }
    return self;
}

- (void)dealloc {
    [_subComponents release];
    [_properties release];
    [_imageUI release];
    //just set assign references to nil
    _delegate = nil;
    _parentComponent = nil;
    [super dealloc];
}

#pragma mark - Public Interface
- (void)renderComponent {
    PNViewDimensions dimensions = [self getViewDimensions];
    [self _createComponentViewWithDimensions: dimensions];
}

- (PNViewDimensions) getViewDimensions{
    float height = [self getFloatValue:[self.properties objectForKey:FrameResponseHeight]];
    float width = [self getFloatValue:[self.properties objectForKey:FrameResponseWidth]];
    
    NSDictionary *coordinateProps = [self extractCoordinateProps];
    float x = [self getFloatValue:[coordinateProps objectForKey:FrameResponseXOffset]];
    float y = [self getFloatValue:[coordinateProps objectForKey:FrameResponseYOffset]];
    
    PNViewDimensions dimensions = {.width = width, .height = height, .x = x, .y = y};
    return dimensions;
}

- (NSDictionary *) extractCoordinateProps {
    if ([self.properties objectForKey:FrameResponseBackground_Landscape] == nil) {
        return self.properties;
    }
    
    // By default, return portrait
    UIInterfaceOrientation orientation = [PNUtil getCurrentOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return [self.properties objectForKey:FrameResponseBackground_Portrait];
    } else if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        return [self.properties objectForKey:FrameResponseBackground_Landscape];
    } else {
        return [self.properties objectForKey:FrameResponseBackground_Portrait];
    }
}

- (float)getFloatValue:(NSNumber*)n {
    @try {
        return [n floatValue];
    } @catch (NSException * exception) {
        //
    }
    return 0;
}

- (void)_createComponentViewWithDimensions :(PNViewDimensions) dimensions {
    CGRect frame = CGRectMake(dimensions.x, dimensions.y, dimensions.width, dimensions.height);
    
    if (self.imageUI == nil) {
        NSString* imageUrl = [BaseAdComponent getImageFromProperties:self.properties];
        if(imageUrl == nil){
            _imageUI = [[PNUIImageView alloc] initWithFrame:frame delegate: self];
        } else {
            _imageUI = [[PNUIImageView alloc] initWithFrame:frame delegate: self imageUrl: imageUrl];
        }
    } else{
        self.imageUI.frame = frame;
    }
}


- (void)addSubComponent:(BaseAdComponent *)subComponent {
    subComponent.parentComponent = self;
    [_subComponents addObject:subComponent];
    [self.imageUI addSubview:subComponent.imageUI];
}

- (void)hide {
    [self.imageUI removeFromSuperview];
}


-(void) didLoad{
    _status = AdComponentStatusCompleted;
    [self.delegate componentDidLoad: self];
}

-(void) didFailToLoad{
    _status = AdComponentStatusError;
    [self.delegate componentDidFailToLoad: self];
}

-(void) didFailToLoadWithError: (NSError*) error{
    [self didFailToLoad];
}

-(void) didFailToLoadWithException: (NSException*) exception{
    [self didFailToLoad];
}

-(void) didReceiveTouch: (UITouch*) touch{
    [self.delegate componentDidReceiveTouch:self touch:touch];
}

+ (NSString*) getImageFromProperties: (NSDictionary*) properties{
    NSString* imageUrl = [properties objectForKey:FrameResponseImageUrl];
    if(imageUrl == nil || imageUrl == (id)[NSNull null] ){
        return nil;
    }
    return imageUrl;
}

@end
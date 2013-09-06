//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PNViewComponent.h"
#import "FSNConnection.h"
#import "PNImage.h"

@implementation PNViewComponent {
@private
    NSMutableArray *_subComponents;
}

@synthesize delegate = _delegate;
@synthesize imageUrl = _imageUrl;
@synthesize parentComponent = _parentComponent;
@synthesize status = _status;

#pragma mark - Lifecycle/Memory management
-(id)initWithDimensions:(PNViewDimensions) dimensions delegate:(id<PNViewComponentDelegate>) delegate image:(NSString*) imageUrl {
    CGRect frame = CGRectMake(dimensions.x, dimensions.y, dimensions.width, dimensions.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setUserInteractionEnabled: YES];
        [self setExclusiveTouch: YES];
        _delegate = delegate;
        _status = AdComponentStatusPending;
        
        if (imageUrl != nil && imageUrl != (id)[NSNull null]) {
            _imageUrl = [imageUrl copy];
            [self loadImage];
        } else {
            [self didLoad];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_subComponents release];
    //just set assign references to nil
    _delegate = nil;
    _parentComponent = nil;
    _imageUrl = nil;
    [super dealloc];
}

#pragma mark - Public Interface
-(void) loadImage {
    //load the image here
    NSURL* url = [NSURL URLWithString:_imageUrl];
    
    if (url == nil) {
        [self didFailToLoadWithException:nil];
        return;
    }
    
    NSLog(@"Loading image from %@", _imageUrl);
    FSNConnection* connection =[FSNConnection withUrl:url
                                               method:FSNRequestMethodGET
                                              headers:nil
                                           parameters:nil
                                           parseBlock:nil
                                      completionBlock:^(FSNConnection *c) { [self onImageDownloaded:c]; }
                                        progressBlock:nil];
    
    [connection start];
}

-(void) onImageDownloaded:(FSNConnection *)connection {
    if (connection.error) {
        NSLog(@"Error retrieving image from the internet: %@", connection.error.localizedDescription);
        [self didFailToLoadWithError: connection.error];
    } else {
        self.image = [UIImage imageWithData:connection.responseData];
        [self didLoad];
    }
}


- (void) addSubComponent:(PNViewComponent *)subComponent {
    subComponent.parentComponent = self;
    [_subComponents addObject:subComponent];
    [self addSubview:subComponent];
}

- (void)hide {
    [self removeFromSuperview];
}


#pragma mark "Delegate Handlers"
-(void) didLoad{
    _status = AdComponentStatusCompleted;
    [self.delegate componentDidLoad];
}

-(void) didFailToLoadWithError: (NSError*) error{
    _status = AdComponentStatusError;
    [self.delegate componentDidFailToLoadWithError: error];
}

-(void) didFailToLoadWithException: (NSException*) exception{
    _status = AdComponentStatusError;
    [self.delegate componentDidFailToLoadWithException: exception];
}

#pragma mark "Touch Events"
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSEnumerator *enumerator = [touches objectEnumerator];
    id value;
    if ((value = [enumerator nextObject]) && [value isKindOfClass:[UITouch class]]) {
        [self.delegate component:self
                 didReceiveTouch:(UITouch*)value];
    }
}

@end
//
// Created by jmistral on 10/16/12.
//
// To change the template use AppCode | Preferences | File Templates.
//
#import "PNViewComponent.h"
#import "PNImage.h"

@implementation PNViewComponent {
@private
    NSMutableArray *_subComponents;
    PNAssetRequest *_request;
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
            if ([PNUtil isUrl:_imageUrl]) {
                [self loadImage];
            } else {
                self.image = [UIImage imageNamed:_imageUrl];
                [self didLoad];
            }
        } else {
            [self didLoad];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_subComponents release];
    
    if(_request){
        [_request cancel];
        [_request release];
    }
    
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
    _request = [[PNAssetRequest alloc] initWithUrl:_imageUrl delegate:self useHttpCache:YES];
    [_request start];
}

-(void) connectionDidFail{
    [PNLogger log:PNLogLevelWarning format:@"Could not create a connection when retreiving asset %@", _imageUrl];
    [self didFailToLoad];
}

-(void) requestDidCompleteWithData:(NSData *)data{
    [PNLogger log:PNLogLevelDebug format:@"Successfully loaded image asset %@", _imageUrl];
    self.image = [UIImage imageWithData: data];
    [self didLoad];
}

-(void) requestDidFailtWithStatusCode:(int)statusCode{
    [PNLogger log:PNLogLevelWarning format:@"Could not load image asset %@, received status code %@", _imageUrl, [NSHTTPURLResponse localizedStringForStatusCode: statusCode]];
}

-(void) requestDidFailWithError:(NSError *)error{
    [PNLogger log:PNLogLevelWarning error:error format:@"Could not load image asset %@", _imageUrl];
}

- (void) addSubComponent:(PNViewComponent *)subComponent {
    subComponent.parentComponent = self;
    [_subComponents addObject:subComponent];
    [self addSubview:subComponent];
}

- (void) hide{
    [self removeFromSuperview];
}

#pragma mark "Delegate Handlers"
-(void) didLoad{
    _status = AdComponentStatusCompleted;
    [self.delegate componentDidLoad];
}

-(void) didFailToLoad{
    [self.delegate componentDidFailToLoad];
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
        [self.delegate component:self didReceiveTouch:(UITouch *) value];
    }
}

@end
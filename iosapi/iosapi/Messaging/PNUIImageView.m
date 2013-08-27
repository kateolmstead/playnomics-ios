//
//  PNUIImageView.m
//  iosapi
//
//  Created by Jared Jenkins on 8/15/13.
//
//

#import "PNUIImageView.h"
#import "FSNConnection.h"

@implementation PNUIImageView

@synthesize imageUrl = _imageUrl;
@synthesize delegate = _delegate;

-(id) initWithFrame: (CGRect) frame delegate: (id<PNUIImageDelegate>) delegate{
    self = [super initWithFrame:frame];
    if(self){
        [self setUserInteractionEnabled: YES];
        [self setExclusiveTouch: YES];
        _delegate = delegate;
        //no image to load this component is ready to go
        [self.delegate didLoad];
    }
    return self;
}

-(id) initWithFrame: (CGRect) frame delegate: (id<PNUIImageDelegate>) delegate imageUrl: (NSString*) imageUrl{
    self = [super initWithFrame:frame];
    if(self){
        [self setUserInteractionEnabled: YES];
        [self setExclusiveTouch: YES];
        _delegate = delegate;
        if(imageUrl != nil && imageUrl != (id)[NSNull null] ){
            _imageUrl = [imageUrl copy];
            [self loadImage];
        } else{
            //no image to load this component is ready to go
            [self.delegate didLoad];
        }
    }
    return self;
}

-(void)dealloc{
    [_imageUrl release];
    _delegate = nil;
    [super dealloc];
}

#pragma mark "Load Images"
-(void)loadImage{
    //load the image here
    NSURL* url = [NSURL URLWithString:self.imageUrl];
    
    if (url == nil){
        [self.delegate didFailToLoadWithException:nil];
        return;
    }
    //connection library is written with ARC, no need to dealloc?
    FSNConnection* connection =[FSNConnection withUrl:url
                                               method:FSNRequestMethodGET
                                              headers:nil
                                           parameters:nil
                                           parseBlock:nil
                                      completionBlock:^(FSNConnection *c) { [self onImageDownloaded:c]; }
                                        progressBlock:nil];
    
    [connection start];
}

- (void)onImageDownloaded:(FSNConnection *)connection {
    if (connection.error) {
        //NSLog(@"Error retrieving image from the internet: %@", connection.error.localizedDescription);
        [self.delegate didFailToLoadWithError: connection.error];
    } else {
        self.image = [UIImage imageWithData:connection.responseData];
        [self.delegate didLoad];
    }
}

#pragma mark "Touch Events"
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSEnumerator *enumerator = [touches objectEnumerator];
    id value;
    if ((value = [enumerator nextObject]) && [value isKindOfClass:[UITouch class]]) {
        [self.delegate didReceiveTouch: (UITouch*)value];
    }
}
@end

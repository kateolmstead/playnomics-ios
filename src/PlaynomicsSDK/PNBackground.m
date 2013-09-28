#import "PNAdData.h"

@implementation PNBackground
@synthesize landscapeDimensions;
@synthesize portraitDimensions;
@synthesize imageUrl;

-(CGRect) dimensionsForCurrentOrientation{
    UIInterfaceOrientation currentOrientation = [PNUtil getCurrentOrientation];
    if(UIInterfaceOrientationIsLandscape(currentOrientation)){
        return self.landscapeDimensions;
    }
    return self.portraitDimensions;
}
@end

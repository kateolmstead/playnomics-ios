#import "PNAdData.h"

@implementation PNBackground
@synthesize landscapeDimensions;
@synthesize portraitDimensions;
@synthesize imageUrl;

-(CGRect) dimensionsForCurrentOrientation{
    UIInterfaceOrientation currentOrientation = [PNUtil getCurrentOrientation];
    if(currentOrientation & UIInterfaceOrientationMaskLandscape){
        return self.landscapeDimensions;
    }
    return self.portraitDimensions;
}
@end

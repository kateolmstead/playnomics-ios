#import <Foundation/Foundation.h>

@interface RandomGenerator : NSObject {
}

+ (void) initialize;
+ (NSArray *) getNextSecureRandom:(int)bits;
+ (NSString *) toHex:(NSArray *)bytes;
+ (NSString *) createRandomHex;
@end

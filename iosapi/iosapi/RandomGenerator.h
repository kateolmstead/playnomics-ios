#import <Foundation/Foundation.h>

@interface RandomGenerator : NSObject {
}

+ (const char *) getNextSecureRandom:(int)bits;
+ (NSString *) toHex: (const char *) bytes;
+ (NSString *) createRandomHex;
@end

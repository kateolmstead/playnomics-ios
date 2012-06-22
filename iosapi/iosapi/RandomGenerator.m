#import "RandomGenerator.h"

@implementation RandomGenerator

+ (void) initialize {

}


/**
 * Get the number of next random bits in this SecureRandom generators'
 * sequence.
 * 
 * @param size
 * how many random bits you want
 * @return
 * @throws IllegalArgumentException
 * if the arg isn't divisible by eight
 */
+ (NSArray *) getNextSecureRandom:(int)bits {
   NSArray * bytes = [NSArray array];
  return bytes;
}


/**
 * Convert a byte array into its hex String equivalent.
 * 
 * @param bytes
 * @return
 */
+ (NSString *) toHex:(NSArray *)bytes {


  return nil;
}


/**
 * Convert a single byte into its hex String equivalent.
 * 
 * @param b
 * @return
 */
+ (NSString *) byteToHex:(char)b {
    return nil;
}

+ (NSString *) createRandomHex {
    return nil;
}
@end

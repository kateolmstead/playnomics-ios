#import "RandomGenerator.h"

@implementation RandomGenerator

const char HEX_DIGIT[] = {
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

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
+ (const char *) getNextSecureRandom:(int)bits {
    if ((bits%8) != 0) {
        bits = bits - bits%8;
    }
    
    int count = (bits / 8);
    char *bytes = (char *) malloc((count + 1) * sizeof(char)); 
    
    for (int i = 0; i < count; i++) {
        *(bytes + i) = arc4random(); // We want the maximum range possible
    }
    *(bytes + count) = '\0';
    
    return bytes;
}


/**
 * Convert a byte array into its hex String equivalent.
 * 
 * @param bytes
 * @return
 */
+ (NSString *) toHex: (const char *) bytes {
    char *c = (char *) bytes;
    NSString *str = [NSString string];
    while (*c != '\0') {
        str = [str stringByAppendingFormat:@"%c%c", HEX_DIGIT[(*c >> 4) & 0x0f], HEX_DIGIT[*c & 0x0f]];
        c++;
    }
    return str;
}


/**
 * Convert a single byte into its hex String equivalent.
 * 
 * @param b
 * @return
 */
+ (NSString *) byteToHex:(char)b {
//    char array = { HEX_DIGIT[(b >> 4) & 0x0f], HEX_DIGIT[b & 0x0f] };
    
    return [NSString stringWithFormat:@"%x", b];
}

+ (NSString *) createRandomHex {
    const char * randBytes = [RandomGenerator getNextSecureRandom:64];
    NSString *str = [RandomGenerator toHex: randBytes];
    free((char *) randBytes);
    return str;
}
@end

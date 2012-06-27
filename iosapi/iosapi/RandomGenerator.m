#import "RandomGenerator.h"

@implementation RandomGenerator

const char HEX_DIGIT[] = {
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

+ (NSString *) createRandomHex {
    int bits = 64;
    
    if ((bits%8) != 0) {
        bits = bits - bits%8;
    }
    
    int count = (bits / 8);
    NSString *str = [NSString string];
    
    for (int i = 0; i < count; i++) {
        char c = arc4random(); // We want the maximum range possible
        str = [str stringByAppendingFormat:@"%c%c", HEX_DIGIT[(c >> 4) & 0x0f], HEX_DIGIT[c & 0x0f]];
    }
    return str;
}
@end

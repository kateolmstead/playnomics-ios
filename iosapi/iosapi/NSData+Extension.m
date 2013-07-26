//
//  NSData+Extension.m
//  iosapi
//
//  Created by Jared Jenkins on 7/26/13.
//
//

#import "NSData+Extension.h"

@implementation NSData(Extension)
- (id)deserializeJsonData{
    return [self deserializeJsonStringWithOptions: kNilOptions];
}

-(id) deserializeJsonDataWithOptions: (NSJSONReadingOptions) readOptions {
    if(![NSJSONSerialization isValidJSONObject:self]){
        //if this is not valid JSON just return nil
        return nil;
    }
    NSError* error;
    id data = [NSJSONSerialization JSONObjectWithData:self options: readOptions error:&error];
    if(error != nil){
        NSLog(@"Could not parse JSON string: %@. Received error: %@", self, [error localizedDescription]);
    }
    return data;
}
@end

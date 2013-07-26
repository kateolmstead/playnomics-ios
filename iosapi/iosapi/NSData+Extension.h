//
//  NSData+Extension.h
//  iosapi
//
//  Created by Jared Jenkins on 7/26/13.
//
//

#import <Foundation/Foundation.h>

@interface NSData(Extension)
- (id) deserializeJsonDataWithOptions: (NSJSONReadingOptions) readOptions;
- (id) deserializeJsonData;
@end

//
//  PNGeneratedHexId.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import <Foundation/Foundation.h>

@interface PNGeneratedHexId : NSObject

@property (nonatomic, readonly) unsigned long long generatedId;

- (id) initAndGenerateValue;
- (id) initWithValue: (NSString*) value;
- (NSString *) toHex;

@end

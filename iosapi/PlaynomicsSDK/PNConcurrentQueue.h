//
//  PNConcurrentQueue.h
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import <Foundation/Foundation.h>

@interface PNConcurrentQueue : NSObject
- (BOOL) isEmpty;
- (void) enqueue: (id) object;
- (id) dequeue;
@end

//
//  PNConcurrentQueue.m
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import "PNConcurrentQueue.h"

@implementation PNConcurrentQueue{
    NSMutableArray *_values;
    NSObject *_syncLock;
    int _recordCount;
}

-(id) init{
    if((self = [super init])){
        _values = [NSMutableArray alloc];
        _syncLock = [NSObject alloc];
        
        _recordCount = 0;
    }
    return self;
}

-(void) dealloc{
    [_values release];
    [_syncLock release];
    [super dealloc];
}

-(void) enqueue:(id)object{
    @synchronized(_syncLock){
        [_values addObject: object];
        _recordCount ++;
    }
}

-(id) dequeue{
    @synchronized(_syncLock){
        id value;
        value = [_values objectAtIndex:0];
        [_values removeObjectAtIndex:0];
        _recordCount --;
        return value;
    }
}

-(BOOL) isEmpty{
    @synchronized(_syncLock){
        return _recordCount == 0;
    }
}
@end


//
//  PNPlayerSessionInfo.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNGameSessionInfo.h"

@implementation PNGameSessionInfo

@synthesize sessionId = _sessionId;
@synthesize userId = _userId;
@synthesize applicationId = _applicationId;
@synthesize breadcrumbId = _breadcrumbId;

-(id) initWithApplicationId:(unsigned long long)applicationId userId:(NSString *) userId breadcrumbId: (NSString *) breadcrumbId sessionId:(PNGeneratedHexId *)sessionId{
    if((self = [super init])){
        _sessionId = [sessionId retain];
        _breadcrumbId = [breadcrumbId copy];
        _applicationId = [NSNumber numberWithUnsignedLongLong: applicationId];
        _userId = [userId copy];
     }
    return self;
}
@end

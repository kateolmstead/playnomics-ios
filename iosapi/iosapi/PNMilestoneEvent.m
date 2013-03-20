//
//  MilestoneEvent.m
//  iosapi
//
//  Created by Douglas Kadlecek on 12/10/12.
//
//
#import "PNMilestoneEvent.h"

@implementation PNMilestoneEvent

@synthesize milestoneId=_milestoneId;
@synthesize milestoneName=_milestoneName;

- (id) init:  (PNEventType) eventType
applicationId: (signed long long) applicationId
     userId: (NSString *) userId
   cookieId: (NSString *) cookieId
milestoneId: (signed long long) milestoneId
     milestoneName:(NSString *)milestoneName {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId])) {
        _milestoneId = milestoneId;
        _milestoneName = [milestoneName retain];
    }
    return self;
}

- (NSString *) toQueryString {
    //escape the milestone name
    NSString * escapedMilestoneName = [PNUtil urlEncodeValue:[self milestoneName]];
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&mi=%lld&mn=%@&jsh=%@",
                              [self milestoneId],
                              escapedMilestoneName,
                              [self internalSessionId]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeInt64:_milestoneId forKey:@"PNMilestoneEvent._milestoneId"];
    [encoder encodeObject:_milestoneName forKey:@"PNMilestoneEvent._milestoneName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _milestoneId = [decoder decodeInt64ForKey:@"PNMilestoneEvent._milestoneId"];
        _milestoneName = (NSString *) [[decoder decodeObjectForKey:@"PNMilestoneEvent._milestoneName"] retain];
    }
    return self;
}

@end

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
@synthesize milestoneType=_milestoneType;

- (id) init:  (PNEventType) eventType applicationId: (signed long long) applicationId userId: (NSString *) userId cookieId: (NSString *) cookieId milestoneId: (signed long long) milestoneId milestoneType:(PNMilestoneType) milestoneType {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId])) {
        _milestoneId = milestoneId;
        _milestoneType = milestoneType;
    }
    return self;
}

- (NSString *) toQueryString {
    //escape the milestone name
    NSString * milestoneName = [self getNameForMilestoneType: self.milestoneType];
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&mi=%lld&mn=%@&jsh=%@", self.milestoneId, milestoneName, self.internalSessionId];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInt64:_milestoneId forKey:@"PNMilestoneEvent._milestoneId"];
    [encoder encodeInt:_milestoneType forKey:@"PNMilestoneEvent._milestoneType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _milestoneId = [decoder decodeInt64ForKey:@"PNMilestoneEvent._milestoneId"];
        _milestoneType = [decoder decodeIntegerForKey:@"PNMilestoneEvent._milestoneType"];
    }
    return self;
}

- (NSString *) getNameForMilestoneType: (PNMilestoneType) milestoneType{
    int milestoneNum  = (int)milestoneType;
    return [NSString stringWithFormat: @"CUSTOM%d", milestoneNum];
}

@end
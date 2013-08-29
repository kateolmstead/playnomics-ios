//
//  MilestoneEvent.h
//  iosapi
//
//  Created by Douglas Kadlecek on 12/10/12.
//
//
#import "PNSession.h"
#import "PNExplicitEvent.h"

@interface PNMilestoneEvent : PNExplicitEvent
- (id) initWithSessionInfo:(PNGameSessionInfo *)info milestoneType: (PNMilestoneType) milestoneType;
- (NSString *) baseUrlPath;
@end

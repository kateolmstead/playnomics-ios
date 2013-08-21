//
//  MilestoneEvent.h
//  iosapi
//
//  Created by Douglas Kadlecek on 12/10/12.
//
//
#import "PlaynomicsSession.h"
#import "PNEvent.h"

@interface PNMilestoneEvent : PNEvent

@property(nonatomic, assign) signed long long milestoneId;
@property(nonatomic, assign) PNMilestoneType milestoneType;

- (id) init:  (PNEventType) eventType applicationId: (signed long long) applicationId userId: (NSString *) userId cookieId: (NSString *) cookieId milestoneId: (signed long long) milestoneId milestoneType: (PNMilestoneType) milestoneType;

@end

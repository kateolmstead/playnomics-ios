//
//  MilestoneEvent.h
//  iosapi
//
//  Created by Douglas Kadlecek on 12/10/12.
//
//

#import "PNEvent.h"

@interface PNMilestoneEvent : PNEvent {
    signed long long _milestoneId;
    NSString * _milestoneName;
}

@property(nonatomic, assign) signed long long milestoneId;
@property(nonatomic, retain) NSString * milestoneName;

- (id) init:  (PNEventType) eventType
applicationId: (signed long long) applicationId
     userId: (NSString *) userId
   cookieId: (NSString *) cookieId
milestoneId: (signed long long) milestoneId
milestoneName: (NSString *) milestoneName;

@end

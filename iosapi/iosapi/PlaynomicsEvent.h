#import <Foundation/Foundation.h>
#import "PLConstants.h"

@interface PlaynomicsEvent : NSObject {
    PLEventType _eventType;
    NSDate * _eventTime;
    NSNumber * _applicationId;
    NSString * _userId;
}

@property (nonatomic, assign) PLEventType eventType;
@property (nonatomic, retain) NSDate *eventTime;
@property (nonatomic, retain) NSNumber *applicationId;
@property (nonatomic, retain) NSString *userId;

- (id) init: (PLEventType)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSObject *)value;
- (NSString *) toQueryString;
@end

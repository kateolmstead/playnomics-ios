#import <Foundation/Foundation.h>
#import "PNConstants.h"

@interface PNEvent : NSObject <NSCoding> {
    PNEventType _eventType;
    NSTimeInterval  _eventTime;
    long _applicationId;
    NSString * _userId;
}

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, assign) PNEventType eventType;
@property (nonatomic, assign) NSTimeInterval eventTime;
@property (nonatomic, assign) long applicationId;
@property (nonatomic, retain) NSString *userId;

- (id) init: (PNEventType)eventType applicationId:(long) applicationId userId:(NSString *)userId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSString *)value;
- (NSString *) toQueryString;
@end

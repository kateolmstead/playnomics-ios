#import <Foundation/Foundation.h>
#import "PNConstants.h"

@interface PNEvent : NSObject <NSCoding> {
    PNEventType _eventType;
    NSTimeInterval  _eventTime;
    signed long long _applicationId;
    NSString * _userId;
}

@property (nonatomic, retain) NSString * internalSessionId;
@property (nonatomic, assign) PNEventType eventType;
@property (nonatomic, assign) NSTimeInterval eventTime;
@property (nonatomic, assign) signed long long applicationId;
@property (nonatomic, retain) NSString *userId;

- (id) init: (PNEventType)eventType applicationId:(signed long long) applicationId userId:(NSString *)userId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSString *)value;
- (NSString *) toQueryString;
@end

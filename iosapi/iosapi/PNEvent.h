#import <Foundation/Foundation.h>

@interface PNEvent : NSObject <NSCoding> {
    PNEventType _eventType;
    NSTimeInterval  _eventTime;
    signed long long _applicationId;
    NSString * _userId;
    NSString * _cookieId;
}

@property (nonatomic, retain) NSString * internalSessionId;
@property (nonatomic, assign) PNEventType eventType;
@property (nonatomic, assign) NSTimeInterval eventTime;
@property (nonatomic, assign) signed long long applicationId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString * cookieId;

- (id) init: (PNEventType)eventType applicationId:(signed long long) applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSString *)value;
- (NSString *) toQueryString;
@end

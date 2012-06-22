#import "PlaynomicsEvent.h"

@implementation PlaynomicsEvent
@synthesize eventType=_eventType;
@synthesize eventTime=_eventTime;
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;

- (id) init: (PLEventType) eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId {
    if ((self = [super init])) {
        _eventTime = [[NSDate alloc] init];
        _eventType = eventType;
        _applicationId = [applicationId retain];
        _userId = [userId retain];
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: %@", [_eventTime description], [PLUtil PLEventTypeDescription: _eventType]];
}

- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSObject *)value {
    if (value != nil) {
        url = [url stringByAppendingFormat:@"&%@=%@", name, [value description]];
    }
    return url;
}

- (NSString *) toQueryString {
    return [NSString stringWithFormat:@"%@?t=%@&a=%@&u=%@", [self eventType], [[self eventTime] timeIntervalSince1970], [self applicationId]];
}

- (void) dealloc {
    [_eventTime release];
    [_applicationId release];
    [_userId release];
    
    [super dealloc];
}
@end
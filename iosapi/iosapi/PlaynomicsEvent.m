#import "PlaynomicsEvent.h"

@implementation PlaynomicsEvent
@synthesize eventType=_eventType;
@synthesize eventTime=_eventTime;
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;

- (id) init: (PLEventType) eventType applicationId:(long) applicationId userId:(NSString *)userId {
    if ((self = [super init])) {
        _eventTime = [[NSDate date] timeIntervalSince1970];
        _eventType = eventType;
        _applicationId = applicationId;
        _userId = [userId retain];
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: %@", [[NSDate dateWithTimeIntervalSince1970:_eventTime] description], [PLUtil PLEventTypeDescription: _eventType]];
}

- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSString *)value {
    if ([value length] > 0) {
        url = [url stringByAppendingFormat:@"&%@=%@", name, [value description]];
    }
    return url;
}

- (NSString *) toQueryString {
    return [NSString stringWithFormat:@"%@?t=%llu&a=%ld&u=%@", [PLUtil PLEventTypeDescription:[self eventType]], TO_LONG_MILLISECONDS([self eventTime]), [self applicationId], [self userId]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userId forKey:@"PLEvent._userId"];
    [encoder encodeInt64:_applicationId forKey:@"PLEvent._applicationId"];
    [encoder encodeInt:_eventType forKey:@"PLEvent._eventType"];
    [encoder encodeDouble:_eventTime forKey:@"PLEvent._eventTime"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _userId = (NSString *)[[decoder decodeObjectForKey:@"PLEvent._userId"] retain];
        _applicationId = [decoder decodeInt64ForKey:@"PLEvent._userId"];
        _eventType = [decoder decodeIntForKey:@"PLEvent._eventType"];
        _eventTime = [decoder decodeDoubleForKey:@"PLEvent._eventTime"];
    }
    return self;
}

- (void) dealloc {
    [_userId release];
    
    [super dealloc];
}
@end
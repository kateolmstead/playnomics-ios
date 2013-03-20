#import "PNEvent.h"

@implementation PNEvent
@synthesize eventType=_eventType;
@synthesize eventTime=_eventTime;
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;
@synthesize internalSessionId=_internalSessionId;
@synthesize cookieId=_cookieId;

- (id) init: (PNEventType) eventType applicationId:(signed long long) applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId {
    if ((self = [super init])) {
        _eventTime = [[NSDate date] timeIntervalSince1970];
        _eventType = eventType;
        _applicationId = applicationId;
        _userId = [userId retain];
        _cookieId = [cookieId retain];
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: %@", [[NSDate dateWithTimeIntervalSince1970:_eventTime] description], [PNUtil PNEventTypeDescription: _eventType]];
}

- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSString *)value {
    if ([value length] > 0) {
        NSString * escapedValue = [PNUtil urlEncodeValue:value];
        url = [url stringByAppendingFormat:@"&%@=%@", name, [escapedValue description]];
    }
    return url;
}

- (NSString *) toQueryString {
    signed long long eventTime = [self eventTime] * 1000;
    return [NSString stringWithFormat:@"%@?t=%lld&a=%lld&u=%@&b=%@", [PNUtil PNEventTypeDescription:[self eventType]], eventTime, [self applicationId], [self userId], [self cookieId]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userId forKey:@"PNEvent._userId"];
    [encoder encodeInt64:_applicationId forKey:@"PNEvent._applicationId"];
    [encoder encodeInt:_eventType forKey:@"PNEvent._eventType"];
    [encoder encodeDouble:_eventTime forKey:@"PNEvent._eventTime"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _userId = (NSString *)[[decoder decodeObjectForKey:@"PNEvent._userId"] retain];
        _applicationId = [decoder decodeInt64ForKey:@"PNEvent._applicationId"];
        _eventType = [decoder decodeIntForKey:@"PNEvent._eventType"];
        _eventTime = [decoder decodeDoubleForKey:@"PNEvent._eventTime"];
    }
    return self;
}

- (void) dealloc {
    [_userId release];
    [_internalSessionId release];
    
    [super dealloc];
}
@end
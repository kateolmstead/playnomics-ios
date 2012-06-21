#import "PlaynomicsEvent.h"

EventType EventTypeValueOf(NSString *text) {
    if (text) {
        if ([text isEqualToString:@"appStart"])
            return ET_appStart;
        else if ([text isEqualToString:@"appPage"])
            return ET_appPage;
        else if ([text isEqualToString:@"appRunning"])
            return ET_appRunning;
        else if ([text isEqualToString:@"appPause"])
            return ET_appPause;
        else if ([text isEqualToString:@"appResume"])
            return ET_appResume;
        else if ([text isEqualToString:@"appStop"])
            return ET_appStop;
        else if ([text isEqualToString:@"userInfo"])
            return ET_userInfo;
        else if ([text isEqualToString:@"sessionStart"])
            return ET_sessionStart;
        else if ([text isEqualToString:@"sessionEnd"])
            return ET_sessionEnd;
        else if ([text isEqualToString:@"gameStart"])
            return ET_gameStart;
        else if ([text isEqualToString:@"gameEnd"])
            return ET_gameEnd;
        else if ([text isEqualToString:@"transaction"])
            return ET_transaction;
        else if ([text isEqualToString:@"invitationSent"])
            return ET_invitationSent;
        else if ([text isEqualToString:@"invitationResponse"])
            return ET_invitationResponse;
    }
    return -1;
}

NSString* EventTypeDescription(EventType value) {
    switch (value) {
        case ET_appStart:
            return @"appStart";
        case ET_appPage:
            return @"appPage";
        case ET_appRunning:
            return @"appRunning";
        case ET_appPause:
            return @"appPause";
        case ET_appResume:
            return @"appResume";
        case ET_appStop:
            return @"appStop";
        case ET_userInfo:
            return @"userInfo";
        case ET_sessionStart:
            return @"sessionStart";
        case ET_sessionEnd:
            return @"sessionEnd";
        case ET_gameStart:
            return @"gameStart";
        case ET_gameEnd:
            return @"gameEnd";
        case ET_transaction:
            return @"transaction";
        case ET_invitationSent:
            return @"invitationSent";
        case ET_invitationResponse:
            return @"invitationResponse";
    }
    return nil;
}

long const serialVersionUID = 1L;

@implementation PlaynomicsEvent
@synthesize eventType=_eventType;
@synthesize eventTime=_eventTime;
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;

- (id) init:(EventType)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId {
    if ((self = [super init])) {
        _eventTime = [[NSDate alloc] init];
        _eventType = eventType;
        _applicationId = [applicationId retain];
        _userId = [userId retain];
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@: %@", [_eventTime description], EventTypeDescription(_eventType)];
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
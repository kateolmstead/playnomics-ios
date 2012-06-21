#import "UserInfoEvent.h"

long const serialVersionUID = 1L;

@implementation UserInfoEvent

@synthesize type;
@synthesize country;
@synthesize subdivision;
@synthesize sex;
@synthesize birthday;
@synthesize source;
@synthesize sourceCampaign;
@synthesize installTime;

- (id) init:(NSNumber *)applicationId userId:(NSString *)userId type:(UserInfoType *)type {
  if (self = [super init:EventType.userInfo param1:applicationId param2:userId]) {
    type = type;
  }
  return self;
}

- (id) init:(NSNumber *)applicationId userId:(NSString *)userId type:(UserInfoType *)type country:(NSString *)country subdivision:(NSString *)subdivision sex:(UserInfoSex *)sex birthday:(Date *)birthday source:(NSString *)source sourceCampaign:(NSString *)sourceCampaign installTime:(Date *)installTime {
  if (self = [self init:applicationId userId:userId type:type]) {
    country = country;
    subdivision = subdivision;
    sex = sex;
    birthday = birthday;
    source = source;
    sourceCampaign = sourceCampaign;
    installTime = installTime;
  }
  return self;
}

- (NSString *) toQueryString {
  NSString * queryString = [[[[[self eventType] stringByAppendingString:@"?t="] + [[self eventTime] time] stringByAppendingString:@"&a="] + [self applicationId] stringByAppendingString:@"&u="] + [self userId] stringByAppendingString:@"&pt="] + [self type];
  queryString = [self addOptionalParam:queryString param1:@"pc" param2:[self country]];
  queryString = [self addOptionalParam:queryString param1:@"ps" param2:[self subdivision]];
  queryString = [self addOptionalParam:queryString param1:@"px" param2:[self sex]];
  SimpleDateFormat * format = [[[SimpleDateFormat alloc] init:@"MM-DD-yyyy"] autorelease];
  queryString = [self addOptionalParam:queryString param1:@"pb" param2:[format format:[self birthday]]];
  queryString = [self addOptionalParam:queryString param1:@"po" param2:[self source]];
  queryString = [self addOptionalParam:queryString param1:@"pm" param2:[self sourceCampaign]];
  queryString = [self addOptionalParam:queryString param1:@"pi" param2:[[self installTime] time]];
  return queryString;
}

- (void) dealloc {
  [type release];
  [country release];
  [subdivision release];
  [sex release];
  [birthday release];
  [source release];
  [sourceCampaign release];
  [installTime release];
  [super dealloc];
}

@end

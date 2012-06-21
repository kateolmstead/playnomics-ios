#import "PlaynomicsEvent.h"
#import "UserInfoEvent.h"

long const serialVersionUID = 1L;

@implementation UserInfoEvent

@synthesize type=_type;
@synthesize country=_country;
@synthesize subdivision=_subdivision;
@synthesize sex=_sex;
@synthesize birthday=_birthday;
@synthesize source=_source;
@synthesize sourceCampaign=_sourceCampaign;
@synthesize installTime=_installTime;


- (id) init:(NSNumber *)applicationId 
     userId:(NSString *)userId 
       type:(UserInfoType) type {
    if (self = [super init:ET_userInfo applicationId:applicationId userId:userId]) {
        type = type;
    }
    return self;
}

- (id) init:(NSNumber *) applicationId 
             userId: (NSString *) userId 
               type: (UserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (UserInfoSex) sex 
           birthday: (NSDate *) birthday
             source: (NSString *) source
     sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSDate *) installTime {
    
    if (self = [self init:applicationId userId:userId type:type]) {
        _country = [country retain];
        _subdivision = [subdivision retain];
        _sex = sex;
        _birthday = [birthday retain];
        _source = [source retain];
        _sourceCampaign = [sourceCampaign retain];
        _installTime = [installTime retain];
    }
    return self;
}

- (NSString *) toQueryString {
    NSString *queryString = [[super toQueryString] stringByAppendingFormat:@"&pt=%@", [self type]];
    
    queryString = [self addOptionalParam:queryString name:@"pc" value:[self country]];
    queryString = [self addOptionalParam:queryString name:@"ps" value:[self subdivision]];
    queryString = [self addOptionalParam:queryString name:@"px" value:[NSString stringWithFormat:@"%d", [self sex]]];
    
    NSDateFormatter *df = [[NSDateFormatter  alloc] init]; 
    [df setDateFormat: @"MM-DD-yyyy"];
    queryString = [self addOptionalParam:queryString name:@"pb" value:[df stringFromDate:[self birthday]]];
    [df release];
    
    queryString = [self addOptionalParam:queryString name:@"po" value:[self source]];
    queryString = [self addOptionalParam:queryString name:@"pm" value:[self sourceCampaign]];
    queryString = [self addOptionalParam:queryString name:@"pi" value:[NSString stringWithFormat:@"%d", [[self installTime] timeIntervalSince1970]]];
    return queryString;
}

- (void) dealloc {
    [_country release];
    [_subdivision release];
    [_birthday release];
    [_source release];
    [_sourceCampaign release];
    [_installTime release];
    [super dealloc];
}

@end

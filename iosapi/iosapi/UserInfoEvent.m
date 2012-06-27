#import "UserInfoEvent.h"

@implementation UserInfoEvent

@synthesize type=_type;
@synthesize country=_country;
@synthesize subdivision=_subdivision;
@synthesize sex=_sex;
@synthesize birthday=_birthday;
@synthesize source=_source;
@synthesize sourceCampaign=_sourceCampaign;
@synthesize installTime=_installTime;


- (id) initUserInfoEvent:(long) applicationId 
     userId:(NSString *)userId 
       type:(PLUserInfoType) type {
    
    PLEventType eType = PLEventUserInfo;
    
    if (self = [super init:eType applicationId:applicationId userId:userId]) {
        _type = type;
    }
    
    return self;
}

- (id) init:(long) applicationId 
             userId: (NSString *) userId 
               type: (PLUserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (PLUserInfoSex) sex 
           birthday: (NSTimeInterval) birthday
             source: (PLUserInfoSource) source
     sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSTimeInterval) installTime {
    
    if (self = [self initUserInfoEvent:applicationId userId:userId type:type]) {
        _country = [country retain];
        _subdivision = [subdivision retain];
        _sex = sex;
        _birthday = birthday;
        _source = source;
        _sourceCampaign = [sourceCampaign retain];
        _installTime = installTime;
    }
    return self;
}

- (NSString *) toQueryString {
    NSString *queryString = [[super toQueryString] stringByAppendingFormat:@"&pt=%@", [PLUtil PLUserInfoTypeDescription:[self type]]];
    
    queryString = [self addOptionalParam:queryString name:@"pc" value:[self country]];
    queryString = [self addOptionalParam:queryString name:@"ps" value:[self subdivision]];
    queryString = [self addOptionalParam:queryString name:@"px" value:[PLUtil PLUserInfoSexDescription:[self sex]]];
    
    NSDateFormatter *df = [[NSDateFormatter  alloc] init]; 
    [df setDateFormat: @"MM-dd-yyyy"];
    queryString = [self addOptionalParam:queryString name:@"pb" value:[df stringFromDate: [NSDate dateWithTimeIntervalSince1970:[self birthday]]]];
    [df release];
    
    queryString = [self addOptionalParam:queryString name:@"po" value:[PLUtil PLUserInfoSourceDescription:[self source]]];
    queryString = [self addOptionalParam:queryString name:@"pm" value:[self sourceCampaign]];
    queryString = [self addOptionalParam:queryString name:@"pi" value:[NSString stringWithFormat:@"%llu", TO_LONG_MILLISECONDS([self installTime])]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
   	[encoder encodeInt: _type forKey:@"PLUserInfoEvent._type"];  
    [encoder encodeObject: _country forKey:@"PLUserInfoEvent._country"];  
    [encoder encodeObject: _subdivision forKey:@"PLUserInfoEvent._subdivision"];  
    [encoder encodeInt: _sex forKey:@"PLUserInfoEvent._sex"];  
    [encoder encodeDouble: _birthday forKey:@"PLUserInfoEvent._birthday"];  
    [encoder encodeInt: _source forKey:@"PLUserInfoEvent._source"];  
    [encoder encodeObject: _sourceCampaign forKey:@"PLUserInfoEvent._sourceCampaign"];  
    [encoder encodeDouble: _installTime forKey:@"PLUserInfoEvent._installTime"];  
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _type= [decoder decodeIntForKey:@"PLUserInfoEvent._type"];
        _country = [(NSString *)[decoder decodeObjectForKey:@"PLUserInfoEvent._country"] retain]; 
        _subdivision = [(NSString *)[decoder decodeObjectForKey:@"PLUserInfoEvent._subdivision"] retain]; 
        _sex = [decoder decodeIntForKey:@"PLUserInfoEvent._sex"]; 
        _birthday = [decoder decodeDoubleForKey:@"PLUserInfoEvent._birthday"]; 
        _source = [decoder decodeIntForKey:@"PLUserInfoEvent._source"]; 
        _sourceCampaign = [(NSString *)[decoder decodeObjectForKey:@"PLUserInfoEvent._sourceCampaign"] retain]; 
        _installTime = [decoder decodeDoubleForKey:@"PLUserInfoEvent._installTime"]; 
    }
    return self;
}

- (void) dealloc {
    [_country release];
    [_subdivision release];
    [_sourceCampaign release];
    [super dealloc];
}

@end

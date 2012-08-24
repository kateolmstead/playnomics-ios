#import "PNUserInfoEvent.h"

@implementation PNUserInfoEvent

@synthesize type=_type;
@synthesize country=_country;
@synthesize subdivision=_subdivision;
@synthesize sex=_sex;
@synthesize birthday=_birthday;
@synthesize sourceStr=_sourceStr;
@synthesize sourceCampaign=_sourceCampaign;
@synthesize installTime=_installTime;


- (id) initUserInfoEvent:(signed long long) applicationId
     userId:(NSString *)userId 
       type:(PNUserInfoType) type {
    
    PNEventType eType = PNEventUserInfo;
    
    if (self = [super init:eType applicationId:applicationId userId:userId]) {
        _type = type;
    }
    
    return self;
}

- (id) init:(signed long long) applicationId
             userId: (NSString *) userId 
               type: (PNUserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (PNUserInfoSex) sex 
           birthday: (NSTimeInterval) birthday
             source: (NSString *) source
     sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSTimeInterval) installTime {
    
    if (self = [self initUserInfoEvent:applicationId userId:userId type:type]) {
        _country = [country retain];
        _subdivision = [subdivision retain];
        _sex = sex;
        _birthday = birthday;
        _sourceStr = [source retain];
        _sourceCampaign = [sourceCampaign retain];
        _installTime = installTime;
    }
    return self;
}

- (NSString *) toQueryString {
    NSString *queryString = [[super toQueryString] stringByAppendingFormat:@"&pt=%@&jsh=%@", [PNUtil PNUserInfoTypeDescription:[self type]], [self internalSessionId]];
    
    queryString = [self addOptionalParam:queryString name:@"pc" value:[self country]];
    queryString = [self addOptionalParam:queryString name:@"ps" value:[self subdivision]];
    queryString = [self addOptionalParam:queryString name:@"px" value:[PNUtil PNUserInfoSexDescription:[self sex]]];
    
    NSDateFormatter *df = [[NSDateFormatter  alloc] init]; 
    [df setDateFormat: @"yyyy"]; // TODO: Details API says this should be of format: YYYY/MM || YYY-MM || MM/YYYY || YYYY
    queryString = [self addOptionalParam:queryString name:@"pb" value:[df stringFromDate: [NSDate dateWithTimeIntervalSince1970:[self birthday]]]];
    [df release];
    
    queryString = [self addOptionalParam:queryString name:@"po" value:[self sourceStr]];
    queryString = [self addOptionalParam:queryString name:@"pm" value:[self sourceCampaign]];
    queryString = [self addOptionalParam:queryString name:@"pi" value:[NSString stringWithFormat:@"%f", [self installTime]]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
   	[encoder encodeInt: _type forKey:@"PNUserInfoEvent._type"];  
    [encoder encodeObject: _country forKey:@"PNUserInfoEvent._country"];  
    [encoder encodeObject: _subdivision forKey:@"PNUserInfoEvent._subdivision"];  
    [encoder encodeInt: _sex forKey:@"PNUserInfoEvent._sex"];  
    [encoder encodeDouble: _birthday forKey:@"PNUserInfoEvent._birthday"];  
    [encoder encodeObject: _sourceStr forKey:@"PNUserInfoEvent._sourceStr"];  
    [encoder encodeObject: _sourceCampaign forKey:@"PNUserInfoEvent._sourceCampaign"];  
    [encoder encodeDouble: _installTime forKey:@"PNUserInfoEvent._installTime"];  
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _type= [decoder decodeIntForKey:@"PNUserInfoEvent._type"];
        _country = [(NSString *)[decoder decodeObjectForKey:@"PNUserInfoEvent._country"] retain]; 
        _subdivision = [(NSString *)[decoder decodeObjectForKey:@"PNUserInfoEvent._subdivision"] retain]; 
        _sex = [decoder decodeIntForKey:@"PNUserInfoEvent._sex"]; 
        _birthday = [decoder decodeDoubleForKey:@"PNUserInfoEvent._birthday"]; 
        _sourceStr = (NSString *)[decoder decodeObjectForKey:@"PNUserInfoEvent._sourceStr"]; 
        _sourceCampaign = [(NSString *)[decoder decodeObjectForKey:@"PNUserInfoEvent._sourceCampaign"] retain]; 
        _installTime = [decoder decodeDoubleForKey:@"PNUserInfoEvent._installTime"]; 
    }
    return self;
}

- (void) dealloc {
    [_country release];
    [_subdivision release];
    [_sourceCampaign release];
    [_sourceStr release];
    
    [super dealloc];
}

@end

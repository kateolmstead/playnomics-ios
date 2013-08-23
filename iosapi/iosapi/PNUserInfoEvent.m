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
@synthesize limitAdvertising=_limitAdvertising;
@synthesize idfa=_idfa;
@synthesize idfv=_idfv;


- (id) initUserInfoEvent:(signed long long) applicationId
                  userId:(NSString *)userId
                cookieId: (NSString *) cookieId
                    type:(PNUserInfoType) type {
    
    PNEventType eType = PNEventUserInfo;
    
    if (self = [super init:eType applicationId:applicationId userId:userId cookieId:cookieId]) {
        _type = type;
    }
    
    return self;
}

- (id) init:(signed long long) applicationId
     userId: (NSString *) userId
   cookieId: (NSString *) cookieId
       type: (PNUserInfoType) type
    country: (NSString *) country
subdivision: (NSString *) subdivision
        sex: (PNUserInfoSex) sex
   birthday: (NSTimeInterval) birthday
     source: (NSString *) source
sourceCampaign: (NSString *) sourceCampaign
installTime: (NSTimeInterval) installTime {
    
    if (self = [self initUserInfoEvent:applicationId userId:userId cookieId:cookieId type:type]) {
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

- (id) initWithAdvertisingInfo:(signed long long) applicationId
                        userId: (NSString *) userId
                      cookieId: (NSString *) cookieId
                          type: (PNUserInfoType) type
              limitAdvertising: (NSString *) limitAdvertising
                          idfa: (NSString *) idfa
                          idfv: (NSString *) idfv {
    if (self = [self initUserInfoEvent:applicationId userId:userId cookieId:cookieId type:type]) {
        _limitAdvertising = [limitAdvertising retain];
        _idfa = [idfa retain];
        _idfv = [idfv retain];
    }
    return self;
}


- (NSString *) toQueryString {
    NSString *queryString = [[super toQueryString] stringByAppendingFormat:@"&pt=%@&jsh=%@", [self PNUserInfoTypeDescription:[self type]], [self internalSessionId]];
    
    queryString = [self addOptionalParam:queryString name:@"pc" value:[self country]];
    queryString = [self addOptionalParam:queryString name:@"ps" value:[self subdivision]];
    queryString = [self addOptionalParam:queryString name:@"px" value:[self PNUserInfoSexDescription:[self sex]]];
    
    NSDateFormatter *df = [[NSDateFormatter  alloc] init];
    [df setDateFormat: @"yyyy"]; // TODO: Details API says this should be of format: YYYY/MM || YYY-MM || MM/YYYY || YYYY
    queryString = [self addOptionalParam:queryString name:@"pb" value:[df stringFromDate: [NSDate dateWithTimeIntervalSince1970:[self birthday]]]];
    [df release];
    
    queryString = [self addOptionalParam:queryString name:@"po" value:[self sourceStr]];
    queryString = [self addOptionalParam:queryString name:@"pm" value:[self sourceCampaign]];
    queryString = [self addOptionalParam:queryString name:@"pi" value:[NSString stringWithFormat:@"%.0f", [self installTime]]];//remove the decimal
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [userDefaults stringForKey:PNUserDefaultsLastDeviceToken];
    if (deviceToken!=nil) {
        queryString = [self addOptionalParam:queryString name:@"pushTok" value:deviceToken];
    }
    
    queryString = [self addOptionalParam:queryString name:@"limitAdvertising" value:[self limitAdvertising]];
    queryString = [self addOptionalParam:queryString name:@"idfa" value:[self idfa]];
    queryString = [self addOptionalParam:queryString name:@"idfv" value:[self idfv]];
    
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

- (NSString *) PNUserInfoSexDescription:(PNUserInfoSex) value {
    switch (value) {
        case PNUserInfoSexMale:
            return @"M";
        case PNUserInfoSexFemale:
            return @"F";
        case PNUserInfoSexUnknown:
            return @"U";
    }
    return nil;
}

-(PNUserInfoSource) PNUserInfoSourceValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"Adwords"])
            return PNUserInfoSourceAdwords;
        else if ([text isEqualToString:@"DoubleClick"])
            return PNUserInfoSourceDoubleClick;
        else if ([text isEqualToString:@"YahooAds"])
            return PNUserInfoSourceYahooAds;
        else if ([text isEqualToString:@"MSNAds"])
            return PNUserInfoSourceMSNAds;
        else if ([text isEqualToString:@"AOLAds"])
            return PNUserInfoSourceAOLAds;
        else if ([text isEqualToString:@"Adbrite"])
            return PNUserInfoSourceAdbrite;
        else if ([text isEqualToString:@"FacebookAds"])
            return PNUserInfoSourceFacebookAds;
        else if ([text isEqualToString:@"GoogleSearch"])
            return PNUserInfoSourceGoogleSearch;
        else if ([text isEqualToString:@"YahooSearch"])
            return PNUserInfoSourceYahooSearch;
        else if ([text isEqualToString:@"BingSearch"])
            return PNUserInfoSourceBingSearch;
        else if ([text isEqualToString:@"FacebookSearch"])
            return PNUserInfoSourceFacebookSearch;
        else if ([text isEqualToString:@"Applifier"])
            return PNUserInfoSourceApplifier;
        else if ([text isEqualToString:@"AppStrip"])
            return PNUserInfoSourceAppStrip;
        else if ([text isEqualToString:@"VIPGamesNetwork"])
            return PNUserInfoSourceVIPGamesNetwork;
        else if ([text isEqualToString:@"UserReferral"])
            return PNUserInfoSourceUserReferral;
        else if ([text isEqualToString:@"InterGame"])
            return PNUserInfoSourceInterGame;
        else if ([text isEqualToString:@"Other"])
            return PNUserInfoSourceOther;
    }
    return -1;
}

- (NSString *) PNUserInfoSourceDescription:(PNUserInfoSource) value {
    switch (value) {
        case PNUserInfoSourceAdwords:
            return @"Adwords";
        case PNUserInfoSourceDoubleClick:
            return @"DoubleClick";
        case PNUserInfoSourceYahooAds:
            return @"YahooAds";
        case PNUserInfoSourceMSNAds:
            return @"MSNAds";
        case PNUserInfoSourceAOLAds:
            return @"AOLAds";
        case PNUserInfoSourceAdbrite:
            return @"Adbrite";
        case PNUserInfoSourceFacebookAds:
            return @"FacebookAds";
        case PNUserInfoSourceGoogleSearch:
            return @"GoogleSearch";
        case PNUserInfoSourceYahooSearch:
            return @"YahooSearch";
        case PNUserInfoSourceBingSearch:
            return @"BingSearch";
        case PNUserInfoSourceFacebookSearch:
            return @"FacebookSearch";
        case PNUserInfoSourceApplifier:
            return @"Applifier";
        case PNUserInfoSourceAppStrip:
            return @"AppStrip";
        case PNUserInfoSourceVIPGamesNetwork:
            return @"VIPGamesNetwork";
        case PNUserInfoSourceUserReferral:
            return @"UserReferral";
        case PNUserInfoSourceInterGame:
            return @"InterGame";
        case PNUserInfoSourceOther:
            return @"Other";
    }
    return nil;
}

-(PNUserInfoType) PNUserInfoTypeValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"update"])
            return PNUserInfoTypeUpdate;
    }
    return -1;
}

-(NSString *) PNUserInfoTypeDescription:(PNUserInfoType) value {
    switch (value) {
        case PNUserInfoTypeUpdate:
            return @"update";
    }
    return nil;
}

-(PNUserInfoSex) PNUserInfoSexValueOf:(NSString *) text {
    if (text) {
        if ([text isEqualToString:@"M"])
            return PNUserInfoSexMale;
        else if ([text isEqualToString:@"F"])
            return PNUserInfoSexFemale;
        else if ([text isEqualToString:@"U"])
            return PNUserInfoSexUnknown;
    }
    return -1;
}


@end

#import "PNEventUserInfo.h"
@implementation PNEventUserInfo


- (id) initWithSessionInfo:(PNGameSessionInfo *)info pushToken : (NSString *) pushToken{
    if((self = [super initWithSessionInfo: info])){
        [self appendParameter:pushToken forKey:PNEventParameterUserInfoPushToken];
        [self appendParameter:@"update" forKey:PNEventParameterUserInfoType];
    }
    return self;
}

- (id) initWithSessionInfo:(PNGameSessionInfo *)info limitAdvertising: (BOOL) limitAdvertising idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv{
    if((self = [super initWithSessionInfo: info])){
        
        [self appendParameter:[PNUtil boolAsString:limitAdvertising] forKey:PNEventParameterUserInfoLimitAdvertising];
        
        if(idfa) {
            [self appendParameter:[idfa UUIDString] forKey:PNEventParameterUserInfoIdfa];
        }
        
        if(idfv) {
            [self appendParameter:[idfv UUIDString] forKey:PNEventParameterUserInfoIdfv];
        }
        [self appendParameter:@"update" forKey:PNEventParameterUserInfoType];
    }
    return self;
}

-(NSString *) baseUrlPath{
    return @"userInfo";
}

@end

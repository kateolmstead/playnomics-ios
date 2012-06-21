#import "SimpleDateFormat.h"
#import "Date.h"
#import "UserInfoSex.h"
#import "UserInfoType.h"

@interface UserInfoEvent : PlaynomicsEvent {
  UserInfoType * type;
  NSString * country;
  NSString * subdivision;
  UserInfoSex * sex;
  Date * birthday;
  NSString * source;
  NSString * sourceCampaign;
  Date * installTime;
}

@property(nonatomic, retain) UserInfoType * type;
@property(nonatomic, retain) NSString * country;
@property(nonatomic, retain) NSString * subdivision;
@property(nonatomic, retain) UserInfoSex * sex;
@property(nonatomic, retain) Date * birthday;
@property(nonatomic, retain) NSString * source;
@property(nonatomic, retain) NSString * sourceCampaign;
@property(nonatomic, retain) Date * installTime;
- (id) init:(NSNumber *)applicationId userId:(NSString *)userId type:(UserInfoType *)type;
- (id) init:(NSNumber *)applicationId userId:(NSString *)userId type:(UserInfoType *)type country:(NSString *)country subdivision:(NSString *)subdivision sex:(UserInfoSex *)sex birthday:(Date *)birthday source:(NSString *)source sourceCampaign:(NSString *)sourceCampaign installTime:(Date *)installTime;
- (void) setType:(UserInfoType *)type;
- (void) setCountry:(NSString *)country;
- (void) setSubdivision:(NSString *)subdivision;
- (void) setSex:(UserInfoSex *)sex;
- (void) setBirthday:(Date *)birthday;
- (void) setSource:(NSString *)source;
- (void) setSourceCampaign:(NSString *)sourceCampaign;
- (void) setInstallTime:(Date *)installTime;
- (NSString *) toQueryString;
@end

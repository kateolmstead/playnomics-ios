#import "PLConstants.h"
#import "PlaynomicsEvent.h"

@interface UserInfoEvent : PlaynomicsEvent {
  PLUserInfoType _type;
  NSString * _country;
  NSString * _subdivision;
  PLUserInfoSex _sex;
  NSDate * _birthday;
  NSString * _source;
  NSString * _sourceCampaign;
  NSDate * _installTime;
}

@property(nonatomic, assign) PLUserInfoType type;
@property(nonatomic, retain) NSString * country;
@property(nonatomic, retain) NSString * subdivision;
@property(nonatomic, assign) PLUserInfoSex sex;
@property(nonatomic, retain) NSDate * birthday;
@property(nonatomic, retain) NSString * source;
@property(nonatomic, retain) NSString * sourceCampaign;
@property(nonatomic, retain) NSDate * installTime;

- (id) initUserInfoEvent: (NSNumber *) applicationId 
             userId: (NSString *) userId 
               type: (PLUserInfoType) type;

- (id) init: (NSNumber *) applicationId 
             userId: (NSString *) userId 
               type: (PLUserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (PLUserInfoSex) sex 
           birthday: (NSDate *) birthday
             source: (NSString *) source
        sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSDate *) installTime;
@end

#import "PlaynomicsConstants.h"

@class PlaynomicsEvent;

@interface UserInfoEvent : PlaynomicsEvent {
  UserInfoType _type;
  NSString * _country;
  NSString * _subdivision;
  UserInfoSex _sex;
  NSDate * _birthday;
  NSString * _source;
  NSString * _sourceCampaign;
  NSDate * _installTime;
}

@property(nonatomic, assign) UserInfoType type;
@property(nonatomic, retain) NSString * country;
@property(nonatomic, retain) NSString * subdivision;
@property(nonatomic, assign) UserInfoSex sex;
@property(nonatomic, retain) NSDate * birthday;
@property(nonatomic, retain) NSString * source;
@property(nonatomic, retain) NSString * sourceCampaign;
@property(nonatomic, retain) NSDate * installTime;

- (id) init: (NSNumber *) applicationId 
             userId: (NSString *) userId 
               type: (UserInfoType) type;

- (id) init: (NSNumber *) applicationId 
             userId: (NSString *) userId 
               type: (UserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (UserInfoSex) sex 
           birthday: (NSDate *) birthday
             source: (NSString *) source
        sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSDate *) installTime;
@end

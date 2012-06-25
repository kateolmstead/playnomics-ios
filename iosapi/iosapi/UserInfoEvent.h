#import "PLConstants.h"
#import "PlaynomicsEvent.h"

@interface UserInfoEvent : PlaynomicsEvent {
  PLUserInfoType _type;
  NSString * _country;
  NSString * _subdivision;
  PLUserInfoSex _sex;
  NSTimeInterval _birthday;
  NSString * _source;
  NSString * _sourceCampaign;
  NSTimeInterval _installTime;
}

@property(nonatomic, assign) PLUserInfoType type;
@property(nonatomic, retain) NSString * country;
@property(nonatomic, retain) NSString * subdivision;
@property(nonatomic, assign) PLUserInfoSex sex;
@property(nonatomic, assign) NSTimeInterval birthday;
@property(nonatomic, retain) NSString * source;
@property(nonatomic, retain) NSString * sourceCampaign;
@property(nonatomic, assign) NSTimeInterval installTime;

- (id) initUserInfoEvent: (long) applicationId 
             userId: (NSString *) userId 
               type: (PLUserInfoType) type;

- (id) init: (long) applicationId 
             userId: (NSString *) userId 
               type: (PLUserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (PLUserInfoSex) sex 
           birthday: (NSTimeInterval) birthday
             source: (NSString *) source
     sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSTimeInterval) installTime;
@end

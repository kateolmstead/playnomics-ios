#import "PNConstants.h"
#import "PNEvent.h"

@interface PNUserInfoEvent : PNEvent {
  PNUserInfoType _type;
  NSString * _country;
  NSString * _subdivision;
  PNUserInfoSex _sex;
  NSTimeInterval _birthday;
  PNUserInfoSource _source;
  NSString * _sourceCampaign;
  NSTimeInterval _installTime;
}

@property(nonatomic, assign) PNUserInfoType type;
@property(nonatomic, retain) NSString * country;
@property(nonatomic, retain) NSString * subdivision;
@property(nonatomic, assign) PNUserInfoSex sex;
@property(nonatomic, assign) NSTimeInterval birthday;
@property(nonatomic, assign) PNUserInfoSource source;
@property(nonatomic, retain) NSString * sourceCampaign;
@property(nonatomic, assign) NSTimeInterval installTime;

- (id) initUserInfoEvent: (long) applicationId 
             userId: (NSString *) userId 
               type: (PNUserInfoType) type;

- (id) init: (long) applicationId 
             userId: (NSString *) userId 
               type: (PNUserInfoType) type 
            country: (NSString *) country 
        subdivision: (NSString *) subdivision 
                sex: (PNUserInfoSex) sex 
           birthday: (NSTimeInterval) birthday
             source: (PNUserInfoSource) source
     sourceCampaign: (NSString *) sourceCampaign
        installTime: (NSTimeInterval) installTime;
@end


typedef enum {
  accepted
} ResponseType;

ResponseType ResponseTypeValueOf(NSString *text);
ResponseType ResponseTypeDescription(ResponseType value);

typedef enum {
  BuyItem,
  SellItem,
  ReturnItem,
  BuyService,
  SellService,
  ReturnService,
  CurrencyConvert,
  Initial,
  Free,
  Reward,
  GiftSend,
  GiftReceive
} TransactionType;

TransactionType TransactionTypeValueOf(NSString *text);
TransactionType TransactionTypeDescription(TransactionType value);

typedef enum {
  Real,
  Virtual
} CurrencyCategory;

typedef struct {
  NSString * name;
} CurrencyCategory_Fields;

static CurrencyCategory_Fields CurrencyCategory_Data[2] = {
  { @"r"}
  , { @"v"}
};

CurrencyCategory CurrencyCategoryValueOf(NSString *text);
CurrencyCategory CurrencyCategoryDescription(CurrencyCategory value);

NSString * CurrencyCategory_description(id<CurrencyCategory> e);

typedef enum {
  USD,
  FBC,
  OFD,
  OFF
} CurrencyType;

CurrencyType CurrencyTypeValueOf(NSString *text);
CurrencyType CurrencyTypeDescription(CurrencyType value);

typedef enum {
  update
} UserInfoType;

UserInfoType UserInfoTypeValueOf(NSString *text);
UserInfoType UserInfoTypeDescription(UserInfoType value);

typedef enum {
  Male,
  Female,
  Unknown
} UserInfoSex;

typedef struct {
  NSString * name;
} UserInfoSex_Fields;

static UserInfoSex_Fields UserInfoSex_Data[3] = {
  { @"M"}
  , { @"F"}
  , { @"U"}
};

UserInfoSex UserInfoSexValueOf(NSString *text);
UserInfoSex UserInfoSexDescription(UserInfoSex value);

NSString * UserInfoSex_description(id<UserInfoSex> e);

typedef enum {
  Adwords,
  DoubleClick,
  YahooAds,
  MSNAds,
  AOLAds,
  Adbrite,
  FacebookAds,
  GoogleSearch,
  YahooSearch,
  BingSearch,
  FacebookSearch,
  Applifier,
  AppStrip,
  VIPGamesNetwork,
  UserReferral,
  InterGame,
  Other
} UserInfoSource;

UserInfoSource UserInfoSourceValueOf(NSString *text);
UserInfoSource UserInfoSourceDescription(UserInfoSource value);

@interface PlaynomicsConstants : NSObject {
}

@end

#import "PlaynomicsConstants.h"

ResponseType ResponseTypeValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"accepted"])
      return accepted;
  }
  return -1;
}

ResponseType ResponseTypeDescription(ResponseType value) {
  switch (value) {
    case accepted:
      return @"accepted";
  }
  return nil;
}

TransactionType TransactionTypeValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"BuyItem"])
      return BuyItem;
    else if ([text isEqualToString:@"SellItem"])
      return SellItem;
    else if ([text isEqualToString:@"ReturnItem"])
      return ReturnItem;
    else if ([text isEqualToString:@"BuyService"])
      return BuyService;
    else if ([text isEqualToString:@"SellService"])
      return SellService;
    else if ([text isEqualToString:@"ReturnService"])
      return ReturnService;
    else if ([text isEqualToString:@"CurrencyConvert"])
      return CurrencyConvert;
    else if ([text isEqualToString:@"Initial"])
      return Initial;
    else if ([text isEqualToString:@"Free"])
      return Free;
    else if ([text isEqualToString:@"Reward"])
      return Reward;
    else if ([text isEqualToString:@"GiftSend"])
      return GiftSend;
    else if ([text isEqualToString:@"GiftReceive"])
      return GiftReceive;
  }
  return -1;
}

TransactionType TransactionTypeDescription(TransactionType value) {
  switch (value) {
    case BuyItem:
      return @"BuyItem";
    else case SellItem:
      return @"SellItem";
    else case ReturnItem:
      return @"ReturnItem";
    else case BuyService:
      return @"BuyService";
    else case SellService:
      return @"SellService";
    else case ReturnService:
      return @"ReturnService";
    else case CurrencyConvert:
      return @"CurrencyConvert";
    else case Initial:
      return @"Initial";
    else case Free:
      return @"Free";
    else case Reward:
      return @"Reward";
    else case GiftSend:
      return @"GiftSend";
    else case GiftReceive:
      return @"GiftReceive";
  }
  return nil;
}

CurrencyCategory CurrencyCategoryValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"Real"])
      return Real;
    else if ([text isEqualToString:@"Virtual"])
      return Virtual;
  }
  return -1;
}

CurrencyCategory CurrencyCategoryDescription(CurrencyCategory value) {
  switch (value) {
    case Real:
      return @"Real";
    else case Virtual:
      return @"Virtual";
  }
  return nil;
}
id CurrencyCategory_initWithName(id<CurrencyCategory> e, NSString * name) {
  if (self = [super init]) {
    name = name;
  }
  return self;
}
NSString * CurrencyCategory_description(id<CurrencyCategory> e) {
  return name;
}
void CurrencyCategory_dealloc(id<CurrencyCategory> e) {
  [name release];
  [super dealloc];
}

CurrencyType CurrencyTypeValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"USD"])
      return USD;
    else if ([text isEqualToString:@"FBC"])
      return FBC;
    else if ([text isEqualToString:@"OFD"])
      return OFD;
    else if ([text isEqualToString:@"OFF"])
      return OFF;
  }
  return -1;
}

CurrencyType CurrencyTypeDescription(CurrencyType value) {
  switch (value) {
    case USD:
      return @"USD";
    else case FBC:
      return @"FBC";
    else case OFD:
      return @"OFD";
    else case OFF:
      return @"OFF";
  }
  return nil;
}

UserInfoType UserInfoTypeValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"update"])
      return update;
  }
  return -1;
}

UserInfoType UserInfoTypeDescription(UserInfoType value) {
  switch (value) {
    case update:
      return @"update";
  }
  return nil;
}

UserInfoSex UserInfoSexValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"Male"])
      return Male;
    else if ([text isEqualToString:@"Female"])
      return Female;
    else if ([text isEqualToString:@"Unknown"])
      return Unknown;
  }
  return -1;
}

UserInfoSex UserInfoSexDescription(UserInfoSex value) {
  switch (value) {
    case Male:
      return @"Male";
    else case Female:
      return @"Female";
    else case Unknown:
      return @"Unknown";
  }
  return nil;
}
id UserInfoSex_initWithName(id<UserInfoSex> e, NSString * name) {
  if (self = [super init]) {
    name = name;
  }
  return self;
}
NSString * UserInfoSex_description(id<UserInfoSex> e) {
  return name;
}
void UserInfoSex_dealloc(id<UserInfoSex> e) {
  [name release];
  [super dealloc];
}

UserInfoSource UserInfoSourceValueOf(NSString *text) {
  if (text) {
    if ([text isEqualToString:@"Adwords"])
      return Adwords;
    else if ([text isEqualToString:@"DoubleClick"])
      return DoubleClick;
    else if ([text isEqualToString:@"YahooAds"])
      return YahooAds;
    else if ([text isEqualToString:@"MSNAds"])
      return MSNAds;
    else if ([text isEqualToString:@"AOLAds"])
      return AOLAds;
    else if ([text isEqualToString:@"Adbrite"])
      return Adbrite;
    else if ([text isEqualToString:@"FacebookAds"])
      return FacebookAds;
    else if ([text isEqualToString:@"GoogleSearch"])
      return GoogleSearch;
    else if ([text isEqualToString:@"YahooSearch"])
      return YahooSearch;
    else if ([text isEqualToString:@"BingSearch"])
      return BingSearch;
    else if ([text isEqualToString:@"FacebookSearch"])
      return FacebookSearch;
    else if ([text isEqualToString:@"Applifier"])
      return Applifier;
    else if ([text isEqualToString:@"AppStrip"])
      return AppStrip;
    else if ([text isEqualToString:@"VIPGamesNetwork"])
      return VIPGamesNetwork;
    else if ([text isEqualToString:@"UserReferral"])
      return UserReferral;
    else if ([text isEqualToString:@"InterGame"])
      return InterGame;
    else if ([text isEqualToString:@"Other"])
      return Other;
  }
  return -1;
}

UserInfoSource UserInfoSourceDescription(UserInfoSource value) {
  switch (value) {
    case Adwords:
      return @"Adwords";
    else case DoubleClick:
      return @"DoubleClick";
    else case YahooAds:
      return @"YahooAds";
    else case MSNAds:
      return @"MSNAds";
    else case AOLAds:
      return @"AOLAds";
    else case Adbrite:
      return @"Adbrite";
    else case FacebookAds:
      return @"FacebookAds";
    else case GoogleSearch:
      return @"GoogleSearch";
    else case YahooSearch:
      return @"YahooSearch";
    else case BingSearch:
      return @"BingSearch";
    else case FacebookSearch:
      return @"FacebookSearch";
    else case Applifier:
      return @"Applifier";
    else case AppStrip:
      return @"AppStrip";
    else case VIPGamesNetwork:
      return @"VIPGamesNetwork";
    else case UserReferral:
      return @"UserReferral";
    else case InterGame:
      return @"InterGame";
    else case Other:
      return @"Other";
  }
  return nil;
}

@implementation PlaynomicsConstants

@end

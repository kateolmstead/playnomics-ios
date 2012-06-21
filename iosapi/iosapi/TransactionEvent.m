#import "TransactionEvent.h"

long const serialVersionUID = 1L;

@implementation TransactionEvent

@synthesize transactionId;
@synthesize itemId;
@synthesize quantity;
@synthesize type;
@synthesize otherUserId;
@synthesize currencyTypes;
@synthesize currencyValues;
@synthesize currencyCategories;

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId transactionId:(long)transactionId itemId:(NSString *)itemId quantity:(double)quantity type:(TransactionType *)type otherUserId:(NSString *)otherUserId currencyTypes:(NSArray *)currencyTypes currencyValues:(NSArray *)currencyValues currencyCategories:(NSArray *)currencyCategories {
  if (self = [super init:eventType param1:applicationId param2:userId]) {
    transactionId = transactionId;
    itemId = itemId;
    quantity = quantity;
    type = type;
    otherUserId = otherUserId;
    currencyTypes = currencyTypes;
    currencyValues = currencyValues;
    currencyCategories = currencyCategories;
  }
  return self;
}

- (NSString *) toQueryString {
  NSString * queryString = [[[[[self eventType] stringByAppendingString:@"?t="] + [[self eventTime] time] stringByAppendingString:@"&a="] + [self applicationId] stringByAppendingString:@"&u="] + [self userId] stringByAppendingString:@"&tt="] + [self type];

  for (int i = 0; i < [self currencyTypes].length; i++) {
    queryString = [queryString stringByAppendingString:[[[[[[@"&tc" stringByAppendingString:i] stringByAppendingString:@"="] + [self currencyTypes][i] stringByAppendingString:@"&tv"] + i stringByAppendingString:@"="] + [self currencyValues][i] stringByAppendingString:@"&ta"] + i stringByAppendingString:@"="] + [self currencyCategories][i]];
  }

  queryString = [self addOptionalParam:queryString param1:@"i" param2:[self itemId]];
  queryString = [self addOptionalParam:queryString param1:@"tq" param2:[self quantity]];
  queryString = [self addOptionalParam:queryString param1:@"to" param2:[self otherUserId]];
  return queryString;
}

- (void) dealloc {
  [itemId release];
  [type release];
  [otherUserId release];
  [currencyTypes release];
  [currencyValues release];
  [currencyCategories release];
  [super dealloc];
}

@end

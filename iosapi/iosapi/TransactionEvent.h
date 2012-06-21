#import "CurrencyCategory.h"
#import "TransactionType.h"

@interface TransactionEvent : PlaynomicsEvent {
  long transactionId;
  NSString * itemId;
  double quantity;
  TransactionType * type;
  NSString * otherUserId;
  NSArray * currencyTypes;
  NSArray * currencyValues;
  NSArray * currencyCategories;
}

@property(nonatomic) long transactionId;
@property(nonatomic, retain) NSString * itemId;
@property(nonatomic) double quantity;
@property(nonatomic, retain) TransactionType * type;
@property(nonatomic, retain) NSString * otherUserId;
@property(nonatomic, retain) NSArray * currencyTypes;
@property(nonatomic, retain) NSArray * currencyValues;
@property(nonatomic, retain) NSArray * currencyCategories;
- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId transactionId:(long)transactionId itemId:(NSString *)itemId quantity:(double)quantity type:(TransactionType *)type otherUserId:(NSString *)otherUserId currencyTypes:(NSArray *)currencyTypes currencyValues:(NSArray *)currencyValues currencyCategories:(NSArray *)currencyCategories;
- (void) setTransactionId:(long)transactionId;
- (void) setItemId:(NSString *)itemId;
- (void) setQuantity:(double)quantity;
- (void) setType:(TransactionType *)type;
- (void) setOtherUserId:(NSString *)otherUserId;
- (void) setCurrencyTypes:(NSArray *)currencyTypes;
- (void) setCurrencyValues:(NSArray *)currencyValues;
- (void) setCurrencyCategories:(NSArray *)currencyCategories;
- (NSString *) toQueryString;
@end

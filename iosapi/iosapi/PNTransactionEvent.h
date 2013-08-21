#import "PNEvent.h"

typedef enum {
    PNCurrencyCategoryReal,
    PNCurrencyCategoryVirtual
} PNCurrencyCategory;

typedef enum {
    PNTransactionBuyItem,
    PNTransactionSellItem,
    PNTransactionReturnItem,
    PNTransactionBuyService,
    PNTransactionSellService,
    PNTransactionReturnService,
    PNTransactionCurrencyConvert,
    PNTransactionInitial,
    PNTransactionFree,
    PNTransactionReward,
    PNTransactionGiftSend,
    PNTransactionGiftReceive
} PNTransactionType;

typedef enum {
    PNCurrencyUSD,
    PNCurrencyFBC,
    PNCurrencyOFD,
    PNCurrencyOFF
} PNCurrencyType;

@interface PNTransactionEvent : PNEvent

@property(nonatomic, assign) signed long long transactionId;
@property(nonatomic, retain) NSString* itemId;
@property(nonatomic, assign) NSInteger quantity;
@property(nonatomic, assign) PNTransactionType type;
@property(nonatomic, retain) NSString* otherUserId;
@property(nonatomic, retain) NSArray* currencyTypes;
@property(nonatomic, retain) NSArray* currencyValues;
@property(nonatomic, retain) NSArray* currencyCategories;

- (id) init:  (PNEventType) eventType applicationId: (signed long long) applicationId userId: (NSString*) userId cookieId: (NSString*) cookieId transactionId: (signed long long) transactionId itemId: (NSString*) itemId quantity: (NSInteger) quantity type: (PNTransactionType) type otherUserId: (NSString*) otherUserId currencyTypes: (NSArray*) currencyTypes currencyValues: (NSArray*) currencyValues currencyCategories: (NSArray*) currencyCategories;
@end

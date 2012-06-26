#import "PlaynomicsEvent.h"

@interface TransactionEvent : PlaynomicsEvent {
    long _transactionId;
    NSString * _itemId;
    double _quantity;
    PLTransactionType _type;
    NSString * _otherUserId;
    NSArray * _currencyTypes;
    NSArray * _currencyValues;
    NSArray * _currencyCategories;
}

@property(nonatomic, assign) long transactionId;
@property(nonatomic, retain) NSString * itemId;
@property(nonatomic, assign) double quantity;
@property(nonatomic, assign) PLTransactionType type;
@property(nonatomic, retain) NSString * otherUserId;
@property(nonatomic, retain) NSArray * currencyTypes;
@property(nonatomic, retain) NSArray * currencyValues;
@property(nonatomic, retain) NSArray * currencyCategories;

/**
 *  currencyTypes: Array of PLCurrencyType String values
 *  currencyValues: Array of NSNumbers containing a double
 *  currencyCategories: Array of PLCurrencyCategory String values
 */
- (id) init:  (PLEventType) eventType 
              applicationId: (long) applicationId 
                     userId: (NSString *) userId 
              transactionId: (long) transactionId 
                     itemId: (NSString *) itemId 
                   quantity: (double) quantity 
                       type: (PLTransactionType) type 
                otherUserId: (NSString *) otherUserId 
              currencyTypes: (NSArray *) currencyTypes
             currencyValues: (NSArray *) currencyValues 
         currencyCategories: (NSArray *) currencyCategories;
@end

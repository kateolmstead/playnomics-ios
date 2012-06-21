#import "PlaynomicsConstants.h"

@class PlaynomicsEvent;

@interface TransactionEvent : PlaynomicsEvent {
    long _transactionId;
    NSString * _itemId;
    double _quantity;
    TransactionType _type;
    NSString * _otherUserId;
    NSArray * _currencyTypes;
    NSArray * _currencyValues;
    NSArray * _currencyCategories;
}

@property(nonatomic, assign) long transactionId;
@property(nonatomic, retain) NSString * itemId;
@property(nonatomic, assign) double quantity;
@property(nonatomic, assign) TransactionType type;
@property(nonatomic, retain) NSString * otherUserId;
@property(nonatomic, retain) NSArray * currencyTypes;
@property(nonatomic, retain) NSArray * currencyValues;
@property(nonatomic, retain) NSArray * currencyCategories;

- (id) init: (EventType) eventType 
              applicationId: (NSNumber *) applicationId 
                     userId: (NSString *) userId 
              transactionId: (long) transactionId 
                     itemId: (NSString *) itemId 
                   quantity: (double) quantity 
                       type: (TransactionType) type 
                otherUserId: (NSString *) otherUserId 
              currencyTypes: (NSArray *) currencyTypes
             currencyValues: (NSArray *) currencyValues 
         currencyCategories: (NSArray *) currencyCategories;
@end

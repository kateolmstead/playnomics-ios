#import "TransactionEvent.h"

@implementation TransactionEvent

@synthesize transactionId=_transactionId;
@synthesize itemId=_itemId;
@synthesize quantity=_quantity;
@synthesize type=_type;
@synthesize otherUserId=_otherUserId;
@synthesize currencyTypes=_currencyTypes;
@synthesize currencyValues=_currencyValues;
@synthesize currencyCategories=_currencyCategories;

- (id) init: (PLEventType) eventType 
              applicationId:(long) applicationId 
                     userId:(NSString *) userId 
              transactionId:(long) transactionId 
                     itemId:(NSString *) itemId 
                   quantity:(double) quantity 
                       type:(PLTransactionType) type 
                otherUserId:(NSString *) otherUserId 
              currencyTypes:(NSArray *) currencyTypes
             currencyValues:(NSArray *) currencyValues 
         currencyCategories:(NSArray *) currencyCategories {
    if (self = [super init: eventType applicationId:applicationId userId:userId]) {
        _transactionId = transactionId;
        _itemId = [itemId retain];
        _quantity = quantity;
        _type = type;
        _otherUserId = [otherUserId retain];
        _currencyTypes = [currencyTypes retain];
        _currencyValues = [currencyValues retain];
        _currencyCategories = [currencyCategories retain];
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat: @"&tt=%@", [self type]];
    
    for (int i = 0; i < [[self currencyTypes] count] ; i++) {
        queryString = [queryString stringByAppendingFormat:@"&tc%d=%@,&tv%d=%@&ta%d=%@", 
                       i, [[self currencyTypes] objectAtIndex:i], 
                       i, [[self currencyValues] objectAtIndex:i],
                       i, [[self currencyCategories] objectAtIndex: i]];
    }
    
    queryString = [self addOptionalParam:queryString name:@"i" value:[self itemId]];
    queryString = [self addOptionalParam:queryString name:@"tq" value: [NSString stringWithFormat:@"%d", [self quantity]]];
    queryString = [self addOptionalParam:queryString name:@"to" value:[self otherUserId]];
    return queryString;
}

- (void) dealloc {
    [_itemId release];
    [_otherUserId release];
    [_currencyTypes release];
    [_currencyValues release];
    [_currencyCategories release];
    
    [super dealloc];
}

@end

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
    NSString * queryString = [[super toQueryString] stringByAppendingFormat: @"&tt=%@", [PLUtil PLTransactionTypeDescription:[self type]]];
    
    for (int i = 0; i < [[self currencyTypes] count] ; i++) {
        queryString = [queryString stringByAppendingFormat:@"&tc%d=%@,&tv%d=%f&ta%d=%@", 
                       i, [[self currencyTypes] objectAtIndex:i], 
                       i, [(NSNumber *) [[self currencyValues] objectAtIndex:i] doubleValue],
                       i, [[self currencyCategories] objectAtIndex: i]];
    }
    
    queryString = [self addOptionalParam:queryString name:@"i" value:[self itemId]];
    queryString = [self addOptionalParam:queryString name:@"tq" value: [NSString stringWithFormat:@"%d", [self quantity]]];
    queryString = [self addOptionalParam:queryString name:@"to" value:[self otherUserId]];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeInt64:_transactionId forKey:@"PLTransactionEvent._transactionId"];
    [encoder encodeObject:_itemId forKey:@"PLTransactionEvent._itemId"];
    [encoder encodeDouble:_quantity forKey:@"PLTransactionEvent._quantity"];
    [encoder encodeInt:_type forKey:@"PLTransactionEvent._type"];
    [encoder encodeObject:_otherUserId forKey:@"PLTransactionEvent._otherUserId"];
    [encoder encodeObject:_currencyTypes forKey:@"PLTransactionEvent._currencyTypes"];
    [encoder encodeObject:_currencyValues forKey:@"PLTransactionEvent._currencyValues"];
    [encoder encodeObject:_currencyCategories forKey:@"PLTransactionEvent._currencyCategories"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _transactionId = [decoder decodeInt64ForKey:@"PLTransactionEvent._transactionId"]; 
        _itemId = [(NSString *)[decoder decodeObjectForKey:@"PLTransactionEvent._itemId"] retain]; 
        _quantity = [decoder decodeDoubleForKey:@"PLTransactionEvent._quantity"]; 
        _type = [decoder decodeIntForKey:@"PLTransactionEvent._type"]; 
        _otherUserId = [(NSString *)[decoder decodeObjectForKey:@"PLTransactionEvent._otherUserId"] retain]; 
        _currencyTypes = [(NSArray *)[decoder decodeObjectForKey:@"PLTransactionEvent._currencyTypes"] retain]; 
        _currencyValues = [(NSArray *)[decoder decodeObjectForKey:@"PLTransactionEvent._currencyValues"] retain]; 
        _currencyCategories = [(NSArray *)[decoder decodeObjectForKey:@"PLTransactionEvent._currencyCategories"] retain]; 
    }
    return self;
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

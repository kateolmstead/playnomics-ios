#import "PNTransactionEvent.h"

@implementation PNTransactionEvent

@synthesize transactionId=_transactionId;
@synthesize itemId=_itemId;
@synthesize quantity=_quantity;
@synthesize type=_type;
@synthesize otherUserId=_otherUserId;
@synthesize currencyTypes=_currencyTypes;
@synthesize currencyValues=_currencyValues;
@synthesize currencyCategories=_currencyCategories;

- (id) init: (PNEventType) eventType 
              applicationId:(signed long long) applicationId
                     userId:(NSString *) userId 
                   cookieId: (NSString *) cookieId
              transactionId:(signed long long) transactionId
                     itemId:(NSString *) itemId 
                   quantity:(double) quantity 
                       type:(PNTransactionType) type 
                otherUserId:(NSString *) otherUserId 
              currencyTypes:(NSArray *) currencyTypes
             currencyValues:(NSArray *) currencyValues 
         currencyCategories:(NSArray *) currencyCategories {
    if (self = [super init: eventType applicationId:applicationId userId:userId cookieId:cookieId]) {
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
    NSString * queryString = [[super toQueryString] stringByAppendingFormat: @"&r=%lld&tt=%@&jsh=%@", [self transactionId], [PNUtil PNTransactionTypeDescription:[self type]], [self internalSessionId]];
    
    for (int i = 0; i < [[self currencyTypes] count] ; i++) {
        id obj = [[self currencyTypes] objectAtIndex:i];
        NSString *currentTypeStr = nil;
        if ([obj isKindOfClass:[NSNumber class]]) {
            currentTypeStr = [PNUtil PNCurrencyTypeDescription: [(NSNumber *) [[self currencyTypes] objectAtIndex:i] intValue]];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            currentTypeStr = (NSString *) obj;
        }
        
        //escape the currency type
        NSString * escapedCurrencyType = [PNUtil UrlEncodeValue:currentTypeStr];
        
        queryString = [queryString stringByAppendingFormat:@"&tc%d=%@&tv%d=%lf&ta%d=%@", 
                       i, escapedCurrencyType, 
                       i, [(NSNumber *) [[self currencyValues] objectAtIndex:i] doubleValue],
                       i, [PNUtil PNCurrencyCategoryDescription:[(NSNumber *) [[self currencyCategories] objectAtIndex: i] intValue]]];
    }
    
    //escape the itemId
    NSString * escapedItemId = [PNUtil UrlEncodeValue:[self itemId]];
    NSString * escapedOtherUserId = [PNUtil UrlEncodeValue:[self otherUserId]];
    
    queryString = [self addOptionalParam:queryString name:@"i" value:escapedItemId];
    queryString = [self addOptionalParam:queryString name:@"tq" value: [NSString stringWithFormat:@"%lf", [self quantity]]];
    queryString = [self addOptionalParam:queryString name:@"to" value: escapedOtherUserId];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeInt64:_transactionId forKey:@"PNTransactionEvent._transactionId"];
    [encoder encodeObject:_itemId forKey:@"PNTransactionEvent._itemId"];
    [encoder encodeDouble:_quantity forKey:@"PNTransactionEvent._quantity"];
    [encoder encodeInt:_type forKey:@"PNTransactionEvent._type"];
    [encoder encodeObject:_otherUserId forKey:@"PNTransactionEvent._otherUserId"];
    [encoder encodeObject:_currencyTypes forKey:@"PNTransactionEvent._currencyTypes"];
    [encoder encodeObject:_currencyValues forKey:@"PNTransactionEvent._currencyValues"];
    [encoder encodeObject:_currencyCategories forKey:@"PNTransactionEvent._currencyCategories"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _transactionId = [decoder decodeInt64ForKey:@"PNTransactionEvent._transactionId"]; 
        _itemId = [(NSString *)[decoder decodeObjectForKey:@"PNTransactionEvent._itemId"] retain]; 
        _quantity = [decoder decodeDoubleForKey:@"PNTransactionEvent._quantity"]; 
        _type = [decoder decodeIntForKey:@"PNTransactionEvent._type"]; 
        _otherUserId = [(NSString *)[decoder decodeObjectForKey:@"PNTransactionEvent._otherUserId"] retain]; 
        _currencyTypes = [(NSArray *)[decoder decodeObjectForKey:@"PNTransactionEvent._currencyTypes"] retain]; 
        _currencyValues = [(NSArray *)[decoder decodeObjectForKey:@"PNTransactionEvent._currencyValues"] retain]; 
        _currencyCategories = [(NSArray *)[decoder decodeObjectForKey:@"PNTransactionEvent._currencyCategories"] retain]; 
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

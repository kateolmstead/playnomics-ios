//
//  PNLogger.m
//  iosapi
//
//  Created by Jared Jenkins on 8/20/13.
//
//

#import "PNLogger.h"

@implementation PNLogger

+(void) logMessage: (NSString*) message{
    NSLog(@"%@", message);
}

+(void) logError: (NSError*) error{
   NSLog(@"Error occurred: %@", error.description);
}

+(void) logException: (NSException*) exception withMessage: (NSString*) message{
    NSLog(@"%@", message);
    [PNLogger logException:exception];
}

+(void) logException: (NSException*) exception{
    NSLog(@"Exception details:");
    NSLog(@"Name: %@", exception.name);
    NSLog(@"Reason: %@", exception.reason);
}
@end

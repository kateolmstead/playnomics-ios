//
//  PNLogger.h
//  iosapi
//
//  Created by Jared Jenkins on 8/20/13.
//
//

#import <UIKit/UIKit.h>

@interface PNLogger : NSObject
+(void) logMessage: (NSString*) message;
+(void) logError: (NSError*) error;
+(void) logException: (NSException*) exception withMessage: (NSString*) message;
+(void) logException: (NSException*) exception;
@end

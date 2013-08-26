//
//  PNLogger.h
//  iosapi
//
//  Created by Jared Jenkins on 8/20/13.
//
//

#import <UIKit/UIKit.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif
typedef NS_ENUM(int, PNLoggingLevel){
    PNLogLevelNone      = 0,
    PNLogLevelDebug     = 1,
    PNLogLevelWarning   = 3,
    PNLogLevelError     = 7
};

@interface PNLogger : NSObject
+(void) setLoggingLevel: (PNLoggingLevel) level;
+(void) log: (PNLoggingLevel) level format: (NSString *) format, ...;
+(void) log: (PNLoggingLevel) level exception: (NSException *) exception;
+(void) log: (PNLoggingLevel) level exception: (NSException *) exception format: (NSString *) format, ...;
+(void) log: (PNLoggingLevel) level error: (NSError *) exception;
+(void) log: (PNLoggingLevel) level error: (NSError *) error format: (NSString *) format, ...;
@end

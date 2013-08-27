//
//  PNLogger.m
//  iosapi
//
//  Created by Jared Jenkins on 8/20/13.
//
//

#import "PNLogger.h"


static PNLoggingLevel _logLevel = PNLogLevelError;

@implementation PNLogger
+(void) setLoggingLevel: (PNLoggingLevel) level{
    _logLevel = level;
}

+(void) log: (PNLoggingLevel) level format: (NSString *) format, ...{
    if(level & _logLevel){
        va_list args;
        va_start(args, format);
        NSLog(format, args);
        va_end(args);
    }
}

+(void) log: (PNLoggingLevel) level exception: (NSException *) exception{
    if(level & _logLevel){
        NSLog(@"Exception details:");
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
    }
}

+(void) log: (PNLoggingLevel) level exception: (NSException *) exception format: (NSString *) format, ...{
    if(level & _logLevel){
        va_list args;
        va_start(args, format);
        NSLog(format, args);
        va_end(args);
        NSLog(@"Exception details:");
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
    }
}

+(void) log: (PNLoggingLevel) level error: (NSError *) error{
    if(level & _logLevel){
        NSLog(@"Error details:");
        NSLog(@"Description: %@", error.debugDescription);
    }
}

+(void) log: (PNLoggingLevel) level error: (NSError *) error format: (NSString *) format, ...{
    if(level & _logLevel){
        va_list args;
        va_start(args, format);
        NSLog(format, args);
        va_end(args);
        NSLog(@"Error details:");
        NSLog(@"Description: %@", error.debugDescription);
    }
}
@end

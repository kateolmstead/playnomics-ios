//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "PlaynomicsMessaging.h"
#import "PlaynomicsFrame+Exposed.h"

@interface PlaynomicsMessaging (Exposed)
// Retrieve the action handler bound to the label and perform the action on it.  If no handler is bound
//   to the provided label, nothing occurrs and no error is sent.
- (void)performActionForLabel:(NSString *)label;

// Perform the provided non-argument action on the current delegate.  This method will check if the current
//   delegate has a selector to handle this action before execution, and will capture and log any
//   exception the selector throws.
- (void)executeActionOnDelegate:(NSString *)action;
@end
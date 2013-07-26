//
//  PlaynomicsCallback.m
//  iosapi
//
//  Created by Eric McConkie on 2/26/13.
//
//

#import "PlaynomicsCallback.h"
#import "FSNConnection.h"
@implementation PlaynomicsCallback



- (void)submitRequestToServer:(NSString *)impressionUrl {
    if (impressionUrl==nil || impressionUrl.length<=0)
        return;//we will crash here...stop everything
    
    NSURL *url = [NSURL URLWithString:impressionUrl];
    NSLog(@"Submitting GET request to impression URL: %@", impressionUrl);
    
    FSNConnection *connection =
    [FSNConnection withUrl:url
                    method:FSNRequestMethodGET
                   headers:nil
                parameters:nil
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData stringFromUTF8];
                }
           completionBlock:^(FSNConnection *c) {
               NSLog(@"********************\r\n---> ");
               NSLog(@"Impression URL complete: error: %@, result: %@", c.error, c.parseResult);
               NSLog(@"********************\r\n---> ");
           }
             progressBlock:nil];
    
    [connection start];
}
@end

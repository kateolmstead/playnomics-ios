//
// Created by jmistral on 10/3/12.
//
#import <Foundation/Foundation.h>
#import "PlaynomicsFrame.h"

@protocol PNAdClickActionHandler
@required
- (void)performActionOnAdClicked;
@end

@protocol PNFrameDelegate <NSObject>
@required
-(void) onClick: (NSDictionary*) jsonData;
@end


@interface PlaynomicsMessaging : NSObject

// The delegate all Playnomics Execution calls will be forwarded to.  Only one execution delegate can be
// set at any given time.
@property (retain) id delegate;
@property (nonatomic)BOOL isTesting;

+ (PlaynomicsMessaging *)sharedInstance;

// Register an action handler with the messaging framework bound to the provided label
- (void)registerActionHandler:(id<PNAdClickActionHandler>)clickAction withLabel:(NSString *)label;
- (PlaynomicsFrame *)createFrameWithId:(NSString *)frameId;
- (PlaynomicsFrame *)createFrameWithId:(NSString*)frameId frameDelegate: (id<PNFrameDelegate>)frameDelegate;
@end
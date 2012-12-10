//
//  ViewController.h
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaynomicsSession.h"

@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *transactionCount;

- (IBAction) onGameStartClick:(id)sender;
- (IBAction) onGameEndClick:(id)sender;
- (IBAction) onSendInvitationClick:(id)sender;
- (IBAction) onRespondToInvitationClick:(id)sender;
- (IBAction) onTransactionClick:(id)sender;
- (IBAction) onUserInfoClick:(id)sender;
- (IBAction) onChangeUserClick:(id)sender;
- (IBAction) onMilestoneClick:(id)sender;
- (void) handlePLAPIRResult: (PNAPIResult) result;
@end

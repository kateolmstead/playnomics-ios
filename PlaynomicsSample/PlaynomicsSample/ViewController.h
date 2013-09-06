//
//  ViewController.h
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playnomics.h"
#import "AdColonyPublic.h"

@interface ViewController : UIViewController <UITextFieldDelegate, AdColonyTakeoverAdDelegate>

@property (nonatomic, retain) IBOutlet UITextField *transactionCount;
@property (retain, nonatomic) IBOutlet UITextField *frameIdText;

- (IBAction) onTransactionClick:(id)sender;

- (IBAction) onHttpClick: (id)sender;
- (IBAction) onJsonClick: (id)sender;
- (IBAction) onNullTargetClick: (id)sender;
- (IBAction) onPnxClick: (id)sender;
- (IBAction) onNoAdsClick:(id)sender;
- (IBAction) onVideoAdClick:(id)sender;
- (IBAction) onWebViewClick:(id)sender;

- (IBAction) onMilestoneClick:(id)sender;

-(void)onPnx;
@end

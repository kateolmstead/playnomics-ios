
//
//  ViewController.m
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "ViewController.h"
#import "Playnomics.h"
#import "FrameDelegate.h"

@implementation ViewController{
    FrameDelegate* _frameDelegate;
//    PlaynomicsFrame *videoFrame;
}
@synthesize transactionCount;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _frameDelegate = [[FrameDelegate alloc] init];
    [super viewDidLoad];
    //[Playnomics preloadFramesWithIds:@"ec964fdf18af3d80", @"7a9138a971ce1773", @"c6877f336e9d9dda", @"546e241b9b97149b", @"15bec4e2b78424a2", nil];
    _frameIdText.delegate = self;
}

- (void)viewDidUnload
{
    [_frameDelegate release];
    [self setFrameIdText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_frameIdText resignFirstResponder];
    
    return YES;
}

#pragma mark - Button receivers

- (IBAction) onTransactionClick:(id)sender {
    NSNumber* price = [NSNumber numberWithDouble:.99];
    [Playnomics transactionWithUSDPrice: price quantity: 1];
}

- (IBAction) onUserInfo:(id)sender {
    [Playnomics attributeInstallToSource:@"source" withCampaign:@"campaign" onInstallDate:[NSDate date]];
}

- (IBAction) onMilestoneClick:(id)sender {
    [Playnomics milestone : PNMilestoneCustom1];
    [Playnomics milestone : PNMilestoneCustom2];
    [Playnomics milestone : PNMilestoneCustom3];
    [Playnomics milestone : PNMilestoneCustom4];
    [Playnomics milestone : PNMilestoneCustom5];
}

- (IBAction)onHttpClick:(id)sender {
    [self initMsgFrame:@"ec964fdf18af3d80"];
}

- (IBAction)onJsonClick:(id)sender {
    [self initMsgFrame:@"7a9138a971ce1773"];    
}

- (IBAction)onNullTargetClick:(id)sender {
    [self initMsgFrame:@"c6877f336e9d9dda"];    
}

- (IBAction)onPnxClick:(id)sender {
    [self initMsgFrame:@"546e241b9b97149b"];   
}

-(IBAction)onNoAdsClick:(id)sender{
    [self initMsgFrame:@"15bec4e2b78424a2"];
}

-(IBAction)onVideoAdClick:(id)sender{
    [self initMsgFrame:@"e028a4547a9e438f"];
}

-(IBAction)onWebViewClick:(id)sender{
    [self initMsgFrame:@"33a3cf0ecfa71c1a"];
}

- (void) initMsgFrame: (NSString *) frameId {
    [Playnomics showFrameWithId: frameId delegate: _frameDelegate];
 }

#pragma mark Misc Functions

- (void)dealloc {
    [_frameIdText release];
    [super dealloc];
}

- (void)adColonyTakeoverBeganForZone:(NSString*)zone {
    NSLog(@"AdColony video ad launched for zone %@",zone);
}

- (void)adColonyTakeoverEndedForZone:(NSString*)zone withVC:(BOOL)withVirtualCurrencyAward {
    //NSLog(@"AdColony video ad finished for zone %@ and boolean %d",zone,withVirtualCurrencyAward);
    //[videoFrame sendVideoView];
}

- (void)adColonyVideoAdNotServedForZone:(NSString*)zone {
    NSLog(@"AdColonydidnotserveavideoforzone%@",zone);
}

@end

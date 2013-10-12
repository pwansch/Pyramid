//
//  FlipsideViewController.m
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"

@interface FlipsideViewController ()
- (IBAction)timerSwitchChanged:(id)sender;
@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    self.preferredContentSize = CGSizeMake(320.0, 568.0);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.screenSize = [[UIScreen mainScreen] bounds];
        UIScrollView *scrollView = (UIScrollView *)self.view;
        scrollView.contentSize = CGSizeMake(self.screenSize.size.width, self.screenSize.size.height);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	// Load settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.animationSwitch.on = [defaults boolForKey:kAnimationKey];
	self.soundSwitch.on = [defaults boolForKey:kSoundKey];
	self.turnOverSwitch.on = [defaults boolForKey:kTurnOverDeckKey];
	self.timerSwitch.on = [defaults boolForKey:kTimerKey];
    self.cardBackControl.selectedSegmentIndex = [defaults integerForKey:kCardBackKey];
    self.oneControl.selectedSegmentIndex = ([defaults boolForKey:kOneKey] ? 0 : 1);
    self.textView.editable = NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(orientation)) {
        self.textView.frame = CGRectMake(20, 347, 280, self.screenSize.size.height - 367);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(orientation)) {
        self.textView.frame = CGRectMake(20, 347, self.screenSize.size.height - 40, self.screenSize.size.height - 367);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSRange r = {0,0};
    [self.textView scrollRangeToVisible:r];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
	// Save settings and write to disk
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.animationSwitch.on forKey:kAnimationKey];
	[defaults setBool:self.soundSwitch.on forKey:kSoundKey];
	[defaults setBool:self.turnOverSwitch.on forKey:kTurnOverDeckKey];
	[defaults setBool:self.timerSwitch.on forKey:kTimerKey];
    [defaults setInteger:self.cardBackControl.selectedSegmentIndex forKey:kCardBackKey];
    [defaults setBool:(self.oneControl.selectedSegmentIndex == 0) forKey:kOneKey];
	[defaults synchronize];
    
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)reset:(id)sender
{
	// Save settings and write to disk
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:-28 forKey:kCasinoScoreKey];
    [defaults synchronize];
    [self.delegate flipsideViewControllerResetScores];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view
    self.animationSwitch = nil;
	self.soundSwitch = nil;
    self.turnOverSwitch = nil;
    self.timerSwitch = nil;
    self.cardBackControl = nil;
    self.oneControl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation !=	UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (IBAction)timerSwitchChanged:(id)sender {
    [self.resetButton setEnabled:(self.timerSwitch.on ? YES : NO)];
}
@end

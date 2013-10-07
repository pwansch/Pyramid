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

@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    self.preferredContentSize = CGSizeMake(320.0, 568.0);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIScrollView *scrollView = (UIScrollView *)self.view;
        scrollView.contentSize = CGSizeMake(320.0, 568.0);
        [super awakeFromNib];
    }
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
    [defaults setBool:self.animationSwitch.on forKey:kAnimationKey];
	[defaults setBool:self.soundSwitch.on forKey:kSoundKey];
	[defaults setBool:self.turnOverSwitch.on forKey:kTurnOverDeckKey];
	[defaults setBool:self.timerSwitch.on forKey:kTimerKey];
    [defaults setInteger:self.cardBackControl.selectedSegmentIndex forKey:kCardBackKey];
    [defaults setBool:(self.oneControl.selectedSegmentIndex == 0) forKey:kOneKey];
    [defaults synchronize];
    [self.delegate flipsideViewControllerResetScores];
}

- (void)viewDidUnload {
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

@end

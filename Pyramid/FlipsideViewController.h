//
//  FlipsideViewController.h
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (void)flipsideViewControllerResetScores;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISwitch *animationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *timerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *turnOverSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *cardBackControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *oneControl;

- (IBAction)done:(id)sender;
- (IBAction)reset:(id)sender;

@end

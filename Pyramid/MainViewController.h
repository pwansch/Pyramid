//
//  MainViewController.h
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "FlipsideViewController.h"

#define kVersionKey			@"version"
#define kSoundKey			@"sound"
#define kCasinoScoreKey	    @"casinoScore"
#define kTimerKey	        @"timer"
#define kTurnOverDeckKey    @"turnOverDeck"
#define kOneKey             @"one"
#define kCardBackKey        @"cardBack"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *gameButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) CADisplayLink *gameTimer;
@property (strong, nonatomic) NSMutableArray *stack;
@property (strong, nonatomic) NSMutableArray *stackDown;
@property (strong, nonatomic) NSMutableArray *down;
@property (strong, nonatomic) NSMutableArray *cards;
@property (assign, nonatomic) CFTimeInterval lastTime;
@property (assign, nonatomic) SystemSoundID newId;
@property (assign, nonatomic) BOOL m_sound;
@property (assign, nonatomic) BOOL fTurnOverDeck;
@property (assign, nonatomic) BOOL fOne;
@property (assign, nonatomic) short sCardBack;
@property (assign, nonatomic) BOOL fGameOver;


- (IBAction)newGame:(id)sender;
- (void)playSound:(SystemSoundID)soundID;
- (void)updateScore:(CADisplayLink*)sender;

@end

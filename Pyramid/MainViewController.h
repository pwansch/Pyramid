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
#import "CardView.h"

#define kVersionKey			@"version"
#define kAnimationKey       @"animation"
#define kSoundKey			@"sound"
#define kCasinoScoreKey	    @"casinoScore"
#define kTimerKey	        @"timer"
#define kTurnOverDeckKey    @"turnOverDeck"
#define kOneKey             @"one"
#define kCardBackKey        @"cardBack"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *gameButton;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) CardView *firstCard;
@property (strong, nonatomic) CardView *undoCard1;
@property (strong, nonatomic) CardView *undoCard2;
@property (assign, nonatomic) long lUndoScore;
@property (assign, nonatomic) long lUndoCasinoScore;
@property (strong, nonatomic) CADisplayLink *gameTimer;
@property (strong, nonatomic) NSMutableArray *stack;
@property (strong, nonatomic) NSMutableArray *stackDown;
@property (strong, nonatomic) NSMutableArray *down;
@property (strong, nonatomic) NSMutableArray *cards;
@property (assign, nonatomic) CFTimeInterval lastTime;
@property (assign, nonatomic) SystemSoundID newId;
@property (assign, nonatomic) SystemSoundID pauseId;
@property (assign, nonatomic) SystemSoundID continueId;
@property (assign, nonatomic) SystemSoundID illegalId;
@property (assign, nonatomic) SystemSoundID matchId;
@property (assign, nonatomic) SystemSoundID selectId;
@property (assign, nonatomic) SystemSoundID flipId;
@property (assign, nonatomic) SystemSoundID wonId;
@property (assign, nonatomic) SystemSoundID undoId;
@property (assign, nonatomic) BOOL fAnimation;
@property (assign, nonatomic) BOOL m_sound;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL m_started;
@property (assign, nonatomic) BOOL fOne;
@property (assign, nonatomic) short sCardBack;
@property (assign, nonatomic) BOOL fGameOver;
@property (assign, atomic) BOOL fUndo;

- (IBAction)newGame:(id)sender;
- (IBAction)pauseGame:(id)sender;
- (IBAction)undo:(id)sender;
- (void)playSound:(SystemSoundID)soundID;
- (void)updateScore:(CADisplayLink*)sender;
- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)cardTappable:(unsigned short)cardIndex;
- (unsigned short)faceValue:(unsigned short)cardValue;

@end

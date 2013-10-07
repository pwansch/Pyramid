//
//  MainViewController.m
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize gameButton;
@synthesize pauseButton;
@synthesize newId;
@synthesize continueId;
@synthesize pauseId;
@synthesize illegalId;
@synthesize matchId;
@synthesize selectId;
@synthesize flipId;
@synthesize wonId;
@synthesize fGameOver;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize the randomizer
    srandom((int)time(NULL));

    // Create system sounds
    NSString *path = [[NSBundle mainBundle] pathForResource:@"new" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &newId);
    path = [[NSBundle mainBundle] pathForResource:@"continue" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &continueId);
    path = [[NSBundle mainBundle] pathForResource:@"pause" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &pauseId);
    path = [[NSBundle mainBundle] pathForResource:@"illegal" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &illegalId);
    path = [[NSBundle mainBundle] pathForResource:@"match" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &matchId);
    path = [[NSBundle mainBundle] pathForResource:@"select" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &selectId);
    path = [[NSBundle mainBundle] pathForResource:@"flip" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &flipId);
    path = [[NSBundle mainBundle] pathForResource:@"won" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &wonId);
    
    // Initialize settings
    self.m_started = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.fAnimation = [defaults boolForKey:kAnimationKey];
    self.m_sound = [defaults boolForKey:kSoundKey];
    self.fOne = [defaults boolForKey:kOneKey];
    self.sCardBack = [defaults integerForKey:kCardBackKey];
    MainView *mainView = (MainView *)self.view;
    mainView.fTurnOverDeck = [defaults boolForKey:kTurnOverDeckKey];
    mainView.lCasinoScore = [defaults integerForKey:kCasinoScoreKey];
    mainView.fTimer = [defaults boolForKey:kTimerKey];
    
    // Create the card arrays
    self.stack = [[NSMutableArray alloc] initWithCapacity:NOCARDS - NOINDEXES];
    self.stackDown = [[NSMutableArray alloc] initWithCapacity:NOCARDS];
    self.down = [[NSMutableArray alloc] initWithCapacity:NOCARDS];
    self.cards = [[NSMutableArray alloc] initWithCapacity:NOINDEXES];

    // Initialize variables
    [self initializeGame];
    
    // Start timer
    self.lastTime = 0.0;
    self.gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScore:)];
    [self.gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
	// Save the settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.fAnimation = [defaults boolForKey:kAnimationKey];
    self.m_sound = [defaults boolForKey:kSoundKey];
    self.fOne = [defaults boolForKey:kOneKey];
    self.sCardBack = [defaults integerForKey:kCardBackKey];
    MainView *mainView = (MainView *)self.view;
    mainView.fTurnOverDeck = [defaults boolForKey:kTurnOverDeckKey];
    mainView.lCasinoScore = [defaults integerForKey:kCasinoScoreKey];
    mainView.fTimer = [defaults boolForKey:kTimerKey];

    // Change the card back
    for (CardView *card in self.cards) {
        if (card != (CardView *)[NSNull null]) {
            [card setBack:self.sCardBack];
        }
    }
    for (CardView *card in self.stack) {
        [card setBack:self.sCardBack];
    }
    for (CardView *card in self.stackDown) {
        [card setBack:self.sCardBack];
    }
    for (CardView *card in self.down) {
        [card setBack:self.sCardBack];
    }
    
    // Invalidate score and stack
    [mainView invalidateLine:1];
    [mainView invalidateLine:2];
    [mainView invalidateLine:3];
    [mainView invalidateStack];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)flipsideViewControllerResetScores
{
    MainView *mainView = (MainView *)self.view;
    mainView.lCasinoScore = -28;
    [mainView invalidateLine:1];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)newGame:(id)sender
{
    MainView *mainView = (MainView *)self.view;
    if(!self.fGameOver) {
        if (!self.m_started) {
            self.m_started = YES;
            if (mainView.fTimer && self.m_started) {
                self.pauseButton.hidden = NO;
            } else {
                self.pauseButton.hidden = YES;
            }
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to start a new game?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
            [actionSheet showInView:self.view];
        }
    } else {
        if(self.m_started && mainView.fTimer) {
            for (CardView *card in self.cards) {
                if (card != (CardView *)[NSNull null]) {
                    mainView.lCasinoScore -= 5;
                }
            }
        }
        [self initializeGame];
        self.m_started = YES;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        MainView *mainView = (MainView *)self.view;
        if(self.m_started && mainView.fTimer) {
            for (CardView *card in self.cards) {
                if (card != (CardView *)[NSNull null]) {
                    mainView.lCasinoScore -= 5;
                }
            }
        }
        [self initializeGame];
        self.m_started = YES;
    }
}

- (IBAction)pauseGame:(id)sender {
    if (!self.fGameOver && self.m_started) {
        MainView *mainView = (MainView *)self.view;
        if (mainView.fPaused) {
            [self playSound:continueId];
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            mainView.fPaused = NO;
        } else {
            [self playSound:pauseId];
            [self.pauseButton setTitle:@"Continue" forState:UIControlStateNormal];
            mainView.fPaused = YES;
        }
        
        // Redraw paused line
        [mainView invalidateLine:3];
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
	// Release any retained subviews of the main view
	self.gameButton = nil;
    self.pauseButton = nil;
    self.infoButton = nil;
    self.flipsidePopoverController = nil;
    
    // Dispose sounds
    AudioServicesDisposeSystemSoundID(newId);
    AudioServicesDisposeSystemSoundID(continueId);
    AudioServicesDisposeSystemSoundID(pauseId);
    AudioServicesDisposeSystemSoundID(illegalId);
    AudioServicesDisposeSystemSoundID(matchId);
    AudioServicesDisposeSystemSoundID(selectId);
    AudioServicesDisposeSystemSoundID(flipId);
    AudioServicesDisposeSystemSoundID(wonId);
}

- (void) playSound:(SystemSoundID)soundID {
	if (self.m_sound) {
		AudioServicesPlaySystemSound(soundID);
	}
}

- (void)initializeGame {
    MainView *mainView = (MainView *)self.view;
    
	// Play the new game sound
	[self playSound:newId];
    
	// Initialize the game
    self.fGameOver = NO;
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    if (mainView.fTimer && self.m_started) {
        self.pauseButton.hidden = NO;
    } else {
        self.pauseButton.hidden = YES;
    }
    mainView.fPaused = NO;
	mainView.ulTime = 0;
    mainView.lScore = -NOINDEXES;
    mainView.text = nil;
    
    // Update the view
    [mainView invalidateLine:1];
    [mainView invalidateLine:3];
    [mainView invalidateText];

    // Remove all cards
    for (CardView *card in self.cards) {
        if (card != (CardView *)[NSNull null]) {
            [card removeFromSuperview];
        }
    }
    for (CardView *card in self.stack) {
        [card removeFromSuperview];
    }
    for (CardView *card in self.stackDown) {
        [card removeFromSuperview];
    }
    for (CardView *card in self.down) {
        [card removeFromSuperview];
    }
    
    // Initialize the cards
    [self.stack removeAllObjects];
    [self.stackDown removeAllObjects];
    [self.down removeAllObjects];
    [self.cards removeAllObjects];
    CardView *card;
    short sTemp;
    BOOL fPicked[NOCARDS];
    for (int i = 0; i < NOCARDS; i++) {
        fPicked[i] = NO;
    }
    for (int i = 0; i < NOINDEXES; i++) {
		do {
			sTemp = abs(random() % NOCARDS);
		} while (fPicked[sTemp]);
		fPicked[sTemp] = YES;
        card = [[CardView alloc] initWithFrame:[mainView cardFrame:i] :sTemp :self.sCardBack :NO :Cards :i];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired = 1;
        [card addGestureRecognizer:tap];
        [self.cards addObject:card];
        [self.view addSubview:card];
    }
    
    for (int i = 0; i < (NOCARDS - NOINDEXES); i++) {
		do {
			sTemp = abs(random() % NOCARDS);
		} while (fPicked[sTemp]);
		fPicked[sTemp] = YES;
        card = [[CardView alloc] initWithFrame:[mainView stackFrame] :sTemp :self.sCardBack :YES :Stack :i];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired = 1;
        [card addGestureRecognizer:tap];
        [self.stack addObject:card];
        [self.view addSubview:card];
    }
    self.firstCard = nil;
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.fGameOver && self.m_started) {
        MainView *mainView = (MainView *)self.view;
        BOOL fClicked = NO;
        CardView *tappedCard = (CardView *)gestureRecognizer.view;
        if (tappedCard.position == Cards && [self cardTappable:tappedCard.positionIndex]) {
            goto _bearbeiten;
        } else if (tappedCard.position == StackDown && tappedCard == [self.stackDown lastObject]) {
            goto _bearbeiten;
        }
        
        goto _weiter;
    _bearbeiten:
		// auf die Karte kann man klicken
		// ist es die erste Karte
		fClicked = YES;
		if(self.firstCard == nil)
		{
			// ist es ein Koenig
			if([self faceValue:(tappedCard.cardValue)] == 13)
			{
				[self playSound:matchId];
                if(tappedCard.position == StackDown) {
                    tappedCard.indent = 0;
                    [self.stackDown removeObject:tappedCard];
                } else if(self.firstCard.position == Cards) {
                    [self.cards replaceObjectAtIndex:tappedCard.positionIndex withObject:[NSNull null]];
                }
                [mainView bringSubviewToFront:tappedCard];
                tappedCard.frame = [mainView downFrame];
                tappedCard.position = Down;
                [self.down addObject:tappedCard];
				mainView.lScore += 13;
				if(mainView.fTimer)
					mainView.lCasinoScore += 13;
                [mainView invalidateLine:1];
			}
			else
			{
				[self playSound:selectId];
				self.firstCard = tappedCard;
                [tappedCard tapCard];
			}
		} else {
			// es ist die zweite Karte
			if (self.firstCard == tappedCard)
			{
                [self playSound:selectId];
				self.firstCard = nil;
                [tappedCard tapCard];
				goto _weiter;
			}
            
            if(([self faceValue:(self.firstCard.cardValue)] + [self faceValue:(tappedCard.cardValue)]) == 13)
			{
				// beide kommen weg
				[self playSound:matchId];
                if(tappedCard.position == StackDown) {
                    tappedCard.indent = 0;
                    [self.stackDown removeObject:tappedCard];
                } else if(tappedCard.position == Cards) {
                    [self.cards replaceObjectAtIndex:tappedCard.positionIndex withObject:[NSNull null]];
                }
                [mainView bringSubviewToFront:tappedCard];
                tappedCard.frame = [mainView downFrame];
                tappedCard.position = Down;
                [self.down addObject:tappedCard];
                [self.cards replaceObjectAtIndex:tappedCard.positionIndex withObject:[NSNull null]];
                mainView.lScore += 13;
				if(mainView.fTimer)
					mainView.lCasinoScore += 13;
                [mainView invalidateLine:1];
                    
				// karte entfernen
                if(self.firstCard.position == StackDown) {
                    self.firstCard.indent = 0;
                    [self.stackDown removeObject:self.firstCard];
                } else if(self.firstCard.position == Cards) {
                    [self.cards replaceObjectAtIndex:self.firstCard.positionIndex withObject:[NSNull null]];
                }
                [self.firstCard bringSubviewToFront:tappedCard];
                self.firstCard.frame = [mainView downFrame];
                self.firstCard.position = Down;
                [self.down addObject:self.firstCard];
                self.firstCard = nil;
            }
			else
			{
				// erste Karte wieder normal setzen
                [self playSound:illegalId];
                [self.firstCard tapCard];
                self.firstCard = nil;
			}
		}
        
    _weiter:
        if (tappedCard.position == Stack && tappedCard == [self.stack lastObject]) {
			fClicked = TRUE;
			// user will Karten vom Stapel aufdecken
            // es sind noch Karten am Stapel
            short sCount;
			if(self.fOne)
				sCount = 1;
			else
				sCount = 3;
			for (int k = 0; k < sCount; k++)
			{
				if(self.firstCard != nil && self.firstCard.position == StackDown) {
                    [self.firstCard tapCard];
                    self.firstCard = nil;
                }
                
				// Karte aufdecken und in Stack down stecken
				[self playSound:flipId];
                CardView *card = [self.stack lastObject];
                [card flipCard];
                [mainView bringSubviewToFront:card];
                CGRect frame = [mainView stackDownFrame];
                frame.origin.x += k * [mainView indent];
                card.frame = frame;
                card.indent = k;
                card.position = StackDown;
                [self.stackDown addObject:card];
                [self.stack removeObject:card];
				mainView.lScore--;
				if(mainView.fTimer)
					mainView.lCasinoScore--;
                [mainView invalidateLine:1];
			}
        }
        
		if([self.cards objectAtIndex:0] == [NSNull null])
		{
			// Spiel gewonnen
			self.fGameOver = YES;
            [self playSound:wonId];
            self.pauseButton.hidden = YES;
            mainView.text = [[NSString alloc] initWithFormat: @"You win."];
		}
        
		if(!fClicked)
			[self playSound:illegalId];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.fGameOver && self.m_started) {
        MainView *mainView = (MainView *)self.view;
    
        // Get touch position
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:mainView];
        if (CGRectContainsPoint([mainView stackFrame], point)) {
            if(mainView.fTurnOverDeck && [self.stackDown count] > 0)
            {
                // es sind keine Karten mehr am Stapel
                // letzte Karte suchen
                [self playSound:flipId];
                NSEnumerator *enumerator = [self.stackDown reverseObjectEnumerator];
                for (CardView *card in enumerator) {
                    [card flipCard];
                    [mainView bringSubviewToFront:card];
                    card.frame = [mainView stackFrame];
                    card.position = Stack;
                    [self.stack addObject:card];
                    card.indent = 0;
                    [self.stackDown removeObject:card];
                    mainView.lScore -= 5;
                    if(mainView.fTimer)
                        mainView.lCasinoScore -= 5;
                    [mainView invalidateLine:1];
                }
            }
            else
                [self playSound:illegalId];
        }
    }
}

- (void)updateScore:(CADisplayLink*)sender
{
    MainView *mainView = (MainView *)self.view;
    if (self.lastTime == 0.0) {
        self.lastTime = sender.timestamp;
    } else if ((sender.timestamp - self.lastTime) >= 1.0) {
        self.lastTime = sender.timestamp;
        if (self.m_started && !self.fGameOver && !mainView.fPaused && mainView.fTimer) {
            mainView.ulTime++;
            [mainView invalidateLine:3];
            if((mainView.ulTime % 10) == 0) {
                if(mainView.fTimer) {
                    mainView.lCasinoScore--;
                }
                mainView.lScore--;
                [mainView invalidateLine:1];
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation !=	UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Dismiss popover if it is displayed
    if (self.flipsidePopoverController != nil) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
    
    // Change the location of the cards
    MainView *mainView = (MainView *)self.view;
    for (CardView *card in self.cards) {
        if (card != (CardView *)[NSNull null]) {
            card.frame = [mainView cardFrame:[card positionIndex]];
        }
    }
    
    // Change the location of the stack cards
    for (CardView *card in self.stack) {
        card.frame = [mainView stackFrame];
    }
    
    // Change the location of the stack down cards
    for (CardView *card in self.stackDown) {
        CGRect frame = [mainView stackDownFrame];
        frame.origin.x += card.indent * [mainView indent];
        card.frame = frame;
    }
    
    // Change the location of the down cards
    for (CardView *card in self.down) {
        card.frame = [mainView downFrame];
    }
}

- (BOOL)cardTappable:(unsigned short)cardIndex {
    if([self.cards objectAtIndex:cardIndex] == [NSNull null]) {
        return NO;
    }
    
    if(cardIndex > 20) {
        return YES;
    }
    
    switch (cardIndex) {
        case 0:
            if(!(([self.cards objectAtIndex:1] == [NSNull null] && [self.cards objectAtIndex:2] == [NSNull null]) ||
                 (self.firstCard.positionIndex == 1 && [self.cards objectAtIndex:2] == [NSNull null]) ||
                 ([self.cards objectAtIndex:1] == [NSNull null] && self.firstCard.positionIndex == 2))) {
                return NO;
            }
            break;
            
        case 1:
        case 2:
            if(!(([self.cards objectAtIndex:cardIndex + 2] == [NSNull null] && [self.cards objectAtIndex:cardIndex + 3] == [NSNull null]) ||
                 (self.firstCard.positionIndex == (cardIndex + 2) && [self.cards objectAtIndex:cardIndex + 3] == [NSNull null]) ||
                 ([self.cards objectAtIndex:cardIndex + 2] == [NSNull null] && self.firstCard.positionIndex == (cardIndex + 3)))) {
                return NO;
            }
            break;
            
        case 3:
        case 4:
        case 5:
            if(!(([self.cards objectAtIndex:cardIndex + 3] == [NSNull null] && [self.cards objectAtIndex:cardIndex + 4] == [NSNull null]) ||
                 (self.firstCard.positionIndex == (cardIndex + 3) && [self.cards objectAtIndex:cardIndex + 4] == [NSNull null]) ||
                 ([self.cards objectAtIndex:cardIndex + 3] == [NSNull null] && self.firstCard.positionIndex == (cardIndex + 4)))) {
                return NO;
            }
            break;
            
        case 6:
        case 7:
        case 8:
        case 9:
            if(!(([self.cards objectAtIndex:cardIndex + 4] == [NSNull null] && [self.cards objectAtIndex:cardIndex + 5] == [NSNull null]) ||
                 (self.firstCard.positionIndex == (cardIndex + 4) && [self.cards objectAtIndex:cardIndex + 5] == [NSNull null]) ||
                 ([self.cards objectAtIndex:cardIndex + 4] == [NSNull null] && self.firstCard.positionIndex == (cardIndex + 5)))) {
                return NO;
            }
            break;
            
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
            if(!(([self.cards objectAtIndex:cardIndex + 5] == [NSNull null] && [self.cards objectAtIndex:cardIndex + 6] == [NSNull null]) ||
                 (self.firstCard.positionIndex == (cardIndex + 5) && [self.cards objectAtIndex:cardIndex + 6] == [NSNull null]) ||
                 ([self.cards objectAtIndex:cardIndex + 5] == [NSNull null] && self.firstCard.positionIndex == (cardIndex + 6)))) {
                return NO;
            }
            break;
            
        case 15:
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
            if(!(([self.cards objectAtIndex:cardIndex + 6] == [NSNull null] && [self.cards objectAtIndex:cardIndex + 7] == [NSNull null]) ||
                 (self.firstCard.positionIndex == (cardIndex + 6) && [self.cards objectAtIndex:cardIndex + 7] == [NSNull null]) ||
                 ([self.cards objectAtIndex:cardIndex + 6] == [NSNull null] && self.firstCard.positionIndex == (cardIndex + 7)))) {
                return NO;
            }
            break;
    }
    return YES;
}

- (unsigned short)faceValue:(unsigned short)cardValue {
    unsigned short usTemp;
    
    if(cardValue < 13) {
        usTemp = cardValue;
    }
    else {
        if(cardValue < 26) {
            usTemp = cardValue - 13;
        } else {
            if(cardValue < 39) {
                usTemp = cardValue - 26;
            } else {
                usTemp = cardValue - 39;
            }
        }
    }
    if(usTemp == 12) {
        return 1;
    } else {
        return (usTemp + 2);
    }
}

@end

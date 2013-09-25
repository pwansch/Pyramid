//
//  MainViewController.m
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "CardView.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize gameButton;
@synthesize newId;
@synthesize fGameOver;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize the randomizer
    srandom((int)time(NULL));

    // Create system sounds
    NSString *path = [[NSBundle mainBundle] pathForResource:@"new" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &newId);
    
    // Initialize settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.m_sound = [defaults boolForKey:kSoundKey];
    self.fTurnOverDeck = [defaults boolForKey:kTurnOverDeckKey];
    self.fOne = [defaults boolForKey:kOneKey];
    self.sCardBack = [defaults integerForKey:kCardBackKey];
    MainView *mainView = (MainView *)self.view;
    mainView.lCasinoScore = [defaults integerForKey:kCasinoScoreKey];
    mainView.fTimer = [defaults boolForKey:kTimerKey];
    
    // Create the card arrays
    self.stack = [[NSMutableArray alloc] initWithCapacity:10];
    self.stackDown = [[NSMutableArray alloc] initWithCapacity:10];
    self.down = [[NSMutableArray alloc] initWithCapacity:10];
    self.cards = [[NSMutableArray alloc] initWithCapacity:28];

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
    self.m_sound = [defaults boolForKey:kSoundKey];
    self.fTurnOverDeck = [defaults boolForKey:kTurnOverDeckKey];
    self.fOne = [defaults boolForKey:kOneKey];
    self.sCardBack = [defaults integerForKey:kCardBackKey];
    MainView *mainView = (MainView *)self.view;
    mainView.lCasinoScore = [defaults integerForKey:kCasinoScoreKey];
    mainView.fTimer = [defaults boolForKey:kTimerKey];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
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

- (IBAction)newGame:(id)sender {
    if(!self.fGameOver) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to start a new game?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    } else {
        [self initializeGame];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [self initializeGame];
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
    self.infoButton = nil;
    self.flipsidePopoverController = nil;
    
    // Dispose sounds
    AudioServicesDisposeSystemSoundID(newId);
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
	mainView.ulTime = 0;
    mainView.lScore = -28;

    // Initialize the cards
    [self.stack removeAllObjects];
    [self.stackDown removeAllObjects];
    [self.down removeAllObjects];
    [self.cards removeAllObjects];
    CardView *card;
    short sTemp;
    BOOL fPicked[52];
    for (int i = 0; i < 52; i++) {
        fPicked[i] = NO;
    }
    for (int i = 0; i < 28; i++) {
		do {
			sTemp = abs(random() % 52);
		} while (fPicked[sTemp]);
		fPicked[sTemp] = YES;
        card = [[CardView alloc] initWithFrame:[mainView cardFrame:i] :sTemp :self.sCardBack :NO];
        [self.cards addObject:card];
        [self.view addSubview:card];
    }
    
    for (int i = 0; i < 24; i++) {
		do {
			sTemp = abs(random() % 52);
		} while (fPicked[sTemp]);
		fPicked[sTemp] = YES;
        card = [[CardView alloc] initWithFrame:[mainView stackFrame] :sTemp :self.sCardBack :YES];
        [self.stack addObject:card];
        [self.view addSubview:card];
    }
    
	// Draw the view
	[mainView setNeedsDisplay];
}

- (void)updateScore:(CADisplayLink*)sender
{
    MainView *mainView = (MainView *)self.view;
    if (self.lastTime == 0.0) {
        self.lastTime = sender.timestamp;
    } else if ((sender.timestamp - self.lastTime) >= 1.0) {
        self.lastTime = sender.timestamp;
        if (!self.fGameOver && !mainView.fPaused && mainView.fTimer) {
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
    for (int i = 0; i < [self.cards count]; i++) {
        CardView *card = [self.cards objectAtIndex:i];
        card.frame = [mainView cardFrame:i];
    }
    
    // Change the location of the stack cards
    for (CardView *card in self.stack) {
        card.frame = [mainView stackFrame];
    }
    
    // Change the location of the stack down cards
    for (CardView *card in self.stackDown) {
        card.frame = [mainView stackDownFrame];
    }
    
    // Change the location of the down cards
    for (CardView *card in self.down) {
        card.frame = [mainView downFrame];
    }
}

@end

//
//  AppDelegate.m
//  Pyramid
//
//  Created by Peter Wansch on 9/20/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MainView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	NSString *versionValue = [[NSUserDefaults standardUserDefaults] stringForKey:kVersionKey];
	if (versionValue == nil) {
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"1.1", kVersionKey,
                                     @"YES", kAnimationKey,
									 @"YES", kSoundKey,
                                     @"YES", kTimerKey,
                                     @"-28", kCasinoScoreKey,
                                     @"YES", kTurnOverDeckKey,
                                     @"NO", kOneKey,
                                     @"0", kCardBackKey,
                                     nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    MainView *mainView = (MainView *)self.window.rootViewController.view;
    [defaults setInteger:mainView.lCasinoScore forKey:kCasinoScoreKey];
	[defaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

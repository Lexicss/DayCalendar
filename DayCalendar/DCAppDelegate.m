//
//  DCAppDelegate.m
//  DayCalendar
//
//  Created by admin on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCAppDelegate.h"

#import "DCViewController.h"

// SLEEP_DURATION x SLEEP_TIMES = number of seconds to wait for repeat
#define SLEEP_DURATION 3
#define SLEEP_TIMES 10

@interface DCAppDelegate () {
    BOOL refreshingAllowed_;
}

@end

@implementation DCAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize globalQueue;

#pragma mark - Thread

- (void)enqueWaitingOperation {
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self threadMethod:nil];
    }];
    [API setThreadOperation:blockOperation];
    [[API threadQueue] addOperation:[API threadOperation]];
}

- (void)threadMethod:(id)sender {
    for (NSInteger i = 0; i < SLEEP_TIMES; i++) {
        if ([[API threadOperation] isCancelled ]) {
            [self enqueWaitingOperation];
            return;
        }
        sleep(SLEEP_DURATION);
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.viewController changeMoonInfo:sender];
    }];
    [self enqueWaitingOperation];
}

#pragma mark - App Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.viewController = [[DCViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = [API navigationAPI];
    [self.window makeKeyAndVisible];
    
    self.globalQueue = [[NSOperationQueue alloc] init];
    [self.globalQueue setMaxConcurrentOperationCount:1];
    refreshingAllowed_ = NO;

    [API setThreadQueue:self.globalQueue];
    [self enqueWaitingOperation];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    refreshingAllowed_ = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (refreshingAllowed_ && [[[API navigationAPI] topViewController] isMemberOfClass:[DCViewController class]]) {
        [(DCViewController *)[API navigationAPI].topViewController refreshCalendarData];
        refreshingAllowed_ = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

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
        if ([[[API navigationAPI] topViewController] isMemberOfClass:[DCViewController class]]) {
          [(DCViewController*)[API navigationAPI].topViewController changeMoonInfo:sender];
        }
    }];
    [self enqueWaitingOperation];
}

#pragma mark - App Lifecycle

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Will FinishLaunching with options");
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Did FinishLaunching with options");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [API navigationAPI];
    [self.window makeKeyAndVisible];
    
    self.globalQueue = [[NSOperationQueue alloc] init];
    [self.globalQueue setMaxConcurrentOperationCount:1];
    refreshingAllowed_ = NO;

    [API setThreadQueue:self.globalQueue];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
     NSLog(@"Will Resign Active");
    refreshingAllowed_ = YES;
    [[API threadOperation] cancel];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"app is now running in the background and may be suspended at any time");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"app is moving out of the background and back into the foreground, but that it is not yet active");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Did Become Active");
    [self enqueWaitingOperation];
    
    if (refreshingAllowed_ && [[[API navigationAPI] topViewController] isMemberOfClass:[DCViewController class]]) {
        [(DCViewController *)[API navigationAPI].topViewController refreshCalendarData];
        refreshingAllowed_ = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

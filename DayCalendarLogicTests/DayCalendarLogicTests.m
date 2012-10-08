//
//  DayCalendarLogicTests.m
//  DayCalendarLogicTests
//
//  Created by Aliaksei_Maiorau on 10/8/12.
//
//

#import "DayCalendarLogicTests.h"
#import "DCAppDelegate.h"
#import "DCViewController.h"

@interface DayCalendarLogicTests () {
    DCAppDelegate *appDelegate_;
    UIViewController *viewController_;
}

@end

@implementation DayCalendarLogicTests

- (void)setUp
{
    [super setUp];
    appDelegate_ = [UIApplication sharedApplication].delegate;
    viewController_ = appDelegate_.window.rootViewController;
    
    NSLog(@"appDelegate %@",appDelegate_?@"assigned":@"nil");
    NSLog(@"viewcontroller %@",viewController_?@"assigned":@"nil");
    
    STAssertNotNil(appDelegate_, @"Cannot find app delegate");
    STAssertNotNil(viewController_, @"Cannot find view controller");
    // Set-up code here.
    NSLog(@"SetUp");
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in DayCalendarLogicTests");
    NSLog(@"It`s a unit test");
}

@end

//
//  DCAppDelegate.h
//  DayCalendar
//
//  Created by admin on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@class DCMainViewController;

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DCMainViewController *viewController;
@property (strong, nonatomic) NSOperationQueue *globalQueue;

@end

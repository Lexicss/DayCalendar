//
//  DCAppDelegate.h
//  DayCalendar
//
//  Created by admin on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@class DCViewController;

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DCViewController *viewController;

@property (strong, nonatomic) NSOperationQueue *globalQueue;

@end

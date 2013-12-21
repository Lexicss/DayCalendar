//
//  DCViewController.h
//  DayCalendar
//
//  Created by admin on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPopView.h"
#import <CoreLocation/CoreLocation.h>

@protocol DCViewControllerDelegate

- (void)wikiResponseFinishedWithEvents:(NSArray*)events;

@end

@interface DCMainViewController : UIViewController<DCViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    UIView *scrollView_;
    UIActivityIndicatorView *activity;
    DCPopView *popView_;
    BOOL conncetionErrorOccured_;
    NSString *lastLocation;
    
    CLLocationCoordinate2D customCoordinate_;
    BOOL useCustomCoordinate_;
}

@property(nonatomic, strong) UIView *scrollView;
@property(atomic, strong) NSArray *eventsArray;
@property(atomic, strong) NSArray *birthsArray;
@property(atomic, strong) NSArray *deathsArray;
@property(nonatomic, strong) NSDateComponents *currentComponents;
@property(nonatomic, strong) DCPopView *popView;

- (CLLocationCoordinate2D)defaultCoordinates;
- (void)refreshCalendarData;
- (void)refreshCalendarDataWithCustomCoordinate:(CLLocationCoordinate2D)aCoordinate andRegionName:(NSString*)aRegionName;
- (void)changeMoonInfo:(id)sender;

@end


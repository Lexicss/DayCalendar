//
//  DCGeoPoint.h
//  DayCalendar
//
//  Created by admin on 09.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCGeoPoint : NSObject {
    NSDateComponents *dateTime_;
    CGFloat latitude_;
    CGFloat longitude_;
    NSTimeZone *timeZone_;
}

@property(nonatomic, strong) NSDateComponents *dateTime;
@property(nonatomic, unsafe_unretained) CGFloat latitude;
@property(nonatomic, unsafe_unretained) CGFloat longitude;
@property(nonatomic, strong) NSTimeZone *timeZone;

@end

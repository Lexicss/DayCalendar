//
//  DCDayInfo.h
//  DayCalendar
//
//  Created by admin on 09.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCGeoPoint.h"
#import "DCZodiac.h"
#import "API.h"

@interface DCDayInfo : NSObject

+ (double)sign:(double)value;
+ (double)jFromG:(NSDateComponents *)components;
+ (NSDateComponents *)gFromJ:(double)JD;

+ (NSInteger)julianDayFromComponents:(NSDateComponents *)components;

+ (NSString *)stringFromWeekday:(NSInteger)weekday;
+ (NSString *)stringFromMonth:(NSInteger)month;
+ (NSString *)ruGenetiveStringFromMonth:(NSInteger)month;

+ (UILabel *)calendarLabelWithComponent:(NSInteger)dateComponent
                               withFont:(UIFont *)font
                             withOffset:(NSInteger)offset
                            withWeekDay:(NSInteger)weekday
                        withChangeColor:(BOOL)needChangeColor;

+ (UILabel *)calendarLabelWithStringComponent:(NSString *)dateComponent
                                     withFont:(UIFont *)font
                                   withOffset:(NSInteger)offset
                                  withWeekDay:(NSInteger)weekday
                              withChangeColor:(BOOL)needChangeColor;

+ (UILabel *)astroLabelWithText:(NSString*)text
                       withFont:(UIFont*)font
                  withTextColor:(UIColor *)color
                      withPoint:(CGPoint)point;

+ (RiseSetTimes)calculateSunWithGeoPoint2:(DCGeoPoint*)geoPoint;

+ (CGFloat)calculateSunWithGeoPoint:(DCGeoPoint*)geoPoint forSet:(BOOL)isSet;

+ (CGFloat)calculateMoonPhaseForComponents:(NSDateComponents *)components;

+ (NSString *)minutesFromCGFloat:(CGFloat)hourFloat;

+ (NSInteger)neverRise;
+ (NSInteger)neverSet;
@end

//
//  DCDayInfo.m
//  DayCalendar
//
//  Created by admin on 09.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCDayInfo.h"

#define NORMAL_DAYCOLOR [UIColor blackColor]
#define HOLIDAY_DAYCOLOR [UIColor redColor]
#define SATURDAY_DAYCOLOR [UIColor darkGrayColor]//[UIColor colorWithRed:128.0 / 255 green:0 blue:1.0 alpha:1.0]

#define DAYS_IN_YEAR 365.25
#define MONTHES_IN_YEAR 12
#define MOON_SINODIC_PERIOD 29.530588853;
#define DAYS_IN_YEAR_AVERAGE 365.2425
#define MINUTES_IN_HOUR 60
#define SECONDS_IN_MINUTE 60
#define NOON (int)(HOURS_IN_DAY / 2)
#define START_CALC_YEAR -4800
#define DAYS_IN_MONTH_AVERAGE 30.6001
#define DAYS_B4800_TILL_JD0 32045

#define JD_FOR_1582 2299161.0
#define JD_FOR_400 1867216.25

#define JULIAN_START_MONTH 3
#define MINUTES_IN_DAY HOURS_IN_DAY * MINUTES_IN_HOUR
#define SECONDS_IN_DAY MINUTES_IN_DAY * SECONDS_IN_MINUTE

#define MID_MORNING_HOUR 6
#define MID_EVENING_HOUR 18
#define DEGREES_IN_ZONE 15
#define SUN_ANOMALY 0.98560028
#define SUN_ANOMALY_OFFSET -3.289
#define ZENITH_DEGREES 90.5

#define DOWN_ALL_DAY -1
#define UP_ALL_DAY 25

#define RAD(X) X * M_PI / 180.0

#define JULIAN_DAY2000 2451545

// - (void)logStrings:(id)firstObject, ...;

@interface DCDayInfo()
+ (NSInteger)julianDayFromComponents:(NSDateComponents *)components;
@end

@implementation DCDayInfo

+ (double)sign:(double)value {
    if (value > 0) {
        return 1.0;
    } else if (value < 0) {
        return -1.0;
    } else return 0;
}

+ (double)julianFromGregorian:(NSDateComponents *)components {
    double gregYear = (double)[components year];
    double gregMonth = (double)[components month];
    double gregDay = (double)[components day];
    double UT = (double)[components hour] + (double)[components minute] / 60 + (double)[components second] / 3600;

    double JD = 367.0*gregYear - floor((((7.0*(gregYear+(gregMonth + 9.0)/12.0)))/4.0)) +
    floor((275.0*gregMonth)/9.0) + gregDay + 1721013.5 + UT/24.0 - 0.5*[self sign:(100.0*gregYear + gregMonth - 190002.5)] + 0.5;
    JD++;
    
    return JD;
}

+ (NSDateComponents *)gregorianFromJulian:(double)JD {
    double J = JD + 0.5;
    double j = J + 32044;
    int g = j / 146097;
    int dg = (int)j % 146097;
    int c = (dg / 36524 + 1)*3 / 4;
    int dc = dg - c * 36524;
    int b = dc / 1461;
    int db = dc % 1461;
    int a = (db / 365 + 1)*3 / 4;
    int da = db - a * 365;
    int y = g * 400 + c*100 + b * 4 + a;
    int m = (da * 5 + 308) / 153 - 2;
    int d = da - (m+4)*153 / 5 + 122;
    int Y = y - 4800 + (m + 2) / 12;
    int M = (m+2) % 12 + 1;
    int D = d + 1;
    
    double T = JD + 0.5 - floor(JD + 0.5);
    
    double hour = T * 24;
    double minute = (hour - floor(hour))*60;
    double second = (minute - floor(minute))*60;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:Y];
    [components setMonth:M];
    [components setDay:D];
    [components setHour:(NSInteger)hour];
    [components setMinute:(NSInteger)minute];
    [components setSecond:(NSInteger)second];
    return components;
}

+ (NSInteger)julianDayFromComponents:(NSDateComponents *)components {
    int specialYear, specialMonth, K1, K2, K3, julianDay;
    
    specialYear = [components year] - floor((MONTHES_IN_YEAR - [components month]) / 10);
    specialMonth = [components month] + 9;
    if (specialMonth >= MONTHES_IN_YEAR) {
        specialMonth -= MONTHES_IN_YEAR;
    }
    
    K1 = floor(DAYS_IN_YEAR*(specialYear + 4712));
    K2 = floor(30.6 * specialMonth + 0.5);
    K3 = floor(floor((specialYear / 100) + 49) * 0.75) - 38;
    
    julianDay = K1 + K2 + [components day] + 59;
    if (julianDay > 2299160) {
        julianDay -= K3;
    }
    return julianDay;
}

+ (double)encodeJDfromComponents:(NSDateComponents *)components {
    double minutesPerDay = (double)MINUTES_IN_DAY;
    double time = (([components hour] - (double)NOON )/ (double)HOURS_IN_DAY) + ([components minute] / minutesPerDay);

    int prevYear = (MONTHES_IN_YEAR - [components month] + JULIAN_START_MONTH - 1) / MONTHES_IN_YEAR;
    
    int totalYears = [components year] - START_CALC_YEAR - prevYear;
    int julianMonthNumber = [components month] + MONTHES_IN_YEAR * prevYear - JULIAN_START_MONTH;
    
    int jdn = [components day] + (153*julianMonthNumber + 2) / 5 + (int)DAYS_IN_YEAR * totalYears + [self lipYearsCountTillYear:totalYears] - DAYS_B4800_TILL_JD0;
    
    return jdn + time;
}

+ (int)lipYearsCountTillYear:(int)year {
    return year / 4 - year / 100 + year / 400;
}

+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1:
            return NSLocalizedString(@"Sunday", nil);
        case 2:
            return NSLocalizedString(@"Monday", nil);
        case 3:
            return NSLocalizedString(@"Tuesday", nil);
        case 4:
            return NSLocalizedString(@"Wednesday", nil);
        case 5:
            return NSLocalizedString(@"Thursday", nil);
        case 6:
            return NSLocalizedString(@"Friday", nil);
        case 7:
            return NSLocalizedString(@"Saturday", nil);
            
        default:
            return @"???";
    }
}

+ (NSString *)stringFromMonth:(NSInteger)month {
    switch (month) {
        case 1:
            return NSLocalizedString(@"January", nil);
        case 2:
            return NSLocalizedString(@"February", nil);
        case 3:
            return NSLocalizedString(@"March", nil);
        case 4:
            return NSLocalizedString(@"April", nil);
        case 5:
            return NSLocalizedString(@"May", nil);
        case 6:
            return NSLocalizedString(@"June", nil);
        case 7: 
            return NSLocalizedString(@"July", nil);
        case 8:
            return NSLocalizedString(@"August", nil);
        case 9:
            return NSLocalizedString(@"September", nil);
        case 10:
            return NSLocalizedString(@"October", nil);
        case 11:
            return NSLocalizedString(@"November", nil);
        case 12:
            return NSLocalizedString(@"December", nil);
            
        default:
            return @"???";
    }
}

+ (NSString *)ruGenetiveStringFromMonth:(NSInteger)month {
    switch (month) {
        case 1:
            return @"января";
        case 2:
            return @"февраля";
        case 3:
            return @"марта";
        case 4:
            return @"апреля";
        case 5:
            return @"мая";
        case 6:
            return @"июня";
        case 7:
            return @"июля";
        case 8:
            return @"августа";
        case 9:
            return @"сентября";
        case 10:
            return @"октября";
        case 11:
            return @"ноября";
        case 12:
            return @"декабря";
            
        default:
            return @"???";
    }
}

#pragma mark - Inner methods
+ (UILabel *)calendarLabelWithComponent:(NSInteger)dateComponent
                               withFont:(UIFont *)font
                             withOffset:(NSInteger)offset
                            withWeekDay:(NSInteger)weekday
                        withChangeColor:(BOOL)needChangeColor {
    UIColor *holidayDependsColor;
    CGRect screenBounds_ = [[UIScreen mainScreen] bounds];
    NSString *dateString = [NSString stringWithFormat:@"%i",dateComponent];
    CGSize dateSize = [dateString sizeWithFont:font];
    CGRect dateRect = CGRectMake((screenBounds_.size.width - dateSize.width) / 2, offset, dateSize.width, dateSize.height);
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateRect];
    [dateLabel setFont:font];
    [dateLabel setText:dateString];
    
    if (needChangeColor && (weekday == 1)) {  // is Sunday 
        holidayDependsColor = HOLIDAY_DAYCOLOR;
    } else if (needChangeColor && (weekday == 7)) { // is Saturday
        holidayDependsColor = SATURDAY_DAYCOLOR;
    } else {
        holidayDependsColor = NORMAL_DAYCOLOR;
    }
    
    [dateLabel setTextColor:holidayDependsColor];
    return dateLabel;
}

+ (UILabel *)calendarLabelWithStringComponent:(NSString *)dateComponent
                                     withFont:(UIFont *)font
                                   withOffset:(NSInteger)offset
                                  withWeekDay:(NSInteger)weekday
                              withChangeColor:(BOOL)needChangeColor {
    UIColor *holidayDependsColor;
    CGRect screenBounds_ = [[UIScreen mainScreen] bounds];
    NSString *dateString = dateComponent;
    CGSize dateSize = [dateString sizeWithFont:font];
    CGRect dateRect = CGRectMake((screenBounds_.size.width - dateSize.width) / 2, offset, dateSize.width, dateSize.height);
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateRect];
    [dateLabel setFont:font];
    [dateLabel setText:dateString];
    
    if (needChangeColor && (weekday == 1)) {  // is Sunday 
        holidayDependsColor = HOLIDAY_DAYCOLOR;
    } else if (needChangeColor && (weekday == 7)) { // is Saturday
        holidayDependsColor = SATURDAY_DAYCOLOR;
    }  else {
        holidayDependsColor = NORMAL_DAYCOLOR;
    }
    
    [dateLabel setTextColor:holidayDependsColor];
    return dateLabel;
}

+ (UILabel *)astroLabelWithText:(NSString *)text
                       withFont:(UIFont *)font
                  withTextColor:(UIColor *)color
                      withPoint:(CGPoint)point {
    CGSize labelSize = [text sizeWithFont:font];
    UILabel *astroLabel = [[UILabel alloc] initWithFrame:CGRectMake(point.x, point.y, labelSize.width, labelSize.height)];
    [astroLabel setFont:font];
    [astroLabel setText:text];
    [astroLabel setTextColor:color];
    [astroLabel setBackgroundColor:[UIColor clearColor]];
    return astroLabel;
}

+ (RiseSetTimes)calculateSunWithGeoPoint2:(DCGeoPoint *)geoPoint{

    double julianDate = [self julianFromGregorian:[geoPoint dateTime]];
    double julianDaysFloat = julianDate - JULIAN_DAY2000 - 0.0009 + ([geoPoint longitude] / 360);
    NSInteger julianDaysInt = round(julianDaysFloat);
    
    double j_ = JULIAN_DAY2000 + 0.0009 - ([geoPoint longitude] / 360) + julianDaysInt;
    
    double M = 0;
    double lambda = 0;
    NSInteger iteration = 0;
    
    do {
        M = (357.5291 + 0.98560028 * (j_ - JULIAN_DAY2000));
        double Mdev = M - floor(M);
        NSInteger temp = (NSInteger)trunc(M) % 360;
        M = temp + Mdev;

        double c = 1.9148*sin(RAD(M)) + 0.0200 * sin(2*RAD(M)) + 0.0003 * sin(2*RAD(M));
        lambda = M + 102.9372 + c + 180;
        double lambdadev = lambda - floor(lambda);
        temp = (NSInteger)trunc(lambda) % 360;
        lambda = temp + lambdadev;

        double jTransit = j_ + 0.0053*sin(RAD(M)) - 0.0069*sin(2*RAD(lambda));
        j_ = jTransit;
        iteration++;
    
    } while (iteration < 1);
    
    //now jTransit is solar noon;
    double declination = asin(sin(RAD(lambda))*sin(RAD(23.34)));
    double cosH = (  sin(RAD(-0.83)) - sin(RAD([geoPoint latitude])) * sin(declination) ) /
    ( cos(RAD([geoPoint latitude])) * cos(declination) );
    RiseSetTimes times;
    
    if (cosH < -1) {
        times.rise = UP_ALL_DAY;
        times.set = UP_ALL_DAY;
        return times;
    } else if (cosH > 1) {
        times.rise = DOWN_ALL_DAY;
        times.set = DOWN_ALL_DAY;
        return times;
    }
    
    double h = acos( cosH );
    h = h * 180 / M_PI;
    double j__ = JULIAN_DAY2000 + 0.0009 + (h - [geoPoint longitude]) / 360 + julianDaysInt;
    //ok
    
    double jSet = j__ + 0.0053 * sin(RAD(M)) - 0.0069*sin(RAD(2*lambda));
    //ok
    double jRise = j_ - (jSet - j_);
    
    NSDateComponents *riseComponents = [DCDayInfo gregorianFromJulian:jRise];
    NSDateComponents *setComponents = [DCDayInfo gregorianFromJulian:jSet];
    double riseMinute, setMinute;
    
    if ([riseComponents second] > 29) {
        riseMinute = [riseComponents minute] + 1;
    } else {
        riseMinute = [riseComponents minute];
    }
    
    if ([setComponents second] > 29) {
        setMinute = [setComponents minute] + 1;
    } else {
        setMinute = [setComponents minute];
    }
    
    times.rise =[riseComponents hour] + riseMinute / 60 + [geoPoint.timeZone secondsFromGMT] / SECONDS_IN_HOUR;
    times.set = [setComponents hour] + setMinute / 60 + [geoPoint.timeZone secondsFromGMT] / SECONDS_IN_HOUR;
    
    if (times.rise >= HOURS_IN_DAY)
        times.rise -= HOURS_IN_DAY;
    
    if (times.set >= HOURS_IN_DAY)
        times.set -= HOURS_IN_DAY;
    
    return times;
}

+ (CGFloat)calculateSunWithGeoPoint:(DCGeoPoint *)geoPoint forSet:(BOOL)isSet{
    NSDateComponents *dc = [geoPoint dateTime];
    NSDate *date = [[NSCalendar currentCalendar]
                          dateFromComponents:dc];
    NSUInteger dayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit
                                                                   inUnit:NSYearCalendarUnit
                                                                  forDate:date];
    double startHour;
    
    if (isSet) {
        startHour = MID_EVENING_HOUR;
    } else {
        startHour = MID_MORNING_HOUR;
    }
    
    double lngHour = [geoPoint longitude] / DEGREES_IN_ZONE;
    double t = dayOfYear + (startHour - lngHour) / HOURS_IN_DAY;
    double M = (SUN_ANOMALY * t) + SUN_ANOMALY_OFFSET; 

    double L = M + (1.916 * sin(M * M_PI / 180.0)) + (0.020 * sin(2 * M * M_PI / 180.0)) + 282.634;
    
    if (L > 360.0) {
        L -= 360.0; 
    }
    
    double RA = atan(0.91764 * tan(L * M_PI / 180.0)) * 180.0 / M_PI;
    double Lquadrant = floor(L / 90.0) * 90.0;
    double Rquadrant = floor(RA / 90.0) * 90.0;
    
    RA += (Lquadrant - Rquadrant);
    RA /= DEGREES_IN_ZONE;
    
    double sinDec = 0.39782 * sin(L * M_PI / 180.0);
    double cosDec = cos(asin(sinDec));
    
    double cosH = cos(ZENITH_DEGREES * M_PI / 180.0) - (sinDec * sin([geoPoint latitude] * M_PI / 180.0)) /
    (cosDec * cos([geoPoint latitude]* M_PI / 180));
    
    if (isSet) {
        if (cosH < -1)
            return UP_ALL_DAY;
    } else {
        if (cosH > 1)
            return DOWN_ALL_DAY;
    }
    
    double H;
    
    if (isSet) {
        H = acos(cosH) * 180 / M_PI;
    } else {
        H = 360 - acos(cosH) * 180 / M_PI;
    }

    H /= DEGREES_IN_ZONE;
    double T = H + RA - (0.06571*t) - 6.622;
    double UT = T - lngHour;
    double localT = UT + [geoPoint.timeZone secondsFromGMT] / SECONDS_IN_HOUR;
    
    if (localT < 0) {
        localT = 24 + localT;
    } else if (localT > 24) {
        localT = localT - 24;
    }
    return localT;
}

+ (CGFloat)calculateMoonPhaseForComponents:(NSDateComponents *)components {
    double AG;
    //int julianDay;
    double IP, julianDay0;

    //julianDay = [self julianDayFromComponents:components];
    julianDay0 = [self encodeJDfromComponents:components];
    IP = (julianDay0 - 2451550) / MOON_SINODIC_PERIOD;
    IP -= floor(IP);
    
    AG = IP * MOON_SINODIC_PERIOD;
    return AG;
}

+ (NSString *)minutesFromCGFloat:(CGFloat)hourFloat {
    NSUInteger hourInt = floor(hourFloat);
    CGFloat minutesFloat = hourFloat - hourInt;
    minutesFloat *= 60;
    
    if (minutesFloat < 10) {
        return [NSString stringWithFormat:@"0%d",(NSUInteger)minutesFloat];
    } else {
        return [NSString stringWithFormat:@"%d",(NSUInteger)minutesFloat];
    }
}

+ (NSInteger)neverRise {
    return DOWN_ALL_DAY;
}

+ (NSInteger)neverSet {
    return UP_ALL_DAY;
}

@end

//
//  DCMoonPhase.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/22/12.
//
//

#import "DCMoonPhase.h"
#import "DCDayInfo.h"

#define MAX_ITERATIONS 10

// Moon phase`s names
#define NEW_PHASE 0.959642
#define WAXINGCRESCENT_PHASE 6.422908
#define FIRSTQUATER_PHASE 8.342382
#define WAXINGFGIBBOUS_PHASE 13.805548
#define FULL_PHASE 15.725042
#define WANINGGIBBOUS_PHASE 21.188198
#define LASTQUATER_PHASE 23.107692
#define WANINGCRESCENT_PHASE 28.570848

@implementation DCMoonPhase
@synthesize period = period_;
@synthesize name = name_;
@synthesize index = index_;

- (id)initWithPeriod:(CGFloat)aperiod {
    self = [super init];
    if (self) {
        period_ = aperiod;
        if (period_ < NEW_PHASE) {
            name_ = NSLocalizedString(@"New Moon", nil);
            index_ = 0;
        } else if (period_ < WAXINGCRESCENT_PHASE) {
            name_ = NSLocalizedString(@"Waxing Crescent", nil);
            index_ = 1;
        } else if (period_ < FIRSTQUATER_PHASE) {
            name_ = NSLocalizedString(@"First Quater", nil);
            index_ = 2;
        } else if (period_ < WAXINGFGIBBOUS_PHASE) {
            name_ = NSLocalizedString(@"Waxing Gibbous", nil);
            index_ = 3;
        } else if (period_ < FULL_PHASE) {
            name_ = NSLocalizedString(@"Full Moon", nil);
            index_ = 4;
        } else if (period_ < WANINGGIBBOUS_PHASE) {
            name_ = NSLocalizedString(@"Waning Gibbous", nil);
            index_ = 5;
        } else if (period_ < LASTQUATER_PHASE) {
            name_ = NSLocalizedString(@"Last Quater", nil);
            index_ = 6;
        } else if (period_ < WANINGCRESCENT_PHASE) {
            name_ = NSLocalizedString(@"Waning Crescent", nil);
            index_ = 7;
        } else {
            name_ = NSLocalizedString(@"New Moon", nil);;
            index_ = 0;
        }
    }
    return self;
}

+ (NSDateComponents*)componentsForNextPhaseOf:(DCMoonPhase*)moonPhase fromComponents:(NSDateComponents*)fromComponents {
    DCMoonPhase *nextMoonPhase;
    NSInteger iterations = 0;
    NSDateComponents *nextComponents = [[NSDateComponents alloc] init];
    [nextComponents setYear:fromComponents.year];
    [nextComponents setMonth:fromComponents.month];
    [nextComponents setDay:fromComponents.day];
    [nextComponents setHour:0];
    [nextComponents setMinute:0];
    [nextComponents setSecond:0];

    do {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *nextDate = [gregorianCalendar dateFromComponents:nextComponents];
        nextDate = [nextDate dateByAddingTimeInterval:SECONDS_IN_DAY];

        nextComponents = [gregorianCalendar components:(NSYearCalendarUnit |
                                                        NSMonthCalendarUnit |
                                                        NSDayCalendarUnit |
                                                        NSWeekdayCalendarUnit |
                                                        NSHourCalendarUnit |
                                                        NSMinuteCalendarUnit |
                                                        NSSecondCalendarUnit) fromDate:nextDate];
        CGFloat nextPeriod = [DCDayInfo calculateMoonPhaseForComponents:nextComponents];
        nextMoonPhase = [[DCMoonPhase alloc] initWithPeriod:nextPeriod];
        iterations++;
    } while (nextMoonPhase.index == [moonPhase index] && iterations <= MAX_ITERATIONS);
    
    return nextComponents;
}

@end

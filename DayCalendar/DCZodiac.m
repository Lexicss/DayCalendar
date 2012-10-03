//
//  DCZodiac.m
//  DayCalendar
//
//  Created by admin on 18.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCZodiac.h"

static uint kZodiacCount = 13;

@implementation DCZodiac
@synthesize sign = sign_;
@synthesize name = name_;
@synthesize index = index_;


- (id)initWithIndex:(NSUInteger)aIndex {
    if (aIndex > kZodiacCount - 1)
        return nil;
    self = [super init];
    if (self) {
        index_ = aIndex;
        switch (index_) {
            case 0: {
                sign_ = @"♈";
                name_ = NSLocalizedString(@"Aries", nil);
            }
                break;
            case 1: {
                sign_ = @"♉";
                name_ = NSLocalizedString(@"Taurus", nil);
            }
                break;
            case 2: {
                sign_ = @"♊";
                name_ = NSLocalizedString(@"Gemini", nil);
            }
                break;
            case 3: {
                sign_ = @"♋";
                name_ = NSLocalizedString(@"Cancer", nil);
            }
                break;
            case 4: {
                sign_ = @"♌";
                name_ = NSLocalizedString(@"Leo", nil);
            }
                break;
            case 5: {
                sign_ = @"♍";
                name_ = NSLocalizedString(@"Virgo", nil);
            }
                break;
            case 6: {
                sign_ = @"♎";
                name_ = NSLocalizedString(@"Libra", nil);
            }
                break;
            case 7: {
                sign_ = @"♏";
                name_ = NSLocalizedString(@"Scorpio", nil);
            }
                break;
            case 8: {
                sign_ = @"♐";
                name_ = NSLocalizedString(@"Sagittarius", nil);
            }
                break;
            case 9: {
                sign_ = @"♑";
                name_ = NSLocalizedString(@"Capricorn", nil);
            }
                break;
            case 10: {
                sign_ = @"♒";
                name_ = NSLocalizedString(@"Aquarius", nil);
            }
                break;
            case 11: {
                sign_ = @"♓";
                name_ = NSLocalizedString(@"Pisces", nil);
            }
                break;
                
            case 12: {
                sign_ = @"U";
                name_ = NSLocalizedString(@"Ophiuchus", nil);
            }
                break;
                
            default: {
                sign_ = @"?";
                name_ = @"";
            }
                break;
        }
    }
    
    return self;
}

+ (DCZodiac*)westernZodicacFromDateComponents:(NSDateComponents *)dateComponents {
    NSUInteger index;
    NSUInteger month = [dateComponents month];
    NSUInteger day = [dateComponents day];
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 20) ) {
        index = 0;
    } else if ((month == 4 && day >=21) || (month == 5 && day <= 20)) {
        index = 1;
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) {
        index = 2;
    } else if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) {
        index = 3;
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 23)) {
        index = 4;
    } else if ((month == 8 && day >= 24) || (month == 9 && day <= 22)) {
        index = 5;
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) {
        index = 6;
    } else if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) {
        index = 7;
    } else if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) {
        index = 8;
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 20)) {
        index = 9;
    } else if ((month == 1 && day >= 21) || (month == 2 && day <= 19)) {
        index = 10;
    } else {
        index = 11;
    }
    DCZodiac *zodiac = [[DCZodiac alloc] initWithIndex:index];
    return zodiac;
}

+ (DCZodiac*)sunZodiacFromDateComponents:(NSDateComponents *)dateComponents {
    NSUInteger index;
    NSUInteger month = [dateComponents month];
    NSUInteger day = [dateComponents day];
    
    if ((month == 4 && day >= 19) || (month == 5 && day <= 13) ) {
        index = 0;
    } else if ((month == 5 && day >= 14) || (month == 6 && day <= 19)) {
        index = 1;
    } else if ((month == 6 && day >= 20) || (month == 7 && day <= 20)) {
        index = 2;
    } else if ((month == 7 && day >= 21) || (month == 8 && day <= 9)) {
        index = 3;
    } else if ((month == 8 && day >= 10) || (month == 9 && day <= 15)) {
        index = 4;
    } else if ((month == 9 && day >= 16) || (month == 10 && day <= 30)) {
        index = 5;
    } else if ((month == 10 && day >= 31) || (month == 11 && day <= 22)) {
        index = 6;
    } else if ((month == 11 && day >= 23) || (month == 11 && day <= 29)) {
        index = 7;
    } else if ((month == 11 && day >= 30) || (month == 12 && day <= 17)) {
        index = 12;
    } else if ((month == 12 && day >= 18) || (month == 1 && day <= 17)) {
        index = 8;
    } else if ((month == 1 && day >= 18) || (month == 2 && day <= 15)) {
        index = 9;
    } else if ((month == 2 && day >= 16) || (month == 3 && day <= 11)) {
        index = 10;
    }
    else {
        index = 11;
    }
    DCZodiac *zodiac = [[DCZodiac alloc] initWithIndex:index];
    return zodiac;
}

@end

//
//  DCViewController.m
//  DayCalendar
//
//  Created by admin on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCViewController.h"
#import "DCDayInfo.h"
#import "DCGeoPoint.h"
#import "DCParseDelegate.h"
#import "DCZodiac.h"
#import "API.h"
#import "DCMoonPhase.h"
#import "DCMoon.h"
#import "TODOMacros.h"

//OFFSETS & FONTS

#define NORMAL_DAYCOLOR [UIColor blackColor]
#define HOLIDAY_DAYCOLOR [UIColor redColor]

#define DAY_OFFSET 53
#define DAY_FONT [UIFont fontWithName:@"Optima-ExtraBlack" size:90]
#define DAY_FONT_OLD [UIFont fontWithName:@"Futura-CondensedExtraBold" size:90];

#define YEAR_OFFSET 8
#define YEAR_FONT [UIFont fontWithName:@"Baskerville-SemiBoldItalic" size:18]
#define YEAR_FONT_OLD [UIFont fontWithName:@"AmericanTypewriter" size:18];

#define MONTH_OFFSET 30
#define MONTH_FONT [UIFont fontWithName:@"Cochin-Bold" size:23]

#define WEEKDAY_OFFSET 150
#define WEEKDAY_FONT [UIFont fontWithName:@"CourierNewPS-BoldMT" size:25]

#define ASTROSUN_FONT_SIGN [UIFont fontWithName:@"MarkerFelt-Thin" size:12]
#define ASTROSUN_FONT_INFO [UIFont fontWithName:@"MarkerFelt-Wide" size:12]
#define ASTROZODIAC_FONT_SYMBOL [UIFont fontWithName:@"Helvetica" size:20]

#define EVENTS_OFFSET 190
#define EVENTS_FONT_INFO [UIFont fontWithName:@"Baskerville" size:14]
#define CELL_HEIGHT 60

#define ASTROSUNR_SIGN_POINT (CGPoint){10,90}
#define ASTROSUNR_INFO_POINT (CGPoint){60,90}
#define ASTROSUNS_SIGN_POINT (CGPoint){10,105}
#define ASTROSUNS_INFO_POINT (CGPoint){60,105}
#define ASTROSUND_SIGN_POINT (CGPoint){10,120}
#define ASTROSUND_INFO_POINT (CGPoint){60,120}
#define SUN_ICON_POINT (CGPoint){10, 50}
#define LINE_CENTER (CGPoint){50, 140}
#define ASTROZODIAC_SYMBOL_POINT (CGPoint){5,5}

#define LINE_WIDTH 80
#define LOCATION_POINT (CGPoint){10,142}

#define RISE_BLACKLAYER 1.8
#define SET_BLACKLAYER 2.5
#define DURATION_BLACKLAYER 1.3

#define MOON_ICON_FRAME CGRectMake(20, 50, 32, 31)
#define NEXT_MOON_OFFSET_X 2
#define MOON_SIGN_OFFSET_X 90
#define MOON_INFO_OFFSET_X 50

#define EVENT_YPOINT 180

#define DEFAULT_CELL_HEIGHT 44
#define NARROW_CELL_HEIGHT 25

//#define MYDEBUG 100

@interface DCViewController () {
    UILabel *nextMoonPhaseLabel;
    UILabel *moonRiseSignLabel;
    UILabel *moonRiseInfoLabel;
    UILabel *moonSetSignLabel;
    UILabel *moonSetInfoLabel;
}

- (UIColor*)colorForWeekDayNumber:(NSUInteger)weekday withBlackLayer:(CGFloat)divider;
- (NSDateComponents*)putDayInfo;
- (void)putDayEventsForDateComponents:(NSDateComponents*)dateComponents;
- (BOOL)componentsChanged;
- (CLLocationCoordinate2D)defaultCoordinates;
- (BOOL)locationChanged;
- (void)handleMoonTouch:(id)sender;
- (NSArray*)myPreferenceSpecifiers;
@end

@implementation DCViewController
@synthesize scrollView = scrollView_;
@synthesize eventsArray = eventsArray_;
@synthesize currentComponents = currentComponents_;
@synthesize popView = popView_;
@synthesize birthsArray;
@synthesize deathsArray;

#pragma mark - Show UI

- (UIColor*)colorForWeekDayNumber:(NSUInteger)weekday withBlackLayer :(CGFloat)divider {
    CGFloat div = divider * 255;
    switch (weekday) {
        case 1: return [UIColor colorWithRed:255.0 / div green:0 blue:0 alpha:1.0];
        case 2: return [UIColor colorWithRed:255.0 / div green:255.0 / div blue:0 alpha:1.0];
        case 3: return [UIColor colorWithRed:255.0 / div green:203.0 / div blue:219.0 / div alpha:1.0];
        case 4: return [UIColor colorWithRed:0 green:255.0 / div blue:0 alpha:1.0];
        case 5: return [UIColor colorWithRed:255.0 / div green:128.0 / div blue:0 alpha:1.0];
        case 6: return [UIColor colorWithRed:0 green:0 blue:255.0 / div alpha:1.0];
        case 7: return [UIColor colorWithRed:128.0 / div green:0 blue:255.0 / div alpha:1.0];
            
        default: return [UIColor blackColor];
    }
}


- (NSDateComponents*)putDayInfo {
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    NSDate *currentDate = [NSDate date];
#ifdef MYDEBUG
    currentDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * MYDEBUG];
#endif
    

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit |
                                                             NSMonthCalendarUnit |
                                                             NSDayCalendarUnit |
                                                             NSWeekdayCalendarUnit |
                                                             NSHourCalendarUnit |
                                                             NSMinuteCalendarUnit |
                                                             NSSecondCalendarUnit) fromDate:currentDate];

    UIFont *dayFont, *yearFont;
    if ([API iosVersion] < __IPHONE_5_0) {  // ios 4.3 or earlier
        dayFont = DAY_FONT_OLD
        yearFont = YEAR_FONT_OLD;
    } else {
        dayFont = DAY_FONT;
        yearFont = YEAR_FONT;
    }

    // Basic items
    UILabel *dayLabel = [DCDayInfo calendarLabelWithComponent:[dateComponents day]
                                                     withFont:dayFont
                                                   withOffset:DAY_OFFSET
                                                  withWeekDay:[dateComponents weekday]
                                              withChangeColor:YES];
    [self.scrollView addSubview:dayLabel];
    
    UILabel *yearLabel = [DCDayInfo calendarLabelWithComponent:[dateComponents year]
                                                      withFont:yearFont
                                                    withOffset:YEAR_OFFSET
                                                   withWeekDay:[dateComponents weekday]
                                               withChangeColor:NO];
    [self.scrollView addSubview:yearLabel];
    
    UILabel *monthLabel = [DCDayInfo calendarLabelWithStringComponent:[DCDayInfo stringFromMonth:[dateComponents month]]
                                                             withFont:MONTH_FONT
                                                           withOffset:MONTH_OFFSET
                                                          withWeekDay:[dateComponents weekday]
                                                      withChangeColor:NO];
    [self.scrollView addSubview:monthLabel];
    
    UILabel *weekdayLabel = [DCDayInfo calendarLabelWithStringComponent:[DCDayInfo stringFromWeekday:[dateComponents weekday]]
                                                               withFont:WEEKDAY_FONT
                                                             withOffset:WEEKDAY_OFFSET
                                                            withWeekDay:[dateComponents weekday]
                                                        withChangeColor:YES];
    [self.scrollView addSubview:weekdayLabel];
    
    //A S T R O N O M I C  C A L C U L A T I O N S
    //The Sun
    CLLocationCoordinate2D currentLocation;
//    if (useCustomCoordinate_) {
//        currentLocation = customCoordinate_;
//    } else {
//        currentLocation = [self defaultCoordinates];//{54.9, 27.33};
//    }
    currentLocation = [self defaultCoordinates];
    
    DCGeoPoint *geoPoint = [[DCGeoPoint alloc] init];
    [geoPoint setDateTime:dateComponents];
    [geoPoint setLatitude:currentLocation.latitude];
    [geoPoint setLongitude:currentLocation.longitude];
    [geoPoint setTimeZone:[NSTimeZone localTimeZone]];
    
    RiseSetTimes sunTimes = [DCDayInfo calculateSunWithGeoPoint2:geoPoint];
    RiseSetTimes moonTimes = [DCMoon calculateMoonWithGeoPoint:geoPoint];
    
    NSUInteger polarDayOrNight = 0;
    if (sunTimes.rise == [DCDayInfo neverSet]) {
        polarDayOrNight = 1; // polar day
    } else if (sunTimes.rise == [DCDayInfo neverRise]) {
        polarDayOrNight = 2; // polar night
    };
    
    NSUInteger riseHour, setHour, durationHour;
    CGFloat durationTime;
    if (!polarDayOrNight) {
        riseHour = floor(sunTimes.rise);
        setHour = floor(sunTimes.set);
        
        if (setHour >= riseHour) {
          durationTime = sunTimes.set - sunTimes.rise;
        } else {
            durationTime = HOURS_IN_DAY - (sunTimes.rise - sunTimes.set);
        }
        durationHour = floor(durationTime);
    }
    NSString *timeInfoRise, *timeInfoSet;
    
    UILabel *sunRiseSign = [DCDayInfo astroLabelWithText:NSLocalizedString(@"Rise:", nil)
                                                withFont:ASTROSUN_FONT_SIGN
                                           withTextColor:[UIColor blackColor]
                                               withPoint:ASTROSUNR_SIGN_POINT];
    [self.scrollView addSubview:sunRiseSign];
    
    switch (polarDayOrNight) {
        case 1:
            timeInfoRise = NSLocalizedString(@"Up", nil);
            timeInfoSet = NSLocalizedString(@"No set", nil);
            break;
            
        case 2:
            timeInfoRise = NSLocalizedString(@"No rise", nil);
            timeInfoSet = NSLocalizedString(@"Down", nil);
            break;
            
        default:
            timeInfoRise = [NSString stringWithFormat:@"%d:%@",riseHour,[DCDayInfo minutesFromCGFloat:sunTimes.rise]];
            timeInfoSet = [NSString stringWithFormat:@"%d:%@", setHour, [DCDayInfo minutesFromCGFloat:sunTimes.set]];
            break;
    }
    
    UILabel *sunRiseInfo = [DCDayInfo astroLabelWithText:timeInfoRise
                                                withFont:ASTROSUN_FONT_INFO
                                           withTextColor:[self colorForWeekDayNumber:[dateComponents weekday] withBlackLayer:RISE_BLACKLAYER]
                                               withPoint:ASTROSUNR_INFO_POINT];
    [self.scrollView addSubview:sunRiseInfo];
    
    UILabel *sunSetSign = [DCDayInfo astroLabelWithText:NSLocalizedString(@"Set:", nil)
                                               withFont:ASTROSUN_FONT_SIGN
                                          withTextColor:[UIColor blackColor]
                                              withPoint:ASTROSUNS_SIGN_POINT];
    [self.scrollView addSubview:sunSetSign];
    
    UILabel *sunSetInfo = [DCDayInfo astroLabelWithText:timeInfoSet
                                               withFont:ASTROSUN_FONT_INFO
                                          withTextColor:[self colorForWeekDayNumber:[dateComponents weekday] withBlackLayer:SET_BLACKLAYER]
                                              withPoint:ASTROSUNS_INFO_POINT];
    [self.scrollView addSubview:sunSetInfo];
    
    UILabel *sunDurationSign = [DCDayInfo astroLabelWithText:NSLocalizedString(@"Duration:", nil)
                                                    withFont:ASTROSUN_FONT_INFO
                                               withTextColor:[UIColor blackColor]
                                                   withPoint:ASTROSUND_SIGN_POINT];
    [self.scrollView addSubview:sunDurationSign];
    
    NSString *timeInfoDur;
    if (polarDayOrNight) {
        timeInfoDur = @"-";
    } else {
        timeInfoDur = [NSString stringWithFormat:@"%d:%@", durationHour, [DCDayInfo minutesFromCGFloat:durationTime]];
    }
    
    UILabel *sunDurationInfo = [DCDayInfo astroLabelWithText:timeInfoDur
                                                    withFont:ASTROSUN_FONT_INFO
                                               withTextColor:[self colorForWeekDayNumber:[dateComponents weekday] withBlackLayer:DURATION_BLACKLAYER]
                                                   withPoint:ASTROSUND_INFO_POINT];
    [self.scrollView addSubview:sunDurationInfo];
    
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizontal-line.png"]];
    CGRect b = [lineView bounds];
    b.size.width = LINE_WIDTH;
    [lineView setBounds:b];
    [lineView setCenter:LINE_CENTER];
    [self.scrollView addSubview:lineView];

    CGSize locationLabelSize = [lastLocation sizeWithFont:ASTROSUN_FONT_INFO];
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(LOCATION_POINT.x, LOCATION_POINT.y, locationLabelSize.width, locationLabelSize.height)];
    [locationLabel setFont:ASTROSUN_FONT_INFO];
    [locationLabel setText:lastLocation];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [self.scrollView addSubview:locationLabel];
    
    
    UIImageView *sunView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"theSun.png"]];
    CGRect sunFrame = [sunView frame];
    sunFrame.origin = SUN_ICON_POINT;
    sunFrame.size = CGSizeMake(sunFrame.size.width / 4, sunFrame.size.height / 4);
    [sunView setFrame:sunFrame];
    [self.scrollView addSubview:sunView];
    
    DCZodiac *ancientZodiac = [DCZodiac westernZodicacFromDateComponents:dateComponents];
    UILabel *zodiacSignLabel = [DCDayInfo astroLabelWithText:[ancientZodiac sign]
                                                    withFont:ASTROZODIAC_FONT_SYMBOL
                                               withTextColor:[UIColor blackColor]
                                                   withPoint:ASTROZODIAC_SYMBOL_POINT];
    [self.scrollView addSubview:zodiacSignLabel];
    UILabel *zodiacTextLabel = [DCDayInfo astroLabelWithText:[ancientZodiac name]
                                                    withFont:ASTROSUN_FONT_SIGN
                                               withTextColor:[UIColor blackColor]
                                                   withPoint:CGPointMake(5, zodiacSignLabel.frame.origin.y +
                                                                         zodiacSignLabel.frame.size.height)];
    [self.scrollView addSubview:zodiacTextLabel];
    
    DCZodiac *realZodiac = [DCZodiac sunZodiacFromDateComponents:dateComponents];
    if (![realZodiac.sign isEqualToString:[ancientZodiac sign]]) {
        UILabel *realZodiacTextLabel = [DCDayInfo astroLabelWithText:
                                        [NSString stringWithFormat:NSLocalizedString(@"(but sun in %@)", nil),[realZodiac name]]
                                                            withFont:ASTROSUN_FONT_SIGN
                                                       withTextColor:[UIColor darkGrayColor]
                                                           withPoint:CGPointMake(zodiacSignLabel.frame.origin.y +
                                                                                 zodiacSignLabel.frame.size.width, 5)];
        if (realZodiacTextLabel.frame.origin.x + realZodiacTextLabel.frame.size.width >= 
            yearLabel.frame.origin.x) {
            CGRect f = [realZodiacTextLabel frame];
            f.size.width = yearLabel.frame.origin.x - realZodiacTextLabel.frame.origin.x - 5;
            f.size.height *= 2;
            [realZodiacTextLabel setFrame:f];
        }
        [realZodiacTextLabel setNumberOfLines:2];
        [self.scrollView addSubview:realZodiacTextLabel];
    }
    
    
    //The Moon
    CGFloat moonDaysLapsed = [DCDayInfo calculateMoonPhaseForComponents:dateComponents];
    DCMoonPhase *moonPhase = [[DCMoonPhase alloc] initWithPeriod:moonDaysLapsed];
    
    
    NSString *fileName = [NSString stringWithFormat:@"amoon_phase_%d.png",moonPhase.index];
    UIImageView *phaseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];

    CGRect reversFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - MOON_ICON_FRAME.origin.x - MOON_ICON_FRAME.size.width, MOON_ICON_FRAME.origin.y, MOON_ICON_FRAME.size.width, MOON_ICON_FRAME.size.height);
    [phaseImageView setFrame:reversFrame];
    CGRect mainFrame = [[UIScreen mainScreen] bounds];
    
    UILabel *moonPhaseLabel = [DCDayInfo astroLabelWithText:[moonPhase name]
                                                   withFont:ASTROSUN_FONT_SIGN
                                              withTextColor:[UIColor blackColor]
                                                  withPoint:CGPointMake(ceilf(reversFrame.origin.x),
                                                                        ceilf(reversFrame.origin.y) + ceilf(phaseImageView.frame.size.height) + 2)];
    CGPoint c = [moonPhaseLabel center];
    [moonPhaseLabel setCenter:CGPointMake(ceilf(reversFrame.origin.x) + ceilf(reversFrame.size.width / 2), c.y)];
    if (mainFrame.size.width < moonPhaseLabel.frame.origin.x + moonPhaseLabel.frame.size.width) {
        CGFloat deltaX = moonPhaseLabel.frame.origin.x + moonPhaseLabel.frame.size.width - mainFrame.size.width + 3;
        CGRect f = [moonPhaseLabel frame];
        f.origin.x -= deltaX;
        [moonPhaseLabel setFrame:f];
    } else {
        CGRect tempRect = [moonPhaseLabel frame];
        tempRect.origin.x = ceilf(moonPhaseLabel.frame.origin.x);
        tempRect.origin.y = ceilf(moonPhaseLabel.frame.origin.y);
        [moonPhaseLabel setFrame:tempRect];
    }
    
    [self.scrollView addSubview:phaseImageView];
    [self.scrollView addSubview:moonPhaseLabel];
     
    NSDateComponents *nextComponents = [DCMoonPhase componentsForNextPhaseOf:moonPhase fromComponents:dateComponents];
    CGFloat nextMoonDaysLapsed = [DCDayInfo calculateMoonPhaseForComponents:nextComponents];
    DCMoonPhase *nextMoonPhase = [[DCMoonPhase alloc] initWithPeriod:nextMoonDaysLapsed];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale;
    if([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ru"]) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    } else {
        locale = [NSLocale currentLocale];
    }

    [formatter setLocale:locale];
    [formatter setDateFormat:@"d MMM"];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *nextDate = [gregorianCalendar dateFromComponents:nextComponents];
    NSString *nextPhaseText = [NSString stringWithFormat:NSLocalizedString(@"%@ will in %@", nil),nextMoonPhase.name, [formatter stringFromDate:nextDate]];
    CGPoint nextPoint = moonPhaseLabel.frame.origin;
    nextPoint.y += moonPhaseLabel.frame.size.height + 4;
    
    nextMoonPhaseLabel = [DCDayInfo astroLabelWithText:nextPhaseText
                                                       withFont:ASTROSUN_FONT_SIGN
                                                  withTextColor:[UIColor darkGrayColor]
                                                      withPoint:nextPoint];
    CGRect tempFrame = [nextMoonPhaseLabel frame];
    tempFrame.origin.x -= NEXT_MOON_OFFSET_X;
    tempFrame.size.height *= 4;
    tempFrame.size.width = moonPhaseLabel.frame.size.width + NEXT_MOON_OFFSET_X;
    [nextMoonPhaseLabel setFrame:tempFrame];
    [nextMoonPhaseLabel setNumberOfLines:4];
    [nextMoonPhaseLabel setUserInteractionEnabled:YES];
    [self.scrollView addSubview:nextMoonPhaseLabel];
    
    // Moon Rise & Set
    riseHour = floor(moonTimes.rise);
    setHour = floor(moonTimes.set);
    
    timeInfoRise = [NSString stringWithFormat:@"%d:%@",riseHour,[DCDayInfo minutesFromCGFloat:moonTimes.rise]];
    CGPoint labelPoint = ASTROSUNS_SIGN_POINT;
    labelPoint.x = [UIScreen mainScreen].bounds.size.width - MOON_SIGN_OFFSET_X;
    moonRiseSignLabel = [DCDayInfo astroLabelWithText:NSLocalizedString(@"Rise:", nil)
                                                 withFont:ASTROSUN_FONT_SIGN
                                            withTextColor:[UIColor blackColor]
                                                withPoint:labelPoint];
    labelPoint = ASTROSUNS_INFO_POINT;
    labelPoint.x = [UIScreen mainScreen].bounds.size.width - MOON_INFO_OFFSET_X;
    moonRiseInfoLabel = [DCDayInfo astroLabelWithText:timeInfoRise
                                                 withFont:ASTROSUN_FONT_INFO
                                            withTextColor:[UIColor lightGrayColor]
                                                withPoint:labelPoint];
    labelPoint = ASTROSUND_SIGN_POINT;
    labelPoint.x = [UIScreen mainScreen].bounds.size.width - MOON_SIGN_OFFSET_X;
    timeInfoSet = [NSString stringWithFormat:@"%d:%@",setHour,[DCDayInfo minutesFromCGFloat:moonTimes.set]];
    moonSetSignLabel = [DCDayInfo astroLabelWithText:NSLocalizedString(@"Set:", nil)
                                                withFont:ASTROSUN_FONT_SIGN
                                           withTextColor:[UIColor blackColor]
                                               withPoint:labelPoint];
    labelPoint = ASTROSUND_INFO_POINT;
    labelPoint.x = [UIScreen mainScreen].bounds.size.width - MOON_INFO_OFFSET_X;
    moonSetInfoLabel = [DCDayInfo astroLabelWithText:timeInfoSet
                                                withFont:ASTROSUN_FONT_INFO
                                           withTextColor:[UIColor grayColor]
                                               withPoint:labelPoint];
    [moonRiseSignLabel setHidden:YES];
    [moonRiseInfoLabel setHidden:YES];
    [moonSetSignLabel setHidden:YES];
    [moonSetInfoLabel setHidden:YES];
    [self.scrollView addSubview:moonRiseSignLabel];
    [self.scrollView addSubview:moonRiseInfoLabel];
    [self.scrollView addSubview:moonSetSignLabel];
    [self.scrollView addSubview:moonSetInfoLabel];

    //phaseImageView
    UIButton *switchButton = [[UIButton alloc] initWithFrame:phaseImageView.frame];
    CGRect buttonFrame = [switchButton frame];
    buttonFrame.origin.x -= buttonFrame.size.width;
    buttonFrame.size.width *= 3;
    buttonFrame.size.height *= 3;
    [switchButton setFrame:buttonFrame];
    [switchButton setBackgroundColor:[UIColor clearColor]];
    [switchButton addTarget:self action:@selector(handleMoonTouch:) forControlEvents:UIControlEventTouchDown];
    [self.scrollView addSubview:switchButton];
    
    return dateComponents;
}

- (void)putDayEventsForDateComponents:(NSDateComponents *)dateComponents {
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width / 2,
                                    [UIScreen mainScreen].bounds.size.height - EVENTS_OFFSET)];
    [activity startAnimating];
    [self.scrollView addSubview:activity];
    
    
    dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_queue, ^(void){
        NSString *whatDay;
        NSURL *wikiURL;
        if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ru"]) {
            whatDay = [NSString stringWithFormat:@"%d_%@",[dateComponents day],
                       [[DCDayInfo ruGenetiveStringFromMonth:[dateComponents month]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        } else {
            whatDay = [NSString stringWithFormat:@"%d_%@",[dateComponents day],
                       [DCDayInfo stringFromMonth:[dateComponents month]]];
        }

        wikiURL = [NSURL URLWithString:[NSString stringWithFormat:NSLocalizedString(@"wikipedia server", nil), whatDay] ];
        
        NSURLRequest *wikiRequest = [NSURLRequest requestWithURL:wikiURL];
        NSHTTPURLResponse *wikiResponse;
        NSError *wikiError;
        NSData *responseData;
        responseData = [NSURLConnection sendSynchronousRequest:wikiRequest
                                             returningResponse:&wikiResponse
                                                         error:&wikiError];
        conncetionErrorOccured_ = (wikiError != nil);
        if (wikiError) {
            __block NSString *errorMessage = [wikiError localizedDescription];
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                UIAlertView *wikiAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error to connect to wikipedia", nil)
                                                                        message:errorMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil, nil];
                [wikiAlertView show];
                [activity stopAnimating];
            });
            return;
        }
        
       // this code needed to debug
        NSString *s = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",s);
        NSString *replacedString = [s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        //NSLog(@"%@",replacedString);
        NSData *replacedResponseData = [replacedString dataUsingEncoding:NSUTF8StringEncoding];

        DCParseDelegate *parseDelegate = [[DCParseDelegate alloc] initWithData:replacedResponseData];
        [parseDelegate setDelegate:self];
        [parseDelegate start];
    });
 }

#pragma mark - DCViewControllerDelegate
     
 - (void) wikiResponseFinishedWithEvents:(NSArray *)events {
     if (!events) {
         if ([NSThread currentThread].isMainThread) {
             [activity stopAnimating];
         }
         return;
     }
     self.eventsArray = [events objectAtIndex:0];
     self.birthsArray = [events objectAtIndex:1];
     self.deathsArray = [events objectAtIndex:2];
     dispatch_sync(dispatch_get_main_queue(), ^(void){
         CGRect mainRect = [[UIScreen mainScreen] bounds];
         UITableView *eventsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, EVENTS_OFFSET, mainRect.size.width, mainRect.size.height - EVENTS_OFFSET - [UIApplication sharedApplication].statusBarFrame.size.height) style:UITableViewStylePlain];
         [eventsTableView setDataSource:self];
         [eventsTableView setDelegate:self];
         [eventsTableView setAllowsSelection:YES];
         
         [self.scrollView addSubview:eventsTableView];
         [activity stopAnimating];
     });
 }
     
     
#pragma mark - TableView

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 3;
 }

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Events", nil);
            break;
        case 1:
            return NSLocalizedString(@"Births", nil);
            break;
        case 2:
            return NSLocalizedString(@"Deaths", nil);
            break;
            
        default:
            return @"";
            break;
    }
}

 - (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
     
     switch (section) {
         case 0:
             return [self.eventsArray count];
             break;
         case 1:
             return [self.birthsArray count];
             break;
         case 2:
             return [self.deathsArray count];
             break;
             
         default:
             break;
     }
     
     return 0;
 }
 - (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *cellIdentifier = @"eventCell";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
         [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
     }
     
     [cell.textLabel setFont:EVENTS_FONT_INFO];
     switch (indexPath.section) {
         case 0:
             [cell.textLabel setNumberOfLines:2];
             [cell.textLabel setText:[self.eventsArray objectAtIndex:indexPath.row]];
             break;
         case 1:
             [cell.textLabel setNumberOfLines:1];
             [cell.textLabel setText:[self.birthsArray objectAtIndex:indexPath.row]];
             break;
         case 2:
             [cell.textLabel setNumberOfLines:1];
             [cell.textLabel setText:[self.deathsArray objectAtIndex:indexPath.row]];
             break;
             
         default:
             break;
     }

     return cell;
 }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.popView) {
        [self.popView animateWithAppearence:NO];
    }
    DCPopView *localPopView;
    switch (indexPath.section) {
        case 0:
            localPopView = [[DCPopView alloc]initWithText:[self.eventsArray objectAtIndex:indexPath.row]];
            break;
        case 1:
            localPopView = [[DCPopView alloc]initWithText:[self.birthsArray objectAtIndex:indexPath.row]];
            break;
        case 2:
            localPopView = [[DCPopView alloc]initWithText:[self.deathsArray objectAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
    
    [self setPopView:localPopView];
    [self.scrollView addSubview:self.popView];
    [self.popView animateWithAppearence:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return DEFAULT_CELL_HEIGHT;
            break;
        case 1:
            return NARROW_CELL_HEIGHT;
            break;
        case 2:
            return NARROW_CELL_HEIGHT;
            break;
        default:
            break;
    }
    return DEFAULT_CELL_HEIGHT;
}


#pragma mark - Internal methods

- (BOOL)componentsChanged {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [calendar components: (NSYearCalendarUnit |
        NSMonthCalendarUnit |
        NSDayCalendarUnit ) fromDate:[NSDate date]];
    return (todayComponents.day != self.currentComponents.day);
}

- (BOOL)locationChanged {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *location = [prefs stringForKey:@"Current"];
    return ![lastLocation isEqualToString:location];
}

- (CLLocationCoordinate2D)defaultCoordinates {
    if (useCustomCoordinate_)
        return customCoordinate_;
    
    CLLocationCoordinate2D zeroLocation = (CLLocationCoordinate2D){0,0};

    NSArray *preferencesArray = [self myPreferenceSpecifiers];
    if (!preferencesArray)
        return zeroLocation;

    // use the shared defaults object
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // for each preference item, set its default if there is no value set
    for (NSDictionary *item in preferencesArray) {
        // get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key) {
            id userDefaultsValue = [userDefaults objectForKey:key];//Minsk,Belarus
            id bundleValue = [item objectForKey:@"DefaultValue"];
            if (bundleValue && !userDefaultsValue) {
                [userDefaults setObject:bundleValue forKey:key];
            }
        }
    }   
    BOOL synchronizeSucceeded = [userDefaults synchronize];
    NSLog(@"synchronizeSucceded %@",synchronizeSucceeded?@"Ok":@"Failed");
    
    NSString *locationName = [userDefaults stringForKey:@"Current"];
    if (!locationName)
        return zeroLocation;
    lastLocation = [NSString stringWithString:locationName];
    
    NSArray *apreferencesArray = [self myPreferenceSpecifiers];
    if (!apreferencesArray)
        return zeroLocation;

    NSDictionary *item1 = [apreferencesArray objectAtIndex:1];
    NSArray *cityArray = [NSArray arrayWithArray:[item1 valueForKey:@"Titles"]];
    NSArray *coordinatesArray = [NSArray arrayWithArray:[item1 valueForKey:@"Points"]];
    NSUInteger index = [cityArray indexOfObject:locationName];
    
    NSDictionary *defaultCoordinates = [coordinatesArray objectAtIndex:index];
    CGFloat lat = [[defaultCoordinates valueForKey:@"latitude"] floatValue];
    CGFloat lon = [[defaultCoordinates valueForKey:@"longitude"] floatValue];

    return (CLLocationCoordinate2D){lat,lon};
}

- (void)handleMoonTouch:(id)sender {
    [[API threadOperation] cancel];
    [self changeMoonInfo:sender];
}

- (NSArray*)myPreferenceSpecifiers {
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
    if (!settingsPath)
        return nil;
    NSString *plistPath =
    [settingsPath stringByAppendingPathComponent:@"Root.plist"];
    if (!plistPath)
        return nil;
    
    // get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary =
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!settingsDictionary)
        return nil;
    NSArray *preferencesArray =
    [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    return preferencesArray;
}

#pragma mark - External methods

- (void)refreshCalendarData {    
    if ([self componentsChanged] || conncetionErrorOccured_ || [self locationChanged]) {
       self.currentComponents = [self putDayInfo];
       [self putDayEventsForDateComponents:self.currentComponents];
    }
}

- (void)refreshCalendarDataWithCustomCoordinate:(CLLocationCoordinate2D)aCoordinate andRegionName:(NSString *)aRegionName{
    lastLocation = @"";
    customCoordinate_ = aCoordinate;
    useCustomCoordinate_ = YES;
    lastLocation = aRegionName;
    [self refreshCalendarData];
}

- (void)changeMoonInfo:(id)sender {
    if (![nextMoonPhaseLabel isHidden]) {
        [UIView animateWithDuration:1 animations:^(void){
            [nextMoonPhaseLabel setAlpha:0];
        }completion:^(BOOL finished) {
            [nextMoonPhaseLabel setHidden:YES];
            [moonRiseSignLabel setAlpha:0];
            [moonRiseInfoLabel setAlpha:0];
            [moonSetSignLabel setAlpha:0];
            [moonSetInfoLabel setAlpha:0];
            
            [moonRiseSignLabel setHidden:NO];
            [moonRiseInfoLabel setHidden:NO];
            [moonSetSignLabel setHidden:NO];
            [moonSetInfoLabel setHidden:NO];
            [UIView animateWithDuration:1 animations:^{
                [moonRiseSignLabel setAlpha:1.0];
                [moonRiseInfoLabel setAlpha:1.0];
                [moonSetSignLabel setAlpha:1.0];
                [moonSetInfoLabel setAlpha:1.0];
            }completion:^(BOOL finished) {
                
            }];
        }];
    } else {
        [UIView animateWithDuration:1 animations:^(void){
            [moonRiseSignLabel setAlpha:0];
            [moonRiseInfoLabel setAlpha:0];
            [moonSetSignLabel setAlpha:0];
            [moonSetInfoLabel setAlpha:0];
        }completion:^(BOOL finished){
            [moonRiseSignLabel setHidden:YES];
            [moonRiseInfoLabel setHidden:YES];
            [moonSetSignLabel setHidden:YES];
            [moonSetInfoLabel setHidden:YES];
            [nextMoonPhaseLabel setAlpha:0];
            
            [nextMoonPhaseLabel setHidden:NO];
            [UIView animateWithDuration:1 animations:^{
                [nextMoonPhaseLabel setAlpha:1.0];
            }];
        }];
    }
}

#pragma mark - Lifecycle

- (void)loadView {
    conncetionErrorOccured_ = NO;
    lastLocation = @"";
    self.scrollView = [[UIView alloc] init];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self setView:self.scrollView];

    [self refreshCalendarData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ||
    (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end

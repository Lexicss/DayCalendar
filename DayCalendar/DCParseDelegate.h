//
//  DCParseDelegate.h
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/14/12.
//
//

#import <Foundation/Foundation.h>
#import "DCViewController.h"

typedef enum {
    kScanStatusNone,
    kScanStatusEvents,
    kScanStatusBirths,
    kScanStatusDearths
} ScanStatus;

@interface DCParseDelegate : NSObject<NSXMLParserDelegate> {
    NSXMLParser *xmlParser_;
    
    NSMutableArray *eventsArray;
    NSMutableArray *birthsArray;
    NSMutableArray *dearthsArray;
    NSArray *allArrays;
    
    NSMutableString *eventString;
    
    NSString *eventsAtr;
    NSString *birthsAtr;
    NSString *deathsAtr;
    NSString *primAtr, *primAtr2;
    
    ScanStatus scanStatus;
}

@property(nonatomic, strong) NSXMLParser *xmlParser;
@property(nonatomic, assign) id <DCViewControllerDelegate> delegate;

- (id)init;
- (id)initWithData:(NSData*)data;

- (BOOL)start;

@end

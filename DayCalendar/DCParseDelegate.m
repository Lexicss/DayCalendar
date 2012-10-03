//
//  DCParseDelegate.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/14/12.
//
//

#define MANUALABORT_ERROR_CODE 27

#import "DCParseDelegate.h"

@interface DCParseDelegate()
- (BOOL)isId:(NSString*)idValue inAttributes:(NSDictionary*)attributes;
@end

@implementation DCParseDelegate
@synthesize xmlParser = xmlParser_;
@synthesize delegate = delegate_;


- (id)init {
    return [self initWithData:nil];
}
- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        xmlParser_ = [[NSXMLParser alloc] initWithData:data];
        [xmlParser_ setDelegate:self];
        if([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ru"]) {
            eventsAtr = [@".D0.A1.D0.BE.D0.B1.D1.8B.D1.82.D0.B8.D1.8F" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            birthsAtr = [@".D0.A0.D0.BE.D0.B4.D0.B8.D0.BB.D0.B8.D1.81.D1.8C" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            deathsAtr = [@".D0.A1.D0.BA.D0.BE.D0.BD.D1.87.D0.B0.D0.BB.D0.B8.D1.81.D1.8C" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            primAtr = [@".D0.9F.D1.80.D0.B8.D0.BC.D0.B5.D1.82.D1.8B" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            primAtr2 = [@".D0.9D.D0.B0.D1.80.D0.BE.D0.B4.D0.BD.D1.8B.D0.B9_.D0.BA.D0.B0.D0.BB.D0.B5.D0.BD.D0.B4.D0.B0.D1.80.D1.8C.2C_.D0.BF.D1.80.D0.B8.D0.BC.D0.B5.D1.82.D1.8B_.D0.B8_.D1.84.D0.BE.D0.BB.D1.8C.D0.BA.D0.BB.D0.BE.D1.80_.D0.A0.D1.83.D1.81.D0.B8" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            eventsAtr = @"Events";
            birthsAtr = @"Births";
            deathsAtr = @"Deaths";
            primAtr = @"Holidays_and_observances";
            primAtr2 = [primAtr copy];
        }
        scanStatus = kScanStatusNone;
    }
    return self;
}

- (BOOL)start {
    return [xmlParser_ parse];
}

#pragma mark - Inner methods

- (BOOL)isId:(NSString *)idValue inAttributes:(NSDictionary *)attributes {
    return [[attributes valueForKey:@"id"] isEqualToString:idValue];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if (eventsArray) {
        eventsArray = nil;
    }
    
    if (birthsArray) {
        birthsArray = nil;
    }
    
    if (eventString) {
        eventString = nil;
    }
    
    scanStatus = kScanStatusEvents;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    scanStatus = kScanStatusNone;
    allArrays = [NSArray arrayWithObjects:eventsArray, birthsArray, dearthsArray, nil];
    [delegate_ wikiResponseFinishedWithEvents:allArrays];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"span"]) {
        
        switch (scanStatus) {
            case kScanStatusEvents: {
                if ([[attributeDict valueForKey:@"class"] isEqualToString:@"mw-headline"] &&
                    [self isId:eventsAtr inAttributes:attributeDict]) {
                    eventsArray = [NSMutableArray array];
                }
                
                
                // time to finish parsing
                if ([[attributeDict valueForKey:@"class"] isEqualToString:@"mw-headline"] &&
                    ([self isId:birthsAtr inAttributes:attributeDict] ||
                     [self isId:deathsAtr inAttributes:attributeDict] ||
                     [self isId:primAtr inAttributes:attributeDict])) {
                        birthsArray = [NSMutableArray array];
                        scanStatus = kScanStatusBirths;
                    }
            }
                break;
                
                
            case kScanStatusBirths: {
                // time to finish parsing
                if ([[attributeDict valueForKey:@"class"] isEqualToString:@"mw-headline"] &&
                     ([self isId:deathsAtr inAttributes:attributeDict] ||
                      [self isId:primAtr inAttributes:attributeDict])) {
                         dearthsArray = [NSMutableArray array];
                         scanStatus = kScanStatusDearths;

                    }
            }
                break;
                
            case kScanStatusDearths: {
                if ([[attributeDict valueForKey:@"class"] isEqualToString:@"mw-headline"] &&
                    ([self isId:primAtr inAttributes:attributeDict] ||
                     [self isId:primAtr2 inAttributes:attributeDict])) {
                    [xmlParser_ abortParsing];
                    scanStatus = kScanStatusNone;
                    allArrays = [NSArray arrayWithObjects:eventsArray, birthsArray, dearthsArray, nil];
                    [delegate_ wikiResponseFinishedWithEvents:allArrays];
                    return;
                }
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if ( (eventsArray && scanStatus == kScanStatusEvents && [elementName isEqualToString:@"li"]) ||
         (birthsArray && scanStatus == kScanStatusBirths && [elementName isEqualToString:@"li"]) ||
         (dearthsArray && scanStatus == kScanStatusDearths && [elementName isEqualToString:@"li"])) {
        eventString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (scanStatus == kScanStatusEvents && eventsArray && eventString && [elementName isEqualToString:@"li"]) {
        [eventsArray addObject:eventString];
        eventString = nil;
        return;
    }
    if (scanStatus == kScanStatusBirths && birthsArray && eventString && [elementName isEqualToString:@"li"]) {
        [birthsArray addObject:eventString];
        eventString = nil;
        return;
    }
    if (scanStatus == kScanStatusDearths && dearthsArray && eventString && [elementName isEqualToString:@"li"]) {
        [dearthsArray addObject:eventString];
        eventString = nil;
        return;
    }
    
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ((scanStatus == kScanStatusEvents && eventsArray && eventString) ||
        (scanStatus == kScanStatusBirths && birthsArray && eventString) ||
        (scanStatus == kScanStatusDearths && dearthsArray && eventString)) {
        [eventString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"ERROR: %@", [parseError localizedDescription]);
    NSLog(@"line: %d, column: %d",[parser lineNumber], [parser columnNumber]);
    if ([parseError code] != MANUALABORT_ERROR_CODE &&
        [parseError code] != 512 ) {
        __block NSString *errorDescription = [parseError localizedDescription];
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            UIAlertView *parseAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Parser error", nil)
                                                                     message:errorDescription
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil, nil];
            [parseAlertView show];
            [delegate_ wikiResponseFinishedWithEvents:allArrays];
        });
    }
}

@end

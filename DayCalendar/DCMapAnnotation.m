//
//  DCMapAnnotation.m
//  DayCalendar
//
//  Created by Lexicss on 07.10.12.
//
//

#import "DCMapAnnotation.h"

@implementation DCMapAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)aTitle andCoordinate:(CLLocationCoordinate2D)aCoordinate {
    self = [super init];
    if (self) {
        title = aTitle;
        coordinate = aCoordinate;
    }
    return self;
}
@end

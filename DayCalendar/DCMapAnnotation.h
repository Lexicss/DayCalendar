//
//  DCMapAnnotation.h
//  DayCalendar
//
//  Created by Lexicss on 07.10.12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DCMapAnnotation : NSObject <MKAnnotation> {
    NSString *title;
    CLLocationCoordinate2D coordinate;
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString*)aTitle andCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end

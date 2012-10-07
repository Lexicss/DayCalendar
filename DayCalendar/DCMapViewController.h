//
//  DCMapViewController.h
//  DayCalendar
//
//  Created by Lexicss on 07.10.12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DCMapAnnotation.h"
#import "API.h"

@interface DCMapViewController : UIViewController <MKMapViewDelegate>

- (id)initWithLocation:(CLLocationCoordinate2D)aLocationCoordinates;

@end

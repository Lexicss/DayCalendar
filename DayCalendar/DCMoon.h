//
//  DCMoon.h
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 9/6/12.
//
//

#import <Foundation/Foundation.h>
#import "DCDayInfo.h"
#import "API.h"

@interface DCMoon : NSObject
+ (RiseSetTimes) calculateMoonWithGeoPoint:(DCGeoPoint *)geoPoint;
@end

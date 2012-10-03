//
//  API.h
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/20/12.
//
//

#import <Foundation/Foundation.h>

#define SECONDS_IN_HOUR 3600
#define SECONDS_IN_DAY 86400

struct RiseSetTimes {
    CGFloat rise;
    CGFloat set;
};
typedef struct RiseSetTimes RiseSetTimes;

@interface API : NSObject

+ (NSInteger)iosVersion;

+ (NSOperation *)threadOperation;
+ (void)setThreadOperation:(NSOperation *)aOperation;

+ (NSOperationQueue *)threadQueue;
+ (void)setThreadQueue:(NSOperationQueue *)aQueue;
@end

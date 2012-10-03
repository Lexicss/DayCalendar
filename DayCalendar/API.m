//
//  API.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/20/12.
//
//

#import "API.h"
#import "DCViewController.h"

#define MAX_VERSION_POINTS 3
#define __IPHONE_2_0 20000
#define __IPHONE_2_1 20100
#define __IPHONE_2_2 20200
#define __IPHONE_3_0 30000
#define __IPHONE_3_1 30100
#define __IPHONE_3_2 30200
#define __IPHONE_4_0 40000
#define __IPHONE_4_3 40300
#define __IPHONE_5_0 50000
#define __IPHONE_6_0 60000


@implementation API

static NSInteger _iosVersion;
static NSOperation *operation;
static NSOperationQueue *queue;

+ (void)initialize {
    _iosVersion = [API systemVersionAsAnInteger];
}

#pragma mark - Versioning
+ (NSInteger)systemVersionAsAnInteger {
    int index = 0;
    NSInteger version = 0;
    
    NSArray* digits = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSEnumerator* enumer = [digits objectEnumerator];
    NSString* number;
    while (number = [enumer nextObject]) {
        if (index > MAX_VERSION_POINTS - 1) {
            break;
        }
        NSInteger multipler = powf(100, MAX_VERSION_POINTS - 1 - index);
        version += [number intValue]*multipler; 
        index++;
    }
    return version;
}

+ (NSInteger)iosVersion {
    return _iosVersion;
}

#pragma mark - Operation;

+ (NSOperation *)threadOperation {
    return operation;
}

+ (void)setThreadOperation:(NSOperation *)aOperation {
    if (operation != aOperation) {
        operation = aOperation;
    }
}

+ (NSOperationQueue *)threadQueue {
    return queue;
}

+ (void) setThreadQueue:(NSOperationQueue *)aQueue {
    if (queue != aQueue) {
        queue = aQueue;
    }
}

@end

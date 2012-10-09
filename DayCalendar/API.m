//
//  API.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/20/12.
//
//

#import "API.h"
#import "DCViewController.h"
#import "DCMapViewController.h"

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

@interface API ()

@property(nonatomic, readonly) UINavigationController *navigationAPI;

@end


@implementation API
@synthesize navigationAPI;

static API *instance;
static CLLocationCoordinate2D custamCoordinate;
static NSString *custamRegionName;

static NSInteger _iosVersion;
static NSOperation *operation;
static NSOperationQueue *queue;

#pragma mark - Singelton

+ (API *)instance {
    return instance;
}

+ (UINavigationController *)navigationAPI {
    return [instance navigationAPI];
}

+ (CLLocationCoordinate2D)custamCoordinate {
    return custamCoordinate;
}

+ (void)setCustamCoordinate:(CLLocationCoordinate2D)newCoordinate {
    custamCoordinate = newCoordinate;
}

+ (NSString*)custamRegionName {
    return [custamRegionName copy];
}

+ (void)setCustamRegionName:(NSString*)newRegionName {
    if (newRegionName != custamRegionName) {
      custamRegionName = [newRegionName copy];
    }
}

+ (void)initialize {
    instance = [API new];
    _iosVersion = [API systemVersionAsAnInteger];
}

#pragma mark - Constructor

- (id)init {
    self = [super init];
    if (self) {
        DCViewController *mainViewController = [[DCViewController alloc] initWithNibName:nil bundle:nil];
        if (!navigationAPI) {
            navigationAPI = [[UINavigationController alloc] initWithRootViewController:mainViewController];
            UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(mapButtonClicked:)];
            [navigationAPI.topViewController.navigationItem setRightBarButtonItem:rigthItem];
            [navigationAPI.topViewController setTitle:@"Calendar"];
        }
    }
    return self;
}

- (void)mapButtonClicked:(id)sender {
    if (![[navigationAPI topViewController] isMemberOfClass:[DCViewController class]]) {
        return;
    }
    CLLocationCoordinate2D coordinates = [(DCViewController *)[navigationAPI topViewController] defaultCoordinates];
    
    
    DCMapViewController *mvc = [[DCMapViewController alloc] initWithLocation:coordinates];
    [navigationAPI pushViewController:mvc animated:YES];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Change position"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(changePositionClicked:)];
    [mvc.navigationItem setRightBarButtonItem:rightItem];
}

- (void)changePositionClicked:(id)sender {
    [navigationAPI popViewControllerAnimated:YES];
    if ([navigationAPI.topViewController isMemberOfClass:[DCViewController class]]) {
        [(DCViewController*)[navigationAPI topViewController] refreshCalendarDataWithCustomCoordinate:[API custamCoordinate] andRegionName:[API custamRegionName]] ;
    }
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

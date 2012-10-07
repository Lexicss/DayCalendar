//
//  DCMapViewController.m
//  DayCalendar
//
//  Created by Lexicss on 07.10.12.
//
//

#import "DCMapViewController.h"

@interface DCMapViewController () {
    MKMapView *mapView_;
    CGRect viewFrame_;
    CLLocationCoordinate2D initialCoordinates;
    UILongPressGestureRecognizer *longPressGesture_;
    NSDate *lastPressDate_;
}
@property(nonatomic, strong) UILongPressGestureRecognizer* longPressGesture;

@end

@implementation DCMapViewController
@synthesize longPressGesture = longPressGesture_;

- (void)handleLongTap:(id)sender {
    if ([lastPressDate_ timeIntervalSinceNow] >= -2) return;
    
    CGPoint touchPoint = [self.longPressGesture locationInView:self.view];
    CLLocationCoordinate2D touchCoordinate = [mapView_ convertPoint:touchPoint toCoordinateFromView:self.view];
    [mapView_ removeAnnotation:[mapView_.annotations lastObject]];
    DCMapAnnotation *oneAnnotation = [[DCMapAnnotation alloc] initWithTitle:@"Selected place"
                                                              andCoordinate:touchCoordinate];
    [mapView_ addAnnotation:oneAnnotation];
    lastPressDate_ = [NSDate date];
}

#pragma mark - VC lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithLocation:(CLLocationCoordinate2D)aLocationCoordinates {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        initialCoordinates = aLocationCoordinates;
    }
    return self;
}

- (void)loadView {
    viewFrame_ = [UIScreen mainScreen].bounds;
    mapView_ = [[MKMapView alloc] initWithFrame:viewFrame_];
    MKCoordinateSpan mapSpan = MKCoordinateSpanMake(0.4, 0.4);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(initialCoordinates,mapSpan);
    [mapView_ setRegion:mapRegion];
    [mapView_ setDelegate:self];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleLongTap:)];
    [self setLongPressGesture:longPressGesture];
    [mapView_ addGestureRecognizer:self.longPressGesture];
    
    [self setView:mapView_];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	DCMapAnnotation *oneAnnotation = [[DCMapAnnotation alloc] initWithTitle:@"Selected place"
                                                              andCoordinate:initialCoordinates];
    [mapView_ addAnnotation:oneAnnotation];
}

- (void)viewWillDisappear:(BOOL)animated {
    DCMapAnnotation *lastAnnotation = [mapView_.annotations lastObject];
    [API setCustamCoordinate:[lastAnnotation coordinate]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  DCMapViewController.m
//  DayCalendar
//
//  Created by Lexicss on 07.10.12.
//
//

#import "DCMapViewController.h"
#import "TODOMacros.h"

@interface DCMapViewController () {
    MKMapView *mapView_;
    CGRect viewFrame_;
    CLLocationCoordinate2D initialCoordinates;
    UILongPressGestureRecognizer *longPressGesture_;
    NSDate *lastPressDate_;
    DCMapAnnotation *currentAnnonation_;
}
@property(nonatomic, strong) UILongPressGestureRecognizer* longPressGesture;
@property(nonatomic, strong) DCMapAnnotation *currentAnnotation;

- (void)assignNewName:(NSString*)aName;

@end

@implementation DCMapViewController
@synthesize longPressGesture = longPressGesture_;
@synthesize currentAnnotation = currentAnnonation_;

- (void)handleLongTap:(id)sender {
    if ([lastPressDate_ timeIntervalSinceNow] >= -2) return;
    
    CGPoint touchPoint = [self.longPressGesture locationInView:self.view];
    CLLocationCoordinate2D touchCoordinate = [mapView_ convertPoint:touchPoint toCoordinateFromView:self.view];
    [mapView_ removeAnnotation:[mapView_.annotations lastObject]];
    DCMapAnnotation *oneAnnotation = [[DCMapAnnotation alloc] initWithTitle:NSLocalizedString(@"Selected place", nil)
                                                              andCoordinate:touchCoordinate];
    [self setCurrentAnnotation:oneAnnotation];
    [mapView_ addAnnotation:oneAnnotation];
    
    // modern style from ios 5.0
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude
                                                      longitude:touchCoordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || !placemarks) {
            [self assignNewName:NSLocalizedString(@"Unnamed place", nil)];
        } else {
            MKPlacemark *placemark = placemarks[0];
            [self assignNewName:[placemark locality]];
        }
    }];
    
    //------
    
    
    lastPressDate_ = [NSDate date];
}

- (void)assignNewName:(NSString *)aName {
    [self.currentAnnotation setTitle:aName];
    [API setCustamRegionName:aName];
}

#pragma mark - VC lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lastPressDate_ = [NSDate date];
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


TODO("implement GPS searching (CLLocationManager) later")
- (void)loadView {
    viewFrame_ = [UIScreen mainScreen].bounds;
    mapView_ = [[MKMapView alloc] initWithFrame:viewFrame_];
    MKCoordinateSpan mapSpan = MKCoordinateSpanMake(0.4, 0.4);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(initialCoordinates,mapSpan);
    [mapView_ setRegion:mapRegion];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleLongTap:)];
    [self setLongPressGesture:longPressGesture];
    [mapView_ addGestureRecognizer:self.longPressGesture];
    
    [self setView:mapView_];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	DCMapAnnotation *oneAnnotation = [[DCMapAnnotation alloc] initWithTitle:NSLocalizedString(@"Selected place", nil)
                                                              andCoordinate:initialCoordinates];
    [mapView_ addAnnotation:oneAnnotation];
}

- (void)viewWillAppear:(BOOL)animated {
    [mapView_ setDelegate:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    DCMapAnnotation *lastAnnotation = [mapView_.annotations lastObject];
    [API setCustamCoordinate:[lastAnnotation coordinate]];
    [mapView_ setDelegate:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

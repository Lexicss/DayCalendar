//
//  DCMoon.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 9/6/12.
//
//

#define DR M_PI/180
#define K1  15*DR*1.0027379
#define RAD(X) X * M_PI / 180.0

#import "DCMoon.h"

@implementation DCMoon

static long double sky0 = 0;
static long double sky1 = 0;
static long double sky2 = 0;

static long double RAn0 = 0;
static long double Dec0 = 0;

static long double Dec1 = 0;
static long double RAn2 = 0;
static long double Dec2 = 0;

static long double VHz0 = 0;
static long double VHz1 = 0;
static long double VHz2 = 0;

static long double Rise_time0 = 0;
static long double Rise_time1 = 0;
static long double Set_time0 = 0;
static long double Set_time1 = 0;

static long double Rise_az = 0.0;
static long double Set_az = 0.0;



+ (double)localSideralTimeForLatitude:(CGFloat)longitude julianDate:(double)JD andZone:(double)z {
    double s = 24110.5 + 8640184.812999999*JD/36525.0 + 86636.6*z + 86400*longitude;
    s /= 86400;
    s -= floor(s);
    return s*360*DR;
}

+ (void)moon:(double)jd {
    double d, f, g, h, m, n, s, u, v, w;
    h = 0.606434 + 0.03660110129*jd;
    m = 0.374897 + 0.03629164709*jd;
    f = 0.259091 + 0.0367481952 *jd;
    d = 0.827362 + 0.03386319198*jd;
    n = 0.347343 - 0.00014709391*jd;
    g = 0.993126 + 0.0027377785 *jd;
    
    h = h - floor(h);
    m = m - floor(m);
    f = f - floor(f);
    d = d - floor(d);
    n = n - floor(n);
    g = g - floor(g);
    
    h = h*2*M_PI;
    m = m*2*M_PI;
    f = f*2*M_PI;
    d = d*2*M_PI;
    n = n*2*M_PI;
    g = g*2*M_PI;
    
    v = 0.39558*sin(f + n);
    v = v + 0.082  *sin(f);
    v = v + 0.03257*sin(m - f - n);
    v = v + 0.01092*sin(m + f + n);
    v = v + 0.00666*sin(m - f);
    v = v - 0.00644*sin(m + f - 2*d + n);
    v = v - 0.00331*sin(f - 2*d + n);
    v = v - 0.00304*sin(f - 2*d);
    v = v - 0.0024 *sin(m - f - 2*d - n);
    v = v + 0.00226*sin(m + f);
    v = v - 0.00108*sin(m + f - 2*d);
    v = v - 0.00079*sin(f - n);
    v = v + 0.00078*sin(f + 2*d + n);
    
    u = 1 - 0.10828*cos(m);
    u = u - 0.0188 *cos(m - 2*d);
    u = u - 0.01479*cos(2*d);
    u = u + 0.00181*cos(2*m - 2*d);
    u = u - 0.00147*cos(2*m);
    u = u - 0.00105*cos(2*d - g);
    u = u - 0.00075*cos(m - 2*d + g);
    
    w = 0.10478*sin(m);
    w = w - 0.04105*sin(2*f + 2*n);
    w = w - 0.0213 *sin(m - 2*d);
    w = w - 0.01779*sin(2*f + n);
    w = w + 0.01774*sin(n);
    w = w + 0.00987*sin(2*d);
    w = w - 0.00338*sin(m - 2*f - 2*n);
    w = w - 0.00309*sin(g);
    w = w - 0.0019 *sin(2*f);
    w = w - 0.00144*sin(m + n);
    w = w - 0.00144*sin(m - 2*f - n);
    w = w - 0.00113*sin(m + 2*f + 2*n);
    w = w - 0.00094*sin(m - 2*d + g);
    w = w - 0.00092*sin(2*m - 2*d);
    
    s = w/sqrt(u - v*v);                  // compute moon's right ascension ...
    sky0 = h + atan(s/sqrt(1 - s*s));
    
    s = v/sqrt(u);                        // declination ...
    sky1 = atan(s/sqrt(1 - s*s));
    
    sky2 = 60.40974*sqrt( u );          // and parallax
}

+ (double)interpolatef0:(double)f0 f1:(double)f1 f2:(double)f2 p:(double)p {
    long double a = f1 - f0;
    long double b = f2 - f1 - a;
    long double f = f0 + p*(2*a + b*(2*p - 1));
    return f;
}

+ (double)testMoonWithK:(double)k withZone:(double)zone withT0:(double)t0 withLat:(CGFloat)lat withPlx:(double)plx {
    double ha0,ha1,ha2;
    double a, b, c, d, e, s, z;
    double hr, min, time;
    double az, hz, nz, dz;
    
    if (RAn2 < RAn0)
        RAn2 += 2*M_PI;
    ha0 = t0 - RAn0 + k*K1;
    ha2 = t0 - RAn2 + k*K1 + K1;
    
    ha1  = (ha2 + ha0)/2;                // hour angle at half hour
    Dec1 = (Dec2 + Dec0)/2;              // declination at half hour
    
    s = sin(DR*lat);
    c = cos(DR*lat);
    
    // refraction + sun semidiameter at horizon + parallax correction
    z = cos(DR*(90.567 - 41.685/plx));
    
    if (k <= 0)                             // first call of function
        VHz0 = s*sin(Dec0) + c*cos(Dec0)*cos(ha0) - z;
    
    VHz2 = s*sin(Dec2) + c*cos(Dec2)*cos(ha2) - z;
    
    if ([DCDayInfo sign:VHz0] == [DCDayInfo sign:VHz2])
        return VHz2;                         // no event this hour
    
    VHz1 = s*sin(Dec1) + c*cos(Dec1)*cos(ha1) - z;
    
    a = 2*VHz2 - 4*VHz1 + 2*VHz0;
    b = 4*VHz1 - 3*VHz0 - VHz2;
    d = b*b - 4*a*VHz0;
    
    if (d < 0)
        return VHz2;                         // no event this hour
    
    d = sqrt(d);
    e = (-b + d)/(2*a);
    
    if (( e > 1 )||( e < 0 ))
        e = (-b - d)/(2*a);
    
    time = k + e + 1/120.0;                      // time of an event + round up
    hr   = floor(time);
    min  = floor((time - hr)*60);
    
    hz = ha0 + e*(ha2 - ha0);            // azimuth of the moon at the event
    nz = -cos(Dec1)*sin(hz);
    dz = c*sin(Dec1) - s*cos(Dec1)*cos(hz);
    az = atan2(nz, dz)/DR;
    if (az < 0) az = az + 360;
    
    if ((VHz0 < 0) && (VHz2 > 0))
    {
        Rise_time0 = hr;
        Rise_time1 = min;
        Rise_az = az;
        //Moonrise = true;
    }
    
    if ((VHz0 > 0)&&(VHz2 < 0))
    {
        Set_time0 = hr;
        Set_time1 = min;
        Set_az = az;
        //Moonset = true;
    }
    
    return VHz2;
    
    return 0;
}

+ (double)arrayValueI:(NSInteger)i andJ:(NSInteger)j forArray:(NSMutableArray*)array {
    NSMutableArray *subArray = [array objectAtIndex:i];
    NSNumber *doubleNumber = [subArray objectAtIndex:j];
    return [doubleNumber doubleValue];
}

+ (void)setArrayDoubleValue:(double)value forI:(NSInteger)i forJ:(NSInteger)j forArray:(NSMutableArray*)array {
    NSMutableArray *subArray = [array objectAtIndex:i];
    NSNumber *doubleNumber = [NSNumber numberWithDouble:value];
    [subArray setObject:doubleNumber atIndexedSubscript:j];
}

+ (RiseSetTimes) calculateMoonWithGeoPoint:(DCGeoPoint *)geoPoint{
    double zone = -[geoPoint.timeZone secondsFromGMT] / SECONDS_IN_HOUR;//-3.0;
    double jdlp = [DCDayInfo julianDayFromComponents:[geoPoint dateTime]];//[DCDayInfo jFromG:components];
    double jd = jdlp - 2451545;
    
    NSMutableArray *mp = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i=0; i < 3; i++) {
        NSMutableArray *subArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (int j=0; j < 3; j++) {
            [subArray addObject:[NSNumber numberWithDouble:0.0]];
        }
        [mp addObject:subArray];
    }
    
    double lon = [geoPoint longitude] / 360;
    double tz = zone / 24;
    double t0 = [self localSideralTimeForLatitude:lon julianDate:jd andZone:tz];
    jd += tz;
    
    for (int k = 0; k < 3; k++) {
        [self moon:jd];
        [self setArrayDoubleValue:sky0 forI:k forJ:0 forArray:mp];
        [self setArrayDoubleValue:sky1 forI:k forJ:1 forArray:mp];
        [self setArrayDoubleValue:sky2 forI:k forJ:2 forArray:mp];
        jd += 0.5;
    }
    
    if ([self arrayValueI:1 andJ:0 forArray:mp] <= [self arrayValueI:0 andJ:0 forArray:mp]) {
        double tempValue = [self arrayValueI:1 andJ:0 forArray:mp] + 2*M_PI;
        [self setArrayDoubleValue:tempValue forI:1 forJ:0 forArray:mp];
    }
    if ([self arrayValueI:2 andJ:0 forArray:mp] <= [self arrayValueI:1 andJ:0 forArray:mp]) {
        double tempValue = [self arrayValueI:2 andJ:0 forArray:mp] + 2*M_PI;
        [self setArrayDoubleValue:tempValue forI:2 forJ:0 forArray:mp];
    }
    
    RAn0 = [self arrayValueI:0 andJ:0 forArray:mp];
    Dec0 = [self arrayValueI:0 andJ:1 forArray:mp];
    
    for (int k = 0; k < 24; k++) {
        double ph = (k+1)/24;
        RAn2 = [self interpolatef0:[self arrayValueI:0 andJ:0 forArray:mp]
                                f1:[self arrayValueI:1 andJ:0 forArray:mp]
                                f2:[self arrayValueI:2 andJ:0 forArray:mp] p:ph];
        Dec2 = [self interpolatef0:[self arrayValueI:0 andJ:1 forArray:mp]
                                f1:[self arrayValueI:1 andJ:1 forArray:mp]
                                f2:[self arrayValueI:2 andJ:1 forArray:mp] p:ph];
        
        VHz2 = [self testMoonWithK:k
                          withZone:zone
                            withT0:t0
                           withLat:[geoPoint latitude]
                           withPlx:[self arrayValueI:1 andJ:2 forArray:mp]];
        RAn0 = RAn2;
        Dec0 = Dec2;
        VHz0 = VHz2;
    }
    RiseSetTimes moonTimes;
    moonTimes.rise = Rise_time0 + Rise_time1 / 60;
    moonTimes.set = Set_time0 + Set_time1 / 60;
    
    return moonTimes;
}

@end

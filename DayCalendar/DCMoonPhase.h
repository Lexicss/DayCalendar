//
//  DCMoonPhase.h
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/22/12.
//
//

#import <Foundation/Foundation.h>

@interface DCMoonPhase : NSObject {
    CGFloat period_;
    NSString *name_;
    NSUInteger index_;
}
@property (nonatomic, readonly) CGFloat period;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger index;

- (id) initWithPeriod:(CGFloat)aperiod;

+ (NSDateComponents*)componentsForNextPhaseOf:(DCMoonPhase*)moonPhase fromComponents:(NSDateComponents*)fromComponents;
@end

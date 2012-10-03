//
//  DCZodiac.h
//  DayCalendar
//
//  Created by admin on 18.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCZodiac : NSObject {
    NSString *sign_;
    NSString *name_;
    NSUInteger index_;
}
@property(nonatomic, readonly) NSString *sign;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSUInteger index;

- (id)initWithIndex:(NSUInteger)aIndex;

+ (DCZodiac*)westernZodicacFromDateComponents:(NSDateComponents *)dateComponents;
+ (DCZodiac*)sunZodiacFromDateComponents:(NSDateComponents *)dateComponents;

@end

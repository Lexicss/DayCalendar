//
//  DCPopView.m
//  DayCalendar
//
//  Created by Aliaksei_Maiorau on 8/15/12.
//
//

#define Y_OFFSET 20
#define BORDER 5
#define ALPHA 0.85
#define DURATION 0.75
#define Y_TEXT_OFFSET 30

#define TEXT_VIEV_FONT [UIFont fontWithName:@"Cochin-Bold" size:15]

#import "DCPopView.h"

CGPoint lastCenter;

@interface DCPopView() {
    CGPoint firstLocation;
}
- (void)handleTap:(id)sender;
@end

@implementation DCPopView

+ (void)initialize {
    CGRect mainRect = [UIScreen mainScreen].bounds;
    UIImage *oldPaperImage = [UIImage imageNamed:@"oldpaper.jpeg"];
    lastCenter = CGPointMake(mainRect.size.width / 2, Y_OFFSET + oldPaperImage.size.height / 2);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithText:(NSString *)text {
    UIImage *oldPaperImage = [UIImage imageNamed:@"oldpaper.jpeg"];
    CGRect neededRect = CGRectMake(lastCenter.x - oldPaperImage.size.width / 2, lastCenter.y - oldPaperImage.size.height / 2, oldPaperImage.size.width, oldPaperImage.size.height);
    
    if ([oldPaperImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {    
        UIEdgeInsets edgeInsets;
        edgeInsets.top = 70;
        edgeInsets.bottom = 70;
        edgeInsets.left = 50;
        edgeInsets.right = 50;
        [oldPaperImage resizableImageWithCapInsets:edgeInsets];
    }
    
    self = [super initWithFrame:neededRect];
    if (self) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(BORDER, BORDER, oldPaperImage.size.width - BORDER, oldPaperImage.size.height - BORDER)];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:TEXT_VIEV_FONT];
        [textView setText:text];
        [textView setEditable:NO];
        
        CGSize textViewSize = [text sizeWithFont:TEXT_VIEV_FONT constrainedToSize:textView.frame.size lineBreakMode:UILineBreakModeHeadTruncation];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:oldPaperImage];
        [self addSubview:imageView];
        CGRect selfFrame = [self frame];
        CGRect textViewFrame = [textView frame];

        selfFrame.origin.y = ceilf(selfFrame.origin.y);
        selfFrame.size.height = textViewSize.height + Y_TEXT_OFFSET + 2*BORDER;  // textView.contentSize.height + 0;
        textViewFrame.size.height = selfFrame.size.height;
        [textView setFrame:textViewFrame];
        [self setFrame:selfFrame];
        [imageView setFrame:self.bounds];
        
        
        [self addSubview:textView];
        [self setAlpha:0];
        [textView setUserInteractionEnabled:NO];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleTap:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)handleTap:(id)sender {
    [self animateWithAppearence:NO];
}

#pragma mark - Animation

- (void)animateWithAppearence:(BOOL)appear {
    if (appear) {
        if (self.alpha != 0)
            return;
        
        [UIView animateWithDuration:DURATION animations:^(void){
            [self setAlpha:ALPHA];
        }];
    } else {
        if (self.alpha == 0)
            return;
        [UIView animateWithDuration:DURATION animations:^(void){
            [self setAlpha:0];
        } completion:^(BOOL finished){
                [self removeFromSuperview];
        }];
        
    }
}

#pragma mark - Moving by touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    firstLocation = [touch locationInView:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint lastLocation = [touch locationInView:self];
    CGFloat deltaX = lastLocation.x - firstLocation.x;
    CGFloat deltaY = lastLocation.y - firstLocation.y;
    CGPoint currentCenter = self.center;
    CGPoint newCenterPoint = CGPointMake(currentCenter.x + deltaX, currentCenter.y + deltaY);
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    mainScreen.size.height -= [UIApplication sharedApplication].statusBarFrame.size.height;
    if (newCenterPoint.x < self.frame.size.width / 2)
        newCenterPoint.x = self.frame.size.width / 2;
    if (newCenterPoint.y < self.frame.size.height / 2)
        newCenterPoint.y = self.frame.size.height / 2;
    if (newCenterPoint.x > mainScreen.size.width - self.frame.size.width / 2)
        newCenterPoint.x = mainScreen.size.width - self.frame.size.width / 2;
    if (newCenterPoint.y > mainScreen.size.height - self.frame.size.height / 2)
        newCenterPoint.y = mainScreen.size.height - self.frame.size.height / 2;
    
    [self setCenter:newCenterPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    lastCenter = [self center];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    lastCenter = [self center];
}

@end

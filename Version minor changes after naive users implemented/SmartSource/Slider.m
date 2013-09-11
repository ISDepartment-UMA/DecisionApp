//
//  Slider.m
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Slider.h"
#import "RatingTableViewViewController.h"


@interface Slider ()
@property (nonatomic, strong) RatingTableViewViewController *sliderDelegate;




@end

@implementation Slider
@synthesize sliderDelegate = _sliderDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

    
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.highlighted) {
        [super touchesBegan:touches withEvent:event];
    }
    
    UITouch *lastTouch = [[touches objectEnumerator] nextObject];
    if (lastTouch) {
        CGPoint pt = [lastTouch locationInView:self];
        CGFloat percentage = pt.x / self.bounds.size.width;
        CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
        CGFloat value = self.minimumValue + delta;
        [self setValue:value animated:YES];
    }
    [super touchesBegan:touches withEvent:event];
}




//make slider bounce back to the closest possible value
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.value < 1.5) {
        [self setValue: 1.0 animated: YES];
    } else if (self.value < 2.5) {
        [self setValue: 2.0 animated: YES];
    } else if (self.value < 3.5) {
        [self setValue: 3.0 animated: YES];
    } else if (self.value < 4.5) {
        [self setValue: 4.0 animated: YES];
    } else {
        [self setValue: 5.0 animated: YES];
    }
    
    
    [self.sliderDelegate saveValueForSlider:self];
    //UILabel *textLabel = (UILabel *)[self.superview viewWithTag:10];
    //[self.currentComponentModel saveWeight:[NSNumber numberWithFloat:self.value] forSuperCharacteristic:textLabel.text];
    //[self sendActionsForControlEvents:UIControlEventValueChanged];
    
    
}






/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

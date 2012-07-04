//
//  Slider.m
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Slider.h"

@interface Slider ()
@property NSMutableArray *numbers;



@end

@implementation Slider
@synthesize numbers = _numbers;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }

    return self;
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

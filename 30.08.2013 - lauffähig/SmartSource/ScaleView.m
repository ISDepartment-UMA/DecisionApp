//
//  ScaleView.m
//  SmartSource
//
//  Created by Lorenz on 18.08.13.
//
//

#import "ScaleView.h"

@interface ScaleView ()

//Views
@property (nonatomic, strong) UIColor *colorOfSuperview;

@end

@implementation ScaleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setValue:(CGFloat)value
{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:77];
    CGFloat relativeValue = ((value - 1) / 2.0);
    CGFloat positionOfArrow = self.frame.size.width * relativeValue;
    [imageView setFrame:CGRectMake((positionOfArrow - (imageView.frame.size.width/2)), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
}





@end

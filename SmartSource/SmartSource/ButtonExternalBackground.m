

//
//  TopBarButton.m
//  SmartSource
//
//  Created by Lorenz on 16.08.13.
//
//

#import "ButtonExternalBackground.h"

@interface ButtonExternalBackground ()

//Views
@property (nonatomic, strong) UIColor *colorOfSuperview;

@end


@implementation ButtonExternalBackground
@synthesize colorOfSuperview = _colorOfSuperview;
@synthesize viewToChangeIfSelected = _viewToChangeIfSelected;
@synthesize colorToUseIfSelected = _colorToUseIfSelected;


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
    [super touchesBegan:touches withEvent:event];
    
    if (self.userInteractionEnabled) {
        if (!self.viewToChangeIfSelected) {
            self.viewToChangeIfSelected = self.superview;
        }
        
        if (!self.colorToUseIfSelected) {
            self.colorToUseIfSelected = [UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0];
        }
        
        self.colorOfSuperview = self.viewToChangeIfSelected.backgroundColor;
        [self.viewToChangeIfSelected setBackgroundColor:self.colorToUseIfSelected];
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.userInteractionEnabled) {
        [self.viewToChangeIfSelected setBackgroundColor:self.colorOfSuperview];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (self.userInteractionEnabled) {
        [self.viewToChangeIfSelected setBackgroundColor:self.colorOfSuperview];
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


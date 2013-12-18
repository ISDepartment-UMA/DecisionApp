

//
//  ButtonExternalBackground.m
//  SmartSource
//
//  Created by Lorenz on 16.08.13.
//
//

#import "ButtonExternalBackground.h"
#import "UIColor+SmartSourceColors.h"

@interface ButtonExternalBackground ()
//Views
@property (nonatomic, strong) UIColor *colorOfSuperview;
@end

@implementation ButtonExternalBackground
@synthesize colorOfSuperview = _colorOfSuperview;
@synthesize viewToChangeIfSelected = _viewToChangeIfSelected;
@synthesize colorToUseIfSelected = _colorToUseIfSelected;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.userInteractionEnabled) {
        if (!self.viewToChangeIfSelected) {
            self.viewToChangeIfSelected = self.superview;
        }
        
        if (!self.colorToUseIfSelected) {
            self.colorToUseIfSelected = [UIColor colorOrange];
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

@end


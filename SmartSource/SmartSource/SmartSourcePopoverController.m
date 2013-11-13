
//
//  PCPopoverController.m
//  PCPopoverControllerTests
//
//  Created by Patrick Perini on 5/16/12.
//  Licensing information available in README.md
//

#import "SmartSourcePopoverController.h"
#import "SmartSourcePopoverBackgroundView.h"

#pragma mark - Internal Constants
CGFloat const contentInset = 10.0;
CGFloat const capInset = 25.0;
CGFloat const arrowHeight = 15.0;
CGFloat const arrowBase = 24.0;

@interface SmartSourcePopoverController()
@property (nonatomic, strong) UIColor *tintColor;

@end

@implementation SmartSourcePopoverController

#pragma mark - Properties
@synthesize tintColor = _tintColor;

#pragma mark - Initializers
- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [self initWithContentViewController: viewController
                                  andTintColor: [UIColor blackColor]];
    return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController andTintColor:(UIColor *)aTintColor
{
    self = [super initWithContentViewController: viewController];
    if (!self)
        return nil;
    
    [super setPopoverBackgroundViewClass: [SmartSourcePopoverBackgroundView class]];
    self.tintColor = aTintColor;
    
    return self;
}

#pragma mark - Overriders
- (void)setPopoverBackgroundViewClass:(Class)popoverBackgroundViewClass {}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    @synchronized(self)
    {
        [SmartSourcePopoverBackgroundView setCurrentTintColor:self.tintColor];
        [super presentPopoverFromRect: rect inView: view permittedArrowDirections: arrowDirections animated: animated];
    }
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    @synchronized(self)
    {
        [SmartSourcePopoverBackgroundView setCurrentTintColor:self.tintColor];
        [super presentPopoverFromBarButtonItem: item permittedArrowDirections: arrowDirections animated: animated];
    }
}

@end


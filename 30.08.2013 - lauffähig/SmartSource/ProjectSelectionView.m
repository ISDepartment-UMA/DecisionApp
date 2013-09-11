//
//  ProjectSelectionView.m
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import "ProjectSelectionView.h"
#import <QuartzCore/QuartzCore.h>

@interface ProjectSelectionView ()

@property (nonatomic) BOOL keepSpinning;

@end


@implementation ProjectSelectionView
@synthesize labelProjectName = _labelProjectName;
@synthesize labelProjectDescription = _labelProjectDescription;
@synthesize labelCategory = _labelCategory;
@synthesize labelStartDate = _labelStartDate;
@synthesize labelEndDate = _labelEndDate;
@synthesize labelCreator = _labelCreator;
@synthesize projectInfoView =_projectInfoView;
@synthesize selectProjectButton = _selectProjectButton;
@synthesize keepSpinning = _keepSpinning;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//designated initializer called by storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    
    return self;
}

- (void)setDisplayedProject:(Project *)project;
{
    [self.labelProjectName setText:project.name];
    [self.labelProjectDescription setText:project.descr];
    [self.labelCategory setText:project.category];
    [self.labelStartDate setText:project.startdate];
    [self.labelEndDate setText:project.enddate];
    [self.labelCreator setText:project.creator];
}


- (void)addActionsToSubviews
{
    // add targets to button
    [self.selectProjectButton setViewToChangeIfSelected:self.rightImageBackgroundView];
    [self.selectProjectButton setColorToUseIfSelected:[UIColor colorWithRed:0.98 green:0.7 blue:0.25 alpha:1.0]];
}

- (void)fitForPortraitMode
{
    
    //hide all subviews except for project name
    for (UIView *view in self.projectInfoView.subviews) {
        [view setHidden:YES];
    }
    [self.labelProjectName setHidden:NO];
}


- (void)fitForLandscapeMode
{
    
    //show all subbiews
    for (UIView *view in self.projectInfoView.subviews) {
        [view setHidden:NO];
    }
    
}

- (void)startActivityIndicator
{
    
    [self startSpin];
    


}

- (void)stopActivityIndicator
{
    
    [self stopSpin];
    
}


#define M_PI   3.14159265358979323846264338327950288   /* pi */
- (void) spinWithOptions:(UIViewAnimationOptions)options toAnkle:(CGFloat)ankle {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.leftImageView.transform = CGAffineTransformRotate(self.leftImageView.transform, ankle);
                     }
                     completion: ^(BOOL finished) {
                         
                         if (finished) {
                             if (self.keepSpinning) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear toAnkle:ankle];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 
                                 CGFloat radiants = atan2f(self.leftImageView.transform.b, self.leftImageView.transform.a);
                                 
                                 if (radiants > -0.1) {
                                     [self spinWithOptions: UIViewAnimationOptionCurveLinear toAnkle:ankle];
                                 } else {
                                     [self spinWithOptions:UIViewAnimationOptionCurveEaseOut toAnkle:(M_PI/2)];
                                 }
                                 
                             }
                         }
                     }];
    
}


- (void) startSpin {
    if (!self.keepSpinning) {
        self.keepSpinning = YES;
        CGFloat ankle = (M_PI/2);
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn toAnkle:ankle];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.keepSpinning = NO;
}



//deactivate view for user interaction
- (void)deactivateUserInteraction
{
    [self.selectProjectButton setUserInteractionEnabled:NO];
}


//activate view for user interaction
- (void)reactivateUserInteraction
{
    [self.selectProjectButton setUserInteractionEnabled:YES];
}

- (void)setEmpty
{
    [self.labelProjectName setText:@""];
    [self.labelProjectDescription setText:@""];
    [self.labelCategory setText:@""];
    [self.labelStartDate setText:@""];
    [self.labelEndDate setText:@""];
    [self.labelCreator setText:@""];
}


@end

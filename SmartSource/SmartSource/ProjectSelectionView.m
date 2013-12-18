//
//  ProjectSelectionView.m
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import "ProjectSelectionView.h"
#import "UIColor+SmartSourceColors.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProjectSelectionView
@synthesize labelProjectName = _labelProjectName;
@synthesize labelProjectDescription = _labelProjectDescription;
@synthesize labelCategory = _labelCategory;
@synthesize labelStartDate = _labelStartDate;
@synthesize labelEndDate = _labelEndDate;
@synthesize labelCreator = _labelCreator;
@synthesize projectInfoView =_projectInfoView;



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
    [self.triggerStepButton setViewToChangeIfSelected:self.rightImageBackgroundView];
    [self.triggerStepButton setColorToUseIfSelected:[UIColor colorOrangeBackgroundChange]];
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


- (void)setEmpty
{
    [super setEmpty];
    [self.labelProjectName setText:@""];
    [self.labelProjectDescription setText:@""];
    [self.labelCategory setText:@""];
    [self.labelStartDate setText:@""];
    [self.labelEndDate setText:@""];
    [self.labelCreator setText:@""];
}


@end

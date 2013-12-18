//
//  EvaluationView.m
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import "EvaluationView.h"

@implementation EvaluationView
@synthesize delegate = _delegate;

//ovveride to customize to evaluation view
+ (NSString *)textDescriptionLabelActive
{
    return @"The Project is ready for Evaluation.";
}
+ (NSString *)textDescriptionLabelInactive
{
    return @"There are no Components for Evaluation in this Project.";
}
+ (NSString *)rightImageNameActive
{
    return @"Start_Next_Active.png";
}
+ (NSString *)rightImageNameInactive
{
    return @"Start_Next_Inactive.png";
}

//override to change behavior when button is pressed
//calls the delegate to tell that the evaluate button has been pressed
- (void)triggerStepButtonPressed
{
    if ([self.delegate conformsToProtocol:@protocol(EvaluationViewDelegate)]) {
        [self.delegate evaluationButtonPressed];
    }
}

@end

//
//  ResultView.m
//  SmartSource
//
//  Created by Lorenz on 12.08.13.
//
//

#import "ResultView.h"

@implementation ResultView
@synthesize delegate = _delegate;

//ovveride to customize to evaluation view
+ (NSString *)textDescriptionLabelActive
{
    return @"Evaluation is complete. You can now view the Results.";
}
+ (NSString *)textDescriptionLabelInactive
{
    return @"Please evaluate all components in order to see the results.";
}
+ (NSString *)rightImageNameActive
{
    return @"Start_Next_Active.png";
}
+ (NSString *)rightImageNameInactive
{
    return @"Start_Next_Inactive.png";
}
+ (NSString *)leftImageNameActive
{
    return @"Start_Result_Active.png";
}
+ (NSString *)leftImageNameInactive
{
    return @"Start_Result_Inactive.png";
}

//override to change behavior when button is pressed
//calls the delegate to tell that the evaluate button has been pressed
- (void)triggerStepButtonPressed
{
    if ([self.delegate conformsToProtocol:@protocol(ResultViewDelegate) ]) {
        [self.delegate showResultsButtonPressed];
    }
}


@end

//
//  MainMenuStepSubview.m
//  SmartSource
//
//  Created by Lorenz on 16.12.13.
//
//

#import "MainMenuStepSubview.h"
#import "UIColor+SmartSourceColors.h"


@interface MainMenuStepSubview ()
@property (nonatomic) BOOL keepSpinning;
@end

@implementation MainMenuStepSubview
@synthesize rightImageBackGroundView = _rightImageBackGroundView;
@synthesize rightImageView = _rightImageView;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize triggerStepButton = _triggerStepButton;
@synthesize leftImageView = _leftImageView;
@synthesize rightImageBottomView = _rightImageBottomView;
@synthesize keepSpinning = _keepSpinning;
@synthesize delegate = _delegate;


#pragma mark Customization Methods

/*
 *  customization methods to be overriden by subclasses
 *  modification of text description labels and icons
 *
 */

+ (NSString *)textDescriptionLabelActive
{
    return @"";
    
}
+ (NSString *)textDescriptionLabelInactive
{
    return @"";
}
+ (NSString *)rightImageNameActive
{
    return @"";
}
+ (NSString *)rightImageNameInactive
{
    return @"";
}
+ (NSString *)leftImageNameActive
{
    return @"";
}
+ (NSString *)leftImageNameInactive
{
    return @"";
}

//calls the delegate to tell that the evaluate button has been pressed
- (void)triggerStepButtonPressed
{
    // to be customized in subclass
}

#pragma mark UI (de-)activation

//method that activates view for evaluation
- (void)setActive
{
    //appear activated
    [self.descriptionLabel setText:[self.class textDescriptionLabelActive]];
    [self setBackgroundColor:[UIColor colorOrange]];
    [self.rightImageBackGroundView setBackgroundColor:[UIColor colorLightOrange]];
    //images
    NSString *imgNameTmp = @"";
    if (![(imgNameTmp = [self.class rightImageNameActive]) isEqualToString:@""]) {
        [self.rightImageView setImage:[UIImage imageNamed:imgNameTmp]];
    }
    if (![(imgNameTmp = [self.class leftImageNameActive]) isEqualToString:@""]) {
        [self.leftImageView setImage:[UIImage imageNamed:imgNameTmp]];
    }
    [self.rightImageBottomView setHidden:NO];
    [self.triggerStepButton setUserInteractionEnabled:YES];
    
    //add target to evaluation button
    [self.triggerStepButton addTarget:self action:@selector(triggerStepButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.triggerStepButton setViewToChangeIfSelected:self.rightImageBackGroundView];
    [self.triggerStepButton setColorToUseIfSelected:[UIColor colorWithRed:0.98 green:0.7 blue:0.25 alpha:1.0]];
    [self bringSubviewToFront:self.triggerStepButton];
}

//method that deactivates view for evaluation
- (void)setDeactive
{
    //appear deactivated
    NSString *message = [self.class textDescriptionLabelInactive];
    [self.descriptionLabel setText:message];
    [self.descriptionLabel sizeToFit];
    [self setBackgroundColor:[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0]];
    [self.rightImageBackGroundView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    //images
    NSString *imgNameTmp = @"";
    if (![(imgNameTmp = [self.class rightImageNameInactive]) isEqualToString:@""]) {
        [self.rightImageView setImage:[UIImage imageNamed:imgNameTmp]];
    }
    if (![(imgNameTmp = [self.class leftImageNameInactive]) isEqualToString:@""]) {
        [self.leftImageView setImage:[UIImage imageNamed:imgNameTmp]];
    }
    [self.rightImageBottomView setHidden:YES];
    [self.triggerStepButton setUserInteractionEnabled:NO];
    
    //remove target
    [self.triggerStepButton removeTarget:self action:@selector(triggerStepButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setEmpty
{
    [self setDeactive];
    [self.descriptionLabel setText:@""];
}

#pragma mark Button (de-)activation


//deactivate view for user interaction
- (void)deactivateUserInteraction
{
    [self.triggerStepButton setUserInteractionEnabled:NO];
}

//activate view for user interaction
- (void)reactivateUserInteraction
{
    [self.triggerStepButton setUserInteractionEnabled:YES];
}


#pragma mark Activity Indicators

//starts spinning of left image view as a custom activity indicator
- (void)startActivityIndicator
{
    [self startSpin];
}

//stops cusom activity indicator
- (void)stopActivityIndicator
{
    [self stopSpin];
}

//spins left image view by the passed ancle
#define M_PI   3.14159265358979323846264338327950288   /* pi */
- (void)spinWithOptions:(UIViewAnimationOptions)options toAnkle:(CGFloat)ankle {
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

//start spinning
- (void) startSpin {
    if (!self.keepSpinning) {
        self.keepSpinning = YES;
        CGFloat ankle = (M_PI/2);
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn toAnkle:ankle];
    }
}

//stop spinnging
- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.keepSpinning = NO;
}

@end

//
//  ResultView.m
//  SmartSource
//
//  Created by Lorenz on 12.08.13.
//
//

#import "ResultView.h"

@interface ResultView ()

@property (nonatomic) BOOL keepSpinning;

@end

@implementation ResultView
@synthesize delegate = _delegate;
@synthesize rightImageBackGroundView = _rightImageBackGroundView;
@synthesize rightImageView = _rightImageView;
@synthesize leftImageView = _leftImageView;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize  showResultsButton = _showResultsButton;
@synthesize rightImageBottomView = _rightImageBottomView;
@synthesize keepSpinning = _keepSpinning;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//method that activates view for evaluation
- (void)setActiveToShowResults
{
    //appear activated
    [self.descriptionLabel setText:@"Evaluation is complete. You can now view the Results."];
    [self.descriptionLabel sizeToFit];
    [self setBackgroundColor:[UIColor colorWithRed:1.0 green:0.54 blue:0.0 alpha:1.0]];
    [self.rightImageBackGroundView setBackgroundColor:[UIColor colorWithRed:0.99 green:0.80 blue:0.55 alpha:1.0]];
    [self.rightImageView setImage:[UIImage imageNamed:@"Start_Next_Active.png"]];
    [self.leftImageView setImage:[UIImage imageNamed:@"Start_Result_Active.png"]];
    [self.rightImageBottomView setHidden:NO];
    
    
    //add target to evaluation button
    [self.showResultsButton setUserInteractionEnabled:YES];
    [self.showResultsButton addTarget:self action:@selector(showResultsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.showResultsButton setViewToChangeIfSelected:self.rightImageBackGroundView];
    [self.showResultsButton setColorToUseIfSelected:[UIColor colorWithRed:0.98 green:0.7 blue:0.25 alpha:1.0]];
    [self bringSubviewToFront:self.showResultsButton];
    
    
}


- (void)setDeactiveToShowResults
{
    
    //appear deactivated
    NSString *message = @"Please evaluate all components in order to see the results.";
    [self.descriptionLabel setText:message];
    [self.descriptionLabel sizeToFit];
    [self setBackgroundColor:[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0]];
    [self.rightImageBackGroundView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    [self.rightImageView setImage:[UIImage imageNamed:@"Start_Next_Inactive.png"]];
    [self.leftImageView setImage:[UIImage imageNamed:@"Start_Result_Inactive.png"]];
    [self.rightImageBottomView setHidden:YES];
    
    
    //remove target
    [self.showResultsButton setUserInteractionEnabled:NO];
    [self.showResultsButton removeTarget:self action:@selector(showResultsButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    
    
}


- (void)startActivityIndicator
{
    [self setDeactiveToShowResults];
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
    [self.showResultsButton setUserInteractionEnabled:NO];
}


//activate view for user interaction
- (void)reactivateUserInteraction
{
    [self.showResultsButton setUserInteractionEnabled:YES];
}


//if results button has been pressed, tell delegate
- (void)showResultsButtonPressed
{
    [self.delegate showResultsButtonPressed];
}

- (void)setEmpty
{
    [self setDeactiveToShowResults];
    [self.descriptionLabel setText:@""];
}

@end

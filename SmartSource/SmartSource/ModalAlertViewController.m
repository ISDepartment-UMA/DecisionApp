//
//  ModalAlertViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import "ModalAlertViewController.h"

@interface ModalAlertViewController ()
@property (strong, nonatomic) IBOutlet UIButton *acknowledgeButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *alertView;

@property (strong, nonatomic) NSString *stringForTitleLabel;
@property (strong, nonatomic) NSString *stringForTextLabel;
@property (strong, nonatomic) NSString *stringForacknowledgeButton;
@property (strong, nonatomic) NSString *stringForcancelButton;

@property (nonatomic) CGRect realBounds;
@property (nonatomic) id<ModalAlertViewControllerDelegate> delegate;
@property (nonatomic) BOOL acknowledgeButtonPressed;
@end

@implementation ModalAlertViewController
@synthesize acknowledgeButton = _acknowledgeButton;
@synthesize cancelButton = _cancelButton;
@synthesize textLabel = _textLabel;
@synthesize titleLabel = _titleLabel;
@synthesize alertView = _alertView;
@synthesize stringForTitleLabel = _stringForTitleLabel;
@synthesize stringForTextLabel = _stringForTextLabel;
@synthesize stringForacknowledgeButton = _stringForacknowledgeButton;
@synthesize stringForcancelButton = _stringForcancelButton;
@synthesize realBounds = _realBounds;
@synthesize delegate = _delegate;
@synthesize acknowledgeButtonPressed = _acknowledgeButtonPressed;


#pragma mark getters & setters

- (void)setDelegate:(id<ModalAlertViewControllerDelegate>)delegate
{
    _delegate = delegate;
}


#pragma mark Inherited Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
	// show only necessary view, make everything else transparent
    self.view.frame = CGRectMake(0, 0, self.alertView.frame.size.width, self.alertView.frame.size.height);
    self.alertView.frame = CGRectMake(0, 0, self.alertView.frame.size.width, self.alertView.frame.size.height);
    self.realBounds = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //check size of text
    CGSize size = [self.stringForTextLabel sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(self.textLabel.frame.size.width, CGFLOAT_MAX)];
    if (size.height > self.textLabel.frame.size.height) {
        CGFloat difference = size.height - self.textLabel.frame.size.height;
        CGRect frameOfTextLabel = self.textLabel.frame;
        [self.textLabel setFrame:CGRectMake(frameOfTextLabel.origin.x, frameOfTextLabel.origin.y, frameOfTextLabel.size.width, size.height)];
        CGRect frameOfCancelButton = self.cancelButton.frame;
        [self.cancelButton setFrame:CGRectMake(frameOfCancelButton.origin.x, (frameOfCancelButton.origin.y + difference), frameOfCancelButton.size.width, frameOfCancelButton.size.height)];
        CGRect frameOfAckButton = self.acknowledgeButton.frame;
        [self.acknowledgeButton setFrame:CGRectMake(frameOfAckButton.origin.x, (frameOfAckButton.origin.y + difference), frameOfAckButton.size.width, frameOfAckButton.size.height)];
        CGRect mainFrame = self.view.frame;
        [self.view setFrame:CGRectMake(mainFrame.origin.x, mainFrame.origin.y, mainFrame.size.width, (mainFrame.size.height + difference))];
        [self.alertView setFrame:self.view.frame];
    }
    
    // show only necessary view, make everything else transparent
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
    //fill label and textfield
    [self.titleLabel setText:self.stringForTitleLabel];
    [self.textLabel setText:self.stringForTextLabel];
    if (self.stringForcancelButton) {
        [self.cancelButton setTitle:self.stringForcancelButton forState:UIControlStateNormal];
    }
    if (self.stringForacknowledgeButton) {
        [self.acknowledgeButton setTitle:self.stringForacknowledgeButton forState:UIControlStateNormal];
    }

}

- (void)viewDidUnload {
    [self setAcknowledgeButton:nil];
    [self setCancelButton:nil];
    [self setTextLabel:nil];
    [self setTitleLabel:nil];
    [self setAlertView:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.acknowledgeButtonPressed) {
        [self.delegate modalViewControllerHasBeenDismissedWithInput:nil];
    }
}


#pragma mark Button pressed

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)acknowledgeButtonPressed:(id)sender {
    
    self.acknowledgeButtonPressed = YES;
    [self dismissModalViewControllerAnimated:YES];
}

@end

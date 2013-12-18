//
//  ReportUploadViewController.m
//  SmartSource
//
//  Created by Lorenz on 30.10.13.
//
//

#import "ReportUploadViewController.h"

@interface ReportUploadViewController ()
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView *uploadView;
@property (nonatomic) CGRect realBounds;
@end

@implementation ReportUploadViewController
@synthesize statusLabel = _statusLabel;
@synthesize activityIndicator = _activityIndicator;
@synthesize cancelButton = _cancelButton;
@synthesize uploadView = _uploadView;
@synthesize realBounds = _realBounds;
@synthesize ableToRespond = _ableToRespond;



#pragma mark Inherited Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// show only necessary view, make everything else transparent
    self.view.frame = CGRectMake(50, self.uploadView.frame.origin.y, self.uploadView.frame.size.width, self.uploadView.frame.size.height);
    self.uploadView.frame = CGRectMake(0, 0, self.uploadView.frame.size.width, self.uploadView.frame.size.height);
    self.realBounds = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // show only necessary view, make everything else transparent
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
    self.ableToRespond = YES;
}

- (void)viewDidUnload {
    [self setStatusLabel:nil];
    [self setActivityIndicator:nil];
    [self setCancelButton:nil];
    [self setUploadView:nil];
    [super viewDidUnload];
}

#pragma mark IBActions

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UploadCompleteHandler

- (void)uploadComplete
{
    [self.statusLabel setText:@"Upload complete."];
    [self.activityIndicator setHidden:YES];
    [self.cancelButton setTitle:@"OK" forState:UIControlStateNormal];
}

- (void)uploadFailed
{
    [self.statusLabel setText:@"Upload failed."];
    [self.activityIndicator setHidden:YES];
    [self.cancelButton setTitle:@"OK" forState:UIControlStateNormal];
}

@end

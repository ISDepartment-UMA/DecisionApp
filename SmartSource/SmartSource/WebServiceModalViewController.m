//
//  WebServiceModalViewController.m
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import "WebServiceModalViewController.h"
#import "WebServiceConnector.h"

@interface WebServiceModalViewController ()

@property (strong, nonatomic) IBOutlet UITextView *urlTextView;
@property (strong, nonatomic) IBOutlet UIView *webServiceView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) CGRect realBounds;
@property (nonatomic) BOOL serverHelloRecieved;

@property (nonatomic, strong) SettingsModel *settingsModel;

@end

@implementation WebServiceModalViewController
@synthesize urlTextView = _urlTextView;
@synthesize webServiceView = _webServiceView;
@synthesize realBounds = _realBounds;
@synthesize activityIndicator = _activityIndicator;
@synthesize statusLabel = _statusLabel;
@synthesize serverHelloRecieved = _serverHelloRecieved;
@synthesize settingsModel = _settingsModel;


#pragma mark Inherited Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// show only necessary view, make everything else transparent
    self.view.frame = CGRectMake(0, 0, self.webServiceView.frame.size.width, self.webServiceView.frame.size.height);
    self.webServiceView.frame = CGRectMake(0, 0, self.webServiceView.frame.size.width, self.webServiceView.frame.size.height);
    self.realBounds = self.view.bounds;
    //fill view with data from defaults
    self.urlTextView.text = [SettingsModel getWebServiceUrl];
    [self.activityIndicator setHidden:YES];
    //delegate
    [self.urlTextView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // show only necessary view, make everything else transparent
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload {
    [self setUrlTextView:nil];
    [self setWebServiceView:nil];
    [self setActivityIndicator:nil];
    [self setStatusLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.urlTextView becomeFirstResponder];
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self saveButtonPressed:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark Button Pressed
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    
    //activity indicator
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    //login Data from Input
    NSString *javaWebServiceUrl = self.urlTextView.text;
    //start check thread
    NSThread *checkDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkConnectionToWebServer:) object:javaWebServiceUrl];
    [checkDataThread start];
    //wait for thread to finish
    while (!checkDataThread.isFinished) {
        // do nothing
    }
    //in case of success, close popup
    if (self.serverHelloRecieved) {
        //save new url
        [SettingsModel setWebServiceUrl:javaWebServiceUrl];
        //make modal view controller disappear
        [self performSelector:@selector(disappear) withObject:nil afterDelay:2.0f];
    }
    //activity indicator
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}

- (void)disappear
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Error Handling


- (void)checkConnectionToWebServer:(NSString *)javaWebServiceUrl
{
    //check connection
    self.serverHelloRecieved = [SettingsModel checkConnectionToWebServer:javaWebServiceUrl];
    if (self.serverHelloRecieved) {
        [self.statusLabel setText:@"Connection to Java Web Service established"];
    } else {
        [self.statusLabel setText:@"Connection failed"];
    }
    
}

@end

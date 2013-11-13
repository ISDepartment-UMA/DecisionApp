//
//  LoginDataModalViewController.m
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import "LoginDataModalViewController.h"
#import "WebServiceConnector.h"

@interface LoginDataModalViewController ()
@property (strong, nonatomic) IBOutlet UITextView *urlTextView;
@property (strong, nonatomic) IBOutlet UITextField *userTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) CGRect realBounds;
@property (nonatomic) BOOL loginSuccess;

@property (nonatomic, strong) SettingsModel *settingsModel;

@end

@implementation LoginDataModalViewController
@synthesize urlTextView = _urlTextView;
@synthesize userTextField = _userTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize realBounds = _realBounds;
@synthesize loginView = _loginView;
@synthesize activityIndicator = _activityIndicator;
@synthesize statusLabel = _statusLabel;
@synthesize loginSuccess = _loginSuccess;
@synthesize settingsModel = _settingsModel;




#pragma mark Inherited Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, self.loginView.frame.size.width, self.loginView.frame.size.height);
    self.loginView.frame = CGRectMake(0, 0, self.loginView.frame.size.width, self.loginView.frame.size.height);
    self.realBounds = self.view.bounds;
	//put login data from NSUser defaults into view
    NSArray *loginData = [SettingsModel getLoginData];
    self.urlTextView.text = [loginData objectAtIndex:0];
    self.userTextField.text = [loginData objectAtIndex:1];
    self.passwordTextField.text = [loginData objectAtIndex:2];
    [self.activityIndicator setHidden:YES];
    
    //textfield and -view delegate
    [self.urlTextView setDelegate:self];
    [self.userTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //show keyboard to edit url in the beginning
    [self.urlTextView becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setUrlTextView:nil];
    [self setUserTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginView:nil];
    [self setActivityIndicator:nil];
    [self setStatusLabel:nil];
    [super viewDidUnload];
}

#pragma mark TextFieldDelegate


#pragma mark Button Pressed

- (IBAction)saveButtonPressed:(id)sender {
    
    //activity indicator
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    //login Data from Input
    NSString *serviceUrl = self.urlTextView.text;
    NSString *login = self.userTextField.text;
    NSString *password = self.passwordTextField.text;
    NSArray *loginData = [NSArray arrayWithObjects:serviceUrl, login, password, nil];
    //start check thread
    NSThread *checkDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkLoginData:) object:loginData];
    [checkDataThread start];
    //wait for thread to finish
    while (!checkDataThread.isFinished) {
        // do nothing
    }
    //in case of success, close popup
    if (self.loginSuccess) {
        //save new login data
        [SettingsModel setLoginData:loginData];
        //make modal view controller disappear
        [self performSelector:@selector(disappear) withObject:nil afterDelay:2.0f];
    }
    //activity indicator
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}


- (IBAction)cancelButtonPressed:(id)sender {

    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)disappear
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //jump from url textview to usertextfield with return
    if([text isEqualToString:@"\n"]) {
        [self.userTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //jump from usertextfield to passwordtextfield with return and save with another return 
    if ([self.userTextField isFirstResponder]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self saveButtonPressed:nil];
    }
    return YES;
}


#pragma mark Error Handling


- (void)checkLoginData:(NSArray *)loginData
{    
    //check loginData
    NSString *response = [SettingsModel checkLoginData:loginData];
    
    //set label and return 
    if ([response isEqualToString:@"error"]) {
        [self.statusLabel setText:@"Problem connecting to Code Beamer Instance."];
    } else if ([response isEqualToString:@"wrongLogin"]) {
        [self.statusLabel setText:@"Wrong Login or Password"];
    } else if ([response isEqualToString:@"wrongCodeBeamerUrl"]) {
        [self.statusLabel setText:@"Problem connecting to Code Beamer Instance."];
    } else if ([response isEqualToString:@"timeoutError"]) {
        [self.statusLabel setText:@"Could not reach Java Webservice!"];
    } else if ([response isEqualToString:@"success"]) {
        [self.statusLabel setText:@"Connected to Codebeamer successfully."];
        self.loginSuccess = YES;
    }
}

         
        

@end

//
//  LoginDataModalViewController.m
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import "LoginDataModalViewController.h"

@interface LoginDataModalViewController ()
@property (strong, nonatomic) IBOutlet UITextView *urlTextView;
@property (strong, nonatomic) IBOutlet UITextField *userTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (nonatomic) CGRect realBounds;

@end

@implementation LoginDataModalViewController
@synthesize urlTextView = _urlTextView;
@synthesize userTextField = _userTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize realBounds = _realBounds;
@synthesize loginView = _loginView;




#pragma mark Inherited Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, self.loginView.frame.size.width, self.loginView.frame.size.height);
    self.loginView.frame = CGRectMake(0, 0, self.loginView.frame.size.width, self.loginView.frame.size.height);
    self.realBounds = self.view.bounds;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload {
    [self setUrlTextView:nil];
    [self setUserTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginView:nil];
    [super viewDidUnload];
}

#pragma mark Button Pressed

- (IBAction)saveButtonPressed:(id)sender {
}


- (IBAction)cancelButtonPressed:(id)sender {

    [self dismissModalViewControllerAnimated:YES];
    
}

@end

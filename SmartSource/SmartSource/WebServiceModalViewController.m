//
//  WebServiceModalViewController.m
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import "WebServiceModalViewController.h"

@interface WebServiceModalViewController ()

@property (strong, nonatomic) IBOutlet UITextView *urlTextView;
@property (strong, nonatomic) IBOutlet UIView *webServiceView;
@property (nonatomic) CGRect realBounds;

@end

@implementation WebServiceModalViewController
@synthesize urlTextView = _urlTextView;
@synthesize webServiceView = _webServiceView;
@synthesize realBounds = _realBounds;


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
    self.view.frame = CGRectMake(0, 0, self.webServiceView.frame.size.width, self.webServiceView.frame.size.height);
    self.webServiceView.frame = CGRectMake(0, 0, self.webServiceView.frame.size.width, self.webServiceView.frame.size.height);
    self.realBounds = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload {
    [self setUrlTextView:nil];
    [self setWebServiceView:nil];
    [super viewDidUnload];
}


#pragma mark Button Pressed
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)saveButtonPressed:(id)sender {
}

@end

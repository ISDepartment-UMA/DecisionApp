//
//  ModalViewPresenterViewController.m
//  SmartSource
//
//  Created by Lorenz on 28.08.13.
//
//

#import "ModalViewPresenterViewController.h"


@interface ModalViewPresenterViewController ()

@property (strong, nonatomic) IBOutlet UIView *doneView;
@property (strong, nonatomic) IBOutlet UIView *abortView;
@property (nonatomic) CGRect realBounds;
@end


@implementation ModalViewPresenterViewController
@synthesize realBounds = _realBounds;
@synthesize viewToPresent = _viewToPresent;
@synthesize doneView = _doneView;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)doneButtonPressed:(id)sender {
    NSString *input = @"";
    
    if ([[self.viewToPresent class] isSubclassOfClass:[UITextField class]]) {
        input = ((UITextField *)self.viewToPresent).text;
    } else if ([[self.viewToPresent class] isSubclassOfClass:[UITextView class]]) {
        input = ((UITextView *)self.viewToPresent).text;
    }
    [self.delegate modalViewControllerDismissedWithInput:input];
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)abortButtonPressed:(id)sender {
    
    [self.delegate modalViewControllerDismissedWithInput:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.viewToPresent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewToPresent becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, (self.viewToPresent.frame.size.width  + self.doneView.frame.size.width + self.abortView.frame.size.width), self.viewToPresent.frame.size.height);
    self.abortView.frame = CGRectMake(0, 0, self.abortView.frame.size.width, self.viewToPresent.frame.size.height);
    self.viewToPresent.frame = CGRectMake(self.abortView.frame.size.width, 0, self.viewToPresent.frame.size.width, self.viewToPresent.frame.size.height);
    self.doneView.frame = CGRectMake((self.view.frame.size.width - self.doneView.frame.size.width), 0, self.doneView.frame.size.width, self.view.frame.size.height);
    self.realBounds = self.view.bounds;
    
    if ([[self.viewToPresent class] isSubclassOfClass:[UITextField class]]) {
        [((UITextField *)self.viewToPresent) setDelegate:self];
    } else if ([[self.viewToPresent class] isSubclassOfClass:[UITextView class]]) {
        [((UITextView *)self.viewToPresent) setDelegate:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //Terminate editing
    [textField resignFirstResponder];
    [self doneButtonPressed:nil];
    return YES;
    
}




- (void)viewDidUnload {
    [self setDoneView:nil];
    [self setAbortView:nil];
    [super viewDidUnload];
}
@end

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
@synthesize appendAbortAndEnterButton = _appendAbortAndEnterButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)doneButtonPressed:(id)sender {

    [self.delegate modalViewControllerDismissedWithView:self.viewToPresent];
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)abortButtonPressed:(id)sender {
    
    [self.delegate modalViewControllerDismissedWithView:nil];
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
    if ([[self.viewToPresent class] isSubclassOfClass:[UITextField class]] || [[self.viewToPresent class] isSubclassOfClass:[UITextView class]]) {
        [self.viewToPresent becomeFirstResponder];
    } else {
        UIView *contentView = [self.viewToPresent.subviews lastObject];
        for (UIView *subview in contentView.subviews) {
            if (subview.tag == 22) {
                [((UIButton *)subview) addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            } else if (subview.tag == 23) {
                [((UIButton *)subview) addTarget:self action:@selector(abortButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [subview becomeFirstResponder];
            }
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.appendAbortAndEnterButton) {
        self.view.frame = CGRectMake(0, 0, (self.viewToPresent.frame.size.width  + self.doneView.frame.size.width + self.abortView.frame.size.width), self.viewToPresent.frame.size.height);
        self.abortView.frame = CGRectMake(0, 0, self.abortView.frame.size.width, self.viewToPresent.frame.size.height);
        self.viewToPresent.frame = CGRectMake(self.abortView.frame.size.width, 0, self.viewToPresent.frame.size.width, self.viewToPresent.frame.size.height);
        self.doneView.frame = CGRectMake((self.view.frame.size.width - self.doneView.frame.size.width), 0, self.doneView.frame.size.width, self.view.frame.size.height);
        self.realBounds = self.view.bounds;
    } else {
        self.view.frame = CGRectMake(0, 0, self.viewToPresent.frame.size.width, self.viewToPresent.frame.size.height);
        [self.abortView removeFromSuperview];
        self.viewToPresent.frame = CGRectMake(0, 0, self.viewToPresent.frame.size.width, self.viewToPresent.frame.size.height);
        [self.doneView removeFromSuperview];
        self.realBounds = self.view.bounds;
        
    }
    
    
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

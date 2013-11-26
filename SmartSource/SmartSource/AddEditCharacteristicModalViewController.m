//
//  AddCharacteristicModalViewController.m
//  SmartSource
//
//  Created by Lorenz on 20.10.13.
//
//

#import "AddEditCharacteristicModalViewController.h"


@interface AddEditCharacteristicModalViewController ()
@property (strong, nonatomic) IBOutlet UIView *addCharacteristicView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *characteristicNameTextField;
@property (nonatomic) CGRect realBounds;

@property (nonatomic, strong) NSString *stringForTitleLabel;
@property (nonatomic, strong) NSString *stringForTextField;

//delegate
@property (nonatomic, strong) SettingsViewController *delegate;

@end

@implementation AddEditCharacteristicModalViewController
@synthesize addCharacteristicView = _addCharacteristicView;
@synthesize realBounds = _realBounds;
@synthesize titleLabel = _titleLabel;
@synthesize characteristicNameTextField = _characteristicNameTextField;
@synthesize stringForTitleLabel = _stringForTitleLabel;
@synthesize delegate = _delegate;


#pragma mark getters & setters

- (void)setSettingsDelegate:(SettingsViewController *)delegate
{
    self.delegate = delegate;
}

#pragma mark Inherited Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// show only necessary view, make everything else transparent
    self.view.frame = CGRectMake(50, self.addCharacteristicView.frame.origin.y, self.addCharacteristicView.frame.size.width, self.addCharacteristicView.frame.size.height);
    self.addCharacteristicView.frame = CGRectMake(0, 0, self.addCharacteristicView.frame.size.width, self.addCharacteristicView.frame.size.height);
    self.realBounds = self.view.bounds;
    //textfielddelegate
    [self.characteristicNameTextField setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // show only necessary view, make everything else transparent
    self.view.superview.bounds = self.realBounds;
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
    //fill label and textfield
    [self.titleLabel setText:self.stringForTitleLabel];
    [self.characteristicNameTextField setText:self.stringForTextField];
}

- (void)viewDidUnload {
    [self setAddCharacteristicView:nil];
    [self setTitleLabel:nil];
    [self setCharacteristicNameTextField:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.characteristicNameTextField becomeFirstResponder];
}

#pragma mark Button pressed


- (IBAction)saveButtonPressed:(id)sender {
    
    [self.delegate modalViewControllerHasBeenDismissedWithInput:self.characteristicNameTextField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//makes the modal view controller disappear
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self saveButtonPressed:nil];
    return YES;
}

#pragma mark other Methods



@end
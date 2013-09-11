//
//  SettingsViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.08.13.
//
//

#import "SettingsViewController.h"
#import "SmartSourceAppDelegate.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "AlertView.h"
#import "ModalViewPresenterViewController.h"

@interface SettingsViewController ()

//collaboration platform
@property (strong, nonatomic) IBOutlet UIView *collaborationPlaformSubview;
@property (strong, nonatomic) IBOutlet UITextView *collaborationURLTextView;
@property (strong, nonatomic) IBOutlet UITextField *collaborationUserTextField;
@property (strong, nonatomic) IBOutlet UITextField *collaborationPasswordTextField;

//webservice
@property (strong, nonatomic) IBOutlet UIView *webServiceSubview;
@property (strong, nonatomic) IBOutlet UITextView *webServiceURLTextView;

//characteristics
@property (strong, nonatomic) IBOutlet UIView *characteristicsSubView;
@property (strong, nonatomic) IBOutlet UITableView *characteristicsTableView;
@property (strong, nonatomic) UIView *addSuperCharacteristicView;
@property (strong, nonatomic) IBOutlet UIButton *addSuperCharacteristicButton;

@property (nonatomic, strong) NSArray *SuperCharacteristics;
@property (nonatomic, strong) NSArray *Characteristics;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIView *selectedTextFieldView;
@property (nonatomic) NSString *nameOfSuperCharacteristicToAddCharacteristic;

@end

@implementation SettingsViewController
@synthesize collaborationPlaformSubview = _collaborationPlaformSubview;
@synthesize webServiceSubview = _webServiceSubview;
@synthesize characteristicsSubView = _characteristicsSubView;
@synthesize characteristicsTableView = _characteristicsTableView;
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize collaborationURLTextView = _collaborationURLTextView;
@synthesize collaborationUserTextField = _collaborationUserTextField;
@synthesize collaborationPasswordTextField = _collaborationPasswordTextField;
@synthesize webServiceURLTextView = _webServiceURLTextView;
@synthesize addSuperCharacteristicView = _addSuperCharacteristicView;
@synthesize addSuperCharacteristicButton = _addSuperCharacteristicButton;
@synthesize mainMenu = _mainMenu;
@synthesize selectedTextFieldView = _selectedTextFieldView;
@synthesize nameOfSuperCharacteristicToAddCharacteristic = _nameOfSuperCharacteristicToAddCharacteristic;




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
    
    
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //delegate
    [self.characteristicsTableView setDelegate:self];
    [self.characteristicsTableView setDataSource:self];
    [self.collaborationUserTextField setDelegate:self];
    [self.collaborationURLTextView setDelegate:self];
    [self.collaborationPasswordTextField setDelegate:self];
    [self.webServiceURLTextView setDelegate:self];
    
    //rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //if device orientation is portrait, handle it
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self deviceOrientationDidChange:nil];
    }
    
    //getcharacteristics
    [self getRatingCharacteristics];
    [self setTextFieldsFromUserDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restoreDefaultsPressed:(id)sender {
    
    //show allert that will ask for acknoledgement
    NSString *message1 = @"Do you really want to reset the settings to default?";
    NSString *message2 = @"This will delete all ratings and additional rating characteristics stored on the device. The login data will be conserved.";
    NSString *message = [NSString stringWithFormat:@"%@ \n%@", message1, message2];
    AlertView * alert = [[AlertView alloc] initWithTitle:@"Reset" message:message delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    alert.identifier = @"reset";
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    [alert show];
    
}


//back to main menu
- (IBAction)backToPreviousViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)getRatingCharacteristics
{
    //getting characteristics from core database
    //get all supercharacteristics
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //initialize arrays for super- and subcharacteristics
    NSMutableArray *superchar = [NSMutableArray array];
    NSMutableArray *subchar = [NSMutableArray array];
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //add supercharacteristics name to array
        [superchar addObject:tmpasc.name];
        
        //add all subcharacteristics names to array
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *enumerator = [NSArray arrayWithArray:[tmpasc.availableSuperCharacteristicOf allObjects]];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            [tmp addObject:tmpcharacteristic.name];
            
        }
        [tmp sortUsingSelector:@selector(compare:)];
        [subchar addObject:tmp];
        
        
    }
    
    
    //set arrays
    self.SuperCharacteristics = superchar;
    self.Characteristics = subchar;
    
    
}




- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.selectedTextFieldView = textView;
    [self performSegueWithIdentifier:@"textField" sender:self];
    return YES;
}

- (void)modalViewControllerDismissedWithInput:(NSString *)input
{
    if (!input) {
        return;
    }
    if (self.nameOfSuperCharacteristicToAddCharacteristic) {
        //add characteristic
        
         //do not add characteristic for standard text
         if (![input isEqualToString:@"Enter Name of Characteristic to add..."]) {
             //then insert the new supercharacteristic
             [AvailableCharacteristic addNewAvailableCharacteristic:input toSuperCharacteristic:self.nameOfSuperCharacteristicToAddCharacteristic toManagedObjectContext:self.managedObjectContext];
             //save context
             NSError *error = nil;
             if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
            }
             
            [self getRatingCharacteristics];
            [self.characteristicsTableView reloadData];
             self.nameOfSuperCharacteristicToAddCharacteristic = nil;
             
         } else {
             
             self.nameOfSuperCharacteristicToAddCharacteristic = nil;
         }
        
    } else {
        
        [((UITextField *)self.selectedTextFieldView) setText:input];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //if last character is not /, then append /
        NSString *newServiceURL = self.webServiceURLTextView.text;
        NSString *lastChar = [newServiceURL substringFromIndex:([newServiceURL length]-1)];
        if (![lastChar isEqualToString:@"/"]) {
            newServiceURL = [newServiceURL stringByAppendingString:@"/"];
        }
        [defaults setObject:newServiceURL forKey:@"javaWebserviceConnection"];
        
        
        NSMutableArray *loginData = [[defaults objectForKey:@"loginData"] mutableCopy];
        
        //url from text field
        [loginData replaceObjectAtIndex:0 withObject:self.collaborationURLTextView.text];
        
        //username
        [loginData replaceObjectAtIndex:1 withObject:self.collaborationUserTextField.text];
        //password
        [loginData replaceObjectAtIndex:2 withObject:self.collaborationPasswordTextField.text];
        
        //save data
        [defaults setObject:[loginData copy] forKey:@"loginData"];
        [defaults synchronize];
        
        [self setTextFieldsFromUserDefaults];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextView *)textView {
    if (textView.tag == 35) {
        return YES;
    }
    self.selectedTextFieldView = textView;
    [self performSegueWithIdentifier:@"textField" sender:self];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //to add supercharacteristic
    if (self.addSuperCharacteristicView) {
        [self addSuperCharacteristic:nil];
    }
    //Terminate editing
    [textField resignFirstResponder];
    return YES;
}





- (void)setTextFieldsFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //web service url
    NSString *webServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    [self.webServiceURLTextView setText:webServiceURL];
    
    //user credentials
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *url = [loginData objectAtIndex:0];
    [self.collaborationURLTextView setText:url];
    NSString *username = [loginData objectAtIndex:1];
    [self.collaborationUserTextField setText:username];
    NSString *password = [loginData objectAtIndex:2];
    NSString *dotpassword =@"";
    for (int i=1; i<password.length ; i++) {
        dotpassword = [dotpassword stringByAppendingString:@"●"];
    }
    [self.collaborationPasswordTextField setText:dotpassword];
    
}

//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        
        //projectinfo and component info subviews above evaluationsubview+
        //single values
        CGFloat widthOfInfoViews = ((self.view.frame.size.width - 60) / 2);
        CGFloat heightOfAllViews = ((self.view.frame.size.height-130)/2);
        
        //rects
        CGRect projectInfoRect = CGRectMake(20, 90, widthOfInfoViews, heightOfAllViews);
        CGRect componentInfoRect = CGRectMake((40 + widthOfInfoViews), 90, widthOfInfoViews, heightOfAllViews);
        CGRect componentEvaluationRect = CGRectMake(20, (110 + heightOfAllViews), (self.view.frame.size.width - 40), heightOfAllViews);
        
        [self.collaborationPlaformSubview setFrame:projectInfoRect];
        [self.webServiceSubview setFrame:componentInfoRect];
        [self.characteristicsSubView setFrame:componentEvaluationRect];
        
        //[self.projectDescriptionLabel sizeToFit];
        
    }
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        
        //projectinfo and component info subviews left of evaluationsubview
        //single values
        CGFloat widthOfAllViews = ((self.view.frame.size.width - 60) / 2);
        CGFloat heightOfEvaluationView = (self.view.frame.size.height - 110);
        CGFloat proportionProjectComponentInfo = 0.59;
        CGFloat heightOfProjectInfoView = (heightOfEvaluationView * proportionProjectComponentInfo);
        CGFloat heightOfComponentInfoView = ((heightOfEvaluationView * (1-proportionProjectComponentInfo)) - 20);
        
        
        //rects
        CGRect projectInfoRect = CGRectMake(20, 90, widthOfAllViews, heightOfProjectInfoView);
        CGRect componentInfoRect = CGRectMake(20, (110 + heightOfProjectInfoView), widthOfAllViews, heightOfComponentInfoView);
        CGRect componentEvaluationRect = CGRectMake((40 + widthOfAllViews), 90, widthOfAllViews, heightOfEvaluationView);
        
        [self.collaborationPlaformSubview setFrame:projectInfoRect];
        [self.webServiceSubview setFrame:componentInfoRect];
        [self.characteristicsSubView setFrame:componentEvaluationRect];
        
        //[self.projectDescriptionLabel sizeToFit];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.SuperCharacteristics count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 + [[self.Characteristics objectAtIndex:section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //in the first row of each section add the name of the supercharacteristic
    if (indexPath.row == 0) {
        
        //return cell of supercharacteristic
        //get cell
        static NSString *CellIdentifier = @"superCharacteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //set label
        UIView *contentView = [cell viewWithTag:19];
        UILabel *textLabel = (UILabel *)[contentView viewWithTag:30];
        [textLabel setText:[self.SuperCharacteristics objectAtIndex:indexPath.section]];
        
        
        UIButton *eraseButton = (UIButton *)[contentView viewWithTag:21];
        [eraseButton addTarget:self action:@selector(eraseCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        
        return cell;
        
        //beginning with the second row of each section, show the subcharacteristics
    } else if (indexPath.row <= [[self.Characteristics objectAtIndex:indexPath.section] count]) {
        
        //return cell of subcharacteristic
        //get cell
        static NSString *CellIdentifier = @"CharacteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //add label
        UILabel *textLabel = (UILabel *)[cell viewWithTag:30];
        textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
        
        UIButton *eraseButton = (UIButton *)[cell viewWithTag:31];
        [eraseButton addTarget:self action:@selector(eraseCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"addCharacteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIButton *addButton = (UIButton *)[cell viewWithTag:22];
        [addButton addTarget:self action:@selector(addCharacteristicSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }

    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    } else {
        return 44;
    }
}

//called when erase button is pushed in cell
- (void)eraseCharacteristic:(UIButton *)sender
{
    //get the views
    UIView *superView = (UIView *)sender.superview;
    UITableViewCell *cell = (UITableViewCell *)superView.superview;
    UILabel *textLabel = (UILabel *)[cell viewWithTag:30];
    
    //get index path of cell
    NSIndexPath *indexPath = [self.characteristicsTableView indexPathForCell:cell];
    
    //find out if it's a supercharacteristic or subcharacteristic
    NSString *characteristicType = @"Characteristic?";
    if (indexPath.row == 0) {
        characteristicType = @"Super Characteristic?";
        //for superchar get views again -- different cell structure
        cell = (UITableViewCell *)superView.superview.superview;
        textLabel = (UILabel *)[superView viewWithTag:30];
    }
    
    
    //show allert that will ask for name of new characteristic
    NSString *message = [@"Do you really want to delete this " stringByAppendingString:characteristicType];
    AlertView * alert = [[AlertView alloc] initWithTitle:textLabel.text message:message delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    alert.objectToPass = cell;
    alert.identifier = @"delete";
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    [alert show];
}

- (IBAction)showCellToAddSupercharacteristic:(id)sender {
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"AddSuperCharacteristicView" owner:self options:nil];
    self.addSuperCharacteristicView = [subviewArray objectAtIndex:0];
    
    UIButton *addButton = (UIButton *)[self.addSuperCharacteristicView viewWithTag:22];
    UIButton *abortButton = (UIButton *)[self.addSuperCharacteristicView viewWithTag:23];
    UITextField *textField = (UITextField *)[self.addSuperCharacteristicView viewWithTag:35];
    [textField setDelegate:self];
    [addButton addTarget:self action:@selector(addSuperCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    [abortButton addTarget:self action:@selector(hideViewToAddSuperCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addSuperCharacteristicView setFrame:CGRectMake(0, 0, self.characteristicsSubView.frame.size.width, 60)];
    [self.characteristicsSubView addSubview:self.addSuperCharacteristicView];
    [self.addSuperCharacteristicButton setHidden:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.addSuperCharacteristicView setFrame:CGRectMake(0, 67, self.characteristicsSubView.frame.size.width, 60)];
        [self.characteristicsTableView setFrame:CGRectMake(self.characteristicsTableView.frame.origin.x, (self.characteristicsTableView.frame.origin.y + 60), self.characteristicsTableView.frame.size.width, (self.characteristicsTableView.frame.size.height - 60))];
        
    
    } completion:^(BOOL finished) {
        
        [textField becomeFirstResponder];
        self.addSuperCharacteristicView = self.addSuperCharacteristicView;
        
    }];
    

}


//called when user selects add button of characteristic
- (void)addCharacteristicSelected:(UIButton *)sender
{
    //get views
    UIView *superView = (UIView *)sender.superview;
    UITableViewCell *cell = (UITableViewCell *)superView.superview;
    self.nameOfSuperCharacteristicToAddCharacteristic = [self.SuperCharacteristics objectAtIndex:[self.characteristicsTableView indexPathForCell:cell].section];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"AddCharacteristicTextField" owner:self options:nil];
    self.selectedTextFieldView = [subviewArray objectAtIndex:0];
    [self performSegueWithIdentifier:@"textField" sender:self];
}


- (void)hideViewToAddSuperCharacteristic:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.addSuperCharacteristicView setFrame:CGRectMake(0, 0, self.addSuperCharacteristicView.frame.size.width, self.addSuperCharacteristicView.frame.size.height)];
        [self.characteristicsTableView setFrame:CGRectMake(self.characteristicsTableView.frame.origin.x, (self.characteristicsTableView.frame.origin.y - 60), self.characteristicsTableView.frame.size.width, (self.characteristicsTableView.frame.size.height + 60))];
        
        
    } completion:^(BOOL finished) {
        
        [self.addSuperCharacteristicView removeFromSuperview];
        self.addSuperCharacteristicView = nil;
        [self getRatingCharacteristics];
        [self.characteristicsTableView reloadData];
        [self.addSuperCharacteristicButton setHidden:NO];
        
    }];
}


- (void)addSuperCharacteristic:(UIButton *)sender
{
    UITextField *textField = (UITextField *)[self.addSuperCharacteristicView viewWithTag:35];
    

    if (![textField.text isEqualToString:@"Enter Name of Supercharacteristic to add..."] && ![textField.text isEqualToString:@""]) {
        //then insert the new supercharacteristic
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:textField.text toManagedObjectContext:self.managedObjectContext];
        
        //save context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [self.addSuperCharacteristicView setFrame:CGRectMake(0, 0, self.addSuperCharacteristicView.frame.size.width, self.addSuperCharacteristicView.frame.size.height)];
            [self.characteristicsTableView setFrame:CGRectMake(self.characteristicsTableView.frame.origin.x, (self.characteristicsTableView.frame.origin.y - 60), self.characteristicsTableView.frame.size.width, (self.characteristicsTableView.frame.size.height + 60))];
            
            
        } completion:^(BOOL finished) {
            
            [self.addSuperCharacteristicView removeFromSuperview];
            self.addSuperCharacteristicView = nil;
            [self getRatingCharacteristics];
            [self.characteristicsTableView reloadData];
            [self.addSuperCharacteristicButton setHidden:NO];
            
        }];
    }
}

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if ([alertView.identifier isEqualToString:@"delete"]) {
        
        //if delete button was pressed
        if (buttonIndex == 0) {
            
            UITableViewCell *cell = (UITableViewCell *)alertView.objectToPass;
            NSIndexPath *indexPath = [self.characteristicsTableView indexPathForCell:cell];
            NSFetchRequest *request;
            
            
            //characteristic to delete is supercharacteristic
            if (indexPath.row == 0) {
                request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
            } else {
                request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableCharacteristic"];
            }
            
            //look for
            request.predicate = [NSPredicate predicateWithFormat:@"name =%@", alertView.title];
            NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
            NSError *error = nil;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            //delete characteristic -- if it's a supercharacteristic, cascade will delete all characteristics that belong to it
            [self.managedObjectContext deleteObject:[matches objectAtIndex:0]];
            
            //save context
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self getRatingCharacteristics];
            [self.characteristicsTableView reloadData];
        }
        
        
        
    //restore defaults
    } else if (([alertView.identifier isEqualToString:@"reset"]) && (buttonIndex == 0)) {
        
        
        //getContext
        //get context
        SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        //delete all supercharacteristics
        NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request1.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches1 = [context executeFetchRequest:request1 error:&error];
        
        for (int i=0; i<[matches1 count]; i++) {
            //delete supercharacteristic, cascade will delete all characteristics that belong to it
            [context deleteObject:[matches1 objectAtIndex:i]];
        }
        
        //delete all projects
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
        request2.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSArray *matches2 = [context executeFetchRequest:request2 error:&error];
        
        for (int i=0; i<[matches2 count]; i++) {
            //delete supercharacteristic, cascade will delete all characteristics that belong to it
            [context deleteObject:[matches2 objectAtIndex:i]];
        }
        
        
        
        //insert root rating characteristics
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:context];
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:context];
        
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Software Object Communication" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:context];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication of Requirements" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:context];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication among Developers" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:context];
        
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Business Process Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:context];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Functional Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:context];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Technical Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:context];
        
        
        //save context
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self getRatingCharacteristics];
        [self.characteristicsTableView reloadData];
        [self.mainMenu resetProjectModel];
        
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}


- (void)viewDidUnload {
    
    [self setCollaborationURLTextView:nil];
    [self setCollaborationUserTextField:nil];
    [self setCollaborationPasswordTextField:nil];
    [self setAddSuperCharacteristicButton:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"textField"]) {
        ModalViewPresenterViewController *modalPresenter = (ModalViewPresenterViewController *)segue.destinationViewController;
        
        UITextView *sle = (UITextView *)[self.selectedTextFieldView copy];
        [modalPresenter setViewToPresent:sle];
        [modalPresenter setDelegate:self];
    }
}



@end

//
//  SettingsViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.08.13.
//
//

#import "SettingsViewController.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "AddEditCharacteristicModalViewController.h"
#import "ButtonExternalBackground.h"
#import "SettingsModel.h"
#import "ModalAlertViewController.h"
#import "LoginDataModalViewController.h"
#import "WebServiceModalViewController.h"

@interface SettingsViewController ()

//collaboration platform
@property (strong, nonatomic) IBOutlet UIView *collaborationPlaformSubview;
@property (strong, nonatomic) IBOutlet UITextView *collaborationURLTextView;
@property (strong, nonatomic) IBOutlet UILabel *collaborationUserTextField;
@property (strong, nonatomic) IBOutlet UILabel *collaborationPasswordTextField;
@property (strong, nonatomic) IBOutlet UILabel *editSymbolLabelLogin;

//webservice
@property (strong, nonatomic) IBOutlet UIView *webServiceSubview;
@property (strong, nonatomic) IBOutlet UITextView *webServiceURLTextView;
@property (strong, nonatomic) IBOutlet UILabel *editSymbolLabelWebservice;

//characteristics
@property (strong, nonatomic) IBOutlet UIView *characteristicsSubView;
@property (strong, nonatomic) IBOutlet UITableView *characteristicsTableView;
@property (strong, nonatomic) UIView *addSuperCharacteristicView;
@property (strong, nonatomic) IBOutlet UIButton *addSuperCharacteristicButton;

@property (nonatomic, strong) NSArray *SuperCharacteristics;
@property (nonatomic, strong) NSArray *Characteristics;


@property (strong, nonatomic) SettingsModel *settingsModel;

@property (nonatomic, strong) NSString *nameOfSuperCharacteristicToAddCharacteristic;
@property (nonatomic, strong) NSString *nameOfCharacteristicToChange;
//characteristic state: 1--> add superchar, 2--> add char, 3-->modify superchar, 4-->modify char, 5-->delete superchar, 6-->delete char, 7-->restoredefaults
@property (nonatomic) NSInteger characteristicState;

//buttons
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;
@property (strong, nonatomic) IBOutlet UIButton *addSuperCharButton;

@end
@implementation SettingsViewController
@synthesize collaborationPlaformSubview = _collaborationPlaformSubview;
@synthesize webServiceSubview = _webServiceSubview;
@synthesize characteristicsSubView = _characteristicsSubView;
@synthesize characteristicsTableView = _characteristicsTableView;
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
@synthesize settingsModel = _settingsModel;
@synthesize collaborationURLTextView = _collaborationURLTextView;
@synthesize collaborationUserTextField = _collaborationUserTextField;
@synthesize collaborationPasswordTextField = _collaborationPasswordTextField;
@synthesize webServiceURLTextView = _webServiceURLTextView;
@synthesize addSuperCharacteristicView = _addSuperCharacteristicView;
@synthesize addSuperCharacteristicButton = _addSuperCharacteristicButton;
@synthesize mainMenu = _mainMenu;
@synthesize nameOfSuperCharacteristicToAddCharacteristic = _nameOfSuperCharacteristicToAddCharacteristic;
@synthesize backButton = _backButton;
@synthesize backButtonBackground = _backButtonBackground;
@synthesize addSuperCharButton = _addSuperCharButton;
@synthesize characteristicState = _characteristicState;
@synthesize editSymbolLabelLogin = _editSymbolLabelLogin;
@synthesize editSymbolLabelWebservice = _editSymbolLabelWebservice;



#pragma mark - Inherited Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize settings mdoel
    self.settingsModel = [[SettingsModel alloc] init];
    
    //delegate
    [self.characteristicsTableView setDelegate:self];
    [self.characteristicsTableView setDataSource:self];
    [self.collaborationURLTextView setDelegate:self];
    [self.webServiceURLTextView setDelegate:self];
    
    //back button
    [self.backButton setViewToChangeIfSelected:self.backButtonBackground];
    //set symbol for entypo
    [self.addSuperCharButton setTitle:@"\u2795" forState:UIControlStateSelected];
    [self.addSuperCharButton setTitle:@"\u2795" forState:UIControlStateNormal];
    [self.editSymbolLabelLogin setText:@"\u270E"];
    [self.editSymbolLabelWebservice setText:@"\u270E"];

    //rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //if device orientation is portrait, handle it
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self deviceOrientationDidChange:nil];
    }
    
    //getcharacteristics
    NSArray *ratingCharacteristics = [self.settingsModel getSuperCharacteristicsAndCharacteristics];
    self.SuperCharacteristics = [ratingCharacteristics objectAtIndex:0];
    self.Characteristics = [ratingCharacteristics objectAtIndex:1];
    //put logindata into screen
    [self setTextFieldsFromModel];
}

- (void)viewDidUnload {
    
    [self setCollaborationURLTextView:nil];
    [self setCollaborationUserTextField:nil];
    [self setCollaborationPasswordTextField:nil];
    [self setAddSuperCharacteristicButton:nil];
    [self setBackButton:nil];
    [self setBackButtonBackground:nil];
    [self setEditSymbolLabelLogin:nil];
    [super viewDidUnload];
}


#pragma mark - Buttons Pressed


- (IBAction)restoreDefaultsPressed:(id)sender {
    
    self.characteristicState = 7;
    //show modal alert to ask for acknowledgement
    [self performSegueWithIdentifier:@"modalAlert" sender:self];    
}

- (IBAction)changeLoginDataPressed:(id)sender {
    
    //modal segue to show login screen
    [self performSegueWithIdentifier:@"loginData" sender:self];
    
}


- (IBAction)changeWebServiceUrlPressed:(id)sender {
    
    //modal segue to show web service screen
    [self performSegueWithIdentifier:@"webServiceUrl" sender:self];
}


//back to main menu
- (IBAction)backToPreviousViewController:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Screen Content

- (void)setTextFieldsFromModel
{
    //get data from model
    NSArray *loginData = [SettingsModel getLoginData];
    NSString *javaWebServiceUrl = [SettingsModel getWebServiceUrl];
    
    //set text fields
    //web service
    [self.webServiceURLTextView setText:javaWebServiceUrl];
    //user credentials
    [self.collaborationURLTextView setText:[loginData objectAtIndex:0]];
    [self.collaborationUserTextField setText:[loginData objectAtIndex:1]];
    NSString *password = [loginData objectAtIndex:2];
    NSString *dotpassword =@"";
    for (int i=1; i<password.length ; i++) {
        dotpassword = [dotpassword stringByAppendingString:@"●"];
    }
    [self.collaborationPasswordTextField setText:dotpassword];
}


#pragma mark - Detect Rotation

#define heightOfCollaborationPlatformView 270
#define heightOfWebServiceInfoView 144
#define yOriginOfTopViews 10


//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        
        //projectinfo and component info subviews above evaluationsubview+
        //single values
        CGFloat widthOfCharacteristicsView = self.characteristicsSubView.frame.size.width; //stays the same
        CGFloat heightOfCharacteristicsView = (self.view.frame.size.height - 75 - heightOfCollaborationPlatformView);
        CGFloat widthOfInfoViews = ((self.view.frame.size.width - 60) / 2);
        
        //rects
        CGRect collaborationPlatformRect = CGRectMake(20, yOriginOfTopViews, widthOfInfoViews, heightOfCollaborationPlatformView);
        CGRect webServiceRect = CGRectMake((40 + widthOfInfoViews), yOriginOfTopViews, widthOfInfoViews, heightOfWebServiceInfoView);
        CGRect characteristicsRect = CGRectMake(20, (yOriginOfTopViews + heightOfCollaborationPlatformView + 10), widthOfCharacteristicsView, heightOfCharacteristicsView);
        
        [self.collaborationPlaformSubview setFrame:collaborationPlatformRect];
        [self.webServiceSubview setFrame:webServiceRect];
        [self.characteristicsSubView setFrame:characteristicsRect];
        
        //[self.projectDescriptionLabel sizeToFit];
        
    }
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        
        //projectinfo and component info subviews left of evaluationsubview
        //single values
        CGFloat widthOfAllViews = ((self.view.frame.size.width - 60) / 2);
        CGFloat heightOfCharacteristicsView = (self.view.frame.size.height - 65);
        
        //rects
        CGRect collaborationPlatformRect = CGRectMake(20, yOriginOfTopViews, widthOfAllViews, heightOfCollaborationPlatformView);
        CGRect webServiceRect = CGRectMake(20, (yOriginOfTopViews + heightOfCollaborationPlatformView + 10), widthOfAllViews, heightOfWebServiceInfoView);
        CGRect characteristicsRect = CGRectMake((40 + widthOfAllViews), yOriginOfTopViews, widthOfAllViews, heightOfCharacteristicsView);
        
        [self.collaborationPlaformSubview setFrame:collaborationPlatformRect];
        [self.webServiceSubview setFrame:webServiceRect];
        [self.characteristicsSubView setFrame:characteristicsRect];
        
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
        [eraseButton setTitle:@"\u274C" forState:UIControlStateNormal];
        [eraseButton setTitle:@"\u274C" forState:UIControlStateSelected];

        return cell;
        
        //beginning with the second row of each section, show the subcharacteristics
    } else if (indexPath.row <= [[self.Characteristics objectAtIndex:indexPath.section] count]) {
        
        //return cell of subcharacteristic
        //get cell
        static NSString *CellIdentifier = @"characteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //add label
        UIView *contentView = [cell viewWithTag:19];
        UILabel *textLabel = (UILabel *)[contentView viewWithTag:30];
        textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
        
        UIButton *eraseButton = (UIButton *)[contentView viewWithTag:31];
        [eraseButton addTarget:self action:@selector(eraseCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
        [eraseButton setTitle:@"\u274C" forState:UIControlStateNormal];
        [eraseButton setTitle:@"\u274C" forState:UIControlStateSelected];
        
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"addCharacteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIView *contentView = [cell viewWithTag:19];
        UIButton *addButton = (UIButton *)[contentView viewWithTag:22];
        //set symbol for entypo
        [addButton setTitle:@"\u2795" forState:UIControlStateSelected];
        [addButton setTitle:@"\u2795" forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addCharacteristicSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }

    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 39;
    }
    if (indexPath.row == ([[self.Characteristics objectAtIndex:indexPath.section] count]+1)) {
        return 42;
    } else {
        return 39;
    }
}

#pragma mark - Add and Delete characteristic

//called when user selects add button of characteristic
- (void)addCharacteristicSelected:(UIButton *)sender
{
    //get first superview of sender that is a UITableViewCell
    UITableViewCell *cell;
    UIView *currentView = sender;
    while (YES) {
        if ([currentView isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)currentView;
            break;
        } else {
            currentView = currentView.superview;
        }
    }
    NSIndexPath *indexPath = [self.characteristicsTableView indexPathForCell:cell];
    self.nameOfSuperCharacteristicToAddCharacteristic = [self.SuperCharacteristics objectAtIndex:indexPath.section];
    self.characteristicState = 2;
    // perform modal segue to add characteristic
    [self performSegueWithIdentifier:@"addCharacteristic" sender:self];
}


- (IBAction)addSuperCharacteristicPressed:(UIButton *)sender {
    
    self.characteristicState = 1;
    // perform modal segue to add characteristic
    [self performSegueWithIdentifier:@"addCharacteristic" sender:self];
    
}

//called when erase button is pushed in cell
- (void)eraseCharacteristic:(UIButton *)sender
{
    //get first superview of sender that is a UITableViewCell
    UITableViewCell *cell;
    UIView *currentView = sender;
    while (YES) {
        if ([currentView isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)currentView;
            break;
        } else {
            currentView = currentView.superview;
        }
    }
    UIView *contentView = [cell viewWithTag:19];
    UILabel *textLabel = (UILabel *)[contentView viewWithTag:30];
    //get index path of cell
    NSIndexPath *indexPath = [self.characteristicsTableView indexPathForCell:cell];
    
    self.nameOfCharacteristicToChange = textLabel.text;
    self.characteristicState = 6;
    if (indexPath.row == 0) {
        self.characteristicState = 5;
    }
    //show modal alert view to ask for acknowledgement
    [self performSegueWithIdentifier:@"modalAlert" sender:self];
}


- (IBAction)characteristicCellClicked:(UIButton *)sender {
    //start to edit characteristic
    //get first superview of sender that is a UITableViewCell
    UITableViewCell *cell;
    UIView *currentView = sender;
    while (YES) {
        if ([currentView isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)currentView;
            break;
        } else {
            currentView = currentView.superview;
        }
    }
    //get cell's index path
    NSIndexPath *indexPath = [self.characteristicsTableView indexPathForCell:cell];
    NSString *nameOfCharacteristic = [[self.Characteristics objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
    self.nameOfCharacteristicToChange = nameOfCharacteristic;
    self.characteristicState = 4;
    //perform modal segue to edit characteristic
    [self performSegueWithIdentifier:@"addCharacteristic" sender:self]; 
}

- (IBAction)superCharacteristicCellClicked:(UIButton *)sender {
    //start to edit characteristic
    //get views
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    UIView *contentView = [cell viewWithTag:19];
    UILabel *textLabel = (UILabel *)[contentView viewWithTag:30];
    //get right characteristic
    NSString *nameOfCharacteristic = textLabel.text;
    self.nameOfCharacteristicToChange = nameOfCharacteristic;
    self.characteristicState = 3;
    //perform modal segue
    [self performSegueWithIdentifier:@"addCharacteristic" sender:self];
}

- (void)modalViewControllerHasBeenDismissedWithInput:(NSString *)input
{
    
    switch (self.characteristicState) {
        case 1:
            //add input as new supercharacteristic
            [self.settingsModel addNewSuperCharacteristicWithName:input];
            break;
            
        case 2:
            //add input as new characteristic to selected supercharacteristic
            [self.settingsModel addNewCharacteristicWithName:input toSuperCharacteristicNamed:self.nameOfSuperCharacteristicToAddCharacteristic];
            break;
        case 3:
            //change name of supercharacteristic to input
            [self.settingsModel changeNameOfSuperCharacteristicFrom:self.nameOfCharacteristicToChange to:input];
            break;
        case 4:
            //change name of characteristic to input
            [self.settingsModel changeNameOfCharacteristicFrom:self.nameOfCharacteristicToChange to:input];
            break;
            
        case 5:
            //delete supercharacteristic
            [self.settingsModel deleteSuperCharacteristicNamed:self.nameOfCharacteristicToChange];
            break;
            
        case 6:
            //delete characteristic
            [self.settingsModel deleteCharacteristicNamed:self.nameOfCharacteristicToChange];
            break;
            
        case 7:
            //restore defautls
            [self.settingsModel restoreDefaultSettings];
            [self.mainMenu resetProjectModel];
            break;
            
        default:
            break;
    }
    
    self.nameOfCharacteristicToChange = nil;
    self.nameOfSuperCharacteristicToAddCharacteristic = nil;
    
    //reload characteristics and table view
    NSArray *ratingCharacteristics = [self.settingsModel getSuperCharacteristicsAndCharacteristics];
    self.SuperCharacteristics = [ratingCharacteristics objectAtIndex:0];
    self.Characteristics = [ratingCharacteristics objectAtIndex:1];
    [self.characteristicsTableView reloadData];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"touched cell");
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCharacteristic"]) {
        //pass name of supercharacteristic to modal view controller
        AddEditCharacteristicModalViewController *aCMVC = (AddEditCharacteristicModalViewController *)segue.destinationViewController;
        [aCMVC setSettingsDelegate:self];
        
        switch (self.characteristicState) {
            case 1:
                [aCMVC setStringForTitleLabel:@"Add Supercharacteristic"];
                [aCMVC setStringForTextField:@""];
                break;
            
            case 2:
                [aCMVC setStringForTitleLabel:@"Add Characteristic"];
                [aCMVC setStringForTextField:@""];
                break;
            case 3:
                [aCMVC setStringForTitleLabel:@"Change Supercharacteristic"];
                [aCMVC setStringForTextField:self.nameOfCharacteristicToChange];
                break;
            case 4:
                [aCMVC setStringForTitleLabel:@"Change Characteristic"];
                [aCMVC setStringForTextField:self.nameOfCharacteristicToChange];
                break;
                
            default:
                break;
        }
    } else if ([segue.identifier isEqualToString:@"modalAlert"]) {
        ModalAlertViewController *mAVC = (ModalAlertViewController *)segue.destinationViewController;
        NSLog(@"before");
        [mAVC setDelegate:self];
        NSLog(@"after");
        switch (self.characteristicState) {
            case 5:
                //delete superchar
                [mAVC setStringForacknowledgeButton:@"Delete"];
                [mAVC setStringForTextLabel:@"Are you sure to delete this Supercharacteristic?"];
                [mAVC setStringForTitleLabel:self.nameOfCharacteristicToChange];
                break;
            case 6:
                //delete char
                [mAVC setStringForacknowledgeButton:@"Delete"];
                [mAVC setStringForTextLabel:@"Are you sure to delete this Characteristic?"];
                [mAVC setStringForTitleLabel:self.nameOfCharacteristicToChange];
                break;
            case 7:
                //restore defaults
                [mAVC setStringForacknowledgeButton:@"Restore Defaults"];
                [mAVC setStringForTextLabel:@"The Characteristics will be restored to default and all projects will be deleted. Login data will be retained?"];
                [mAVC setStringForTitleLabel:@"Restore Defaults"];
                break;
                
            default:
                break;
        }
    } else if ([segue.identifier isEqualToString:@"webServiceUrl"]) {
        WebServiceModalViewController *wSMVC = (WebServiceModalViewController *)segue.destinationViewController;
        [wSMVC setSettingsModel:self.settingsModel];
    } else if ([segue.identifier isEqualToString:@"loginData"]) {
        LoginDataModalViewController *lDMVC = (LoginDataModalViewController *)segue.destinationViewController;
        [lDMVC setSettingsModel:self.settingsModel];
    }
}



@end

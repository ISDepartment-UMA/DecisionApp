//
//  MainMenuViewController.m
//  SmartSource
//
//  Created by Lorenz on 01.07.13.
//
//

#import "MainMenuViewController.h"
#import "ProjectPlatformModel.h"
#import "ProjectSelectionViewController.h"
#import "ProjectModel.h"
#import "ResultsOverviewViewController.h"
#import "EvaluationView.h"
#import "ProjectSelectionView.h"
#import "ResultView.h"
#import "DecisionTableViewController.h"
#import "SettingsViewController.h"
#import "ButtonExternalBackground.h"



@interface MainMenuViewController ()

//models
@property (nonatomic, strong) ProjectPlatformModel *platformModel;
@property (nonatomic, strong) ProjectModel *projectModel;

//scroll view
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


//subview for project info
@property (strong, nonatomic) IBOutlet ProjectSelectionView *projectSelectionSubview;
//subview for evaluation
@property (strong, nonatomic) IBOutlet EvaluationView *evaluationView;

//subview for results
@property (strong, nonatomic) IBOutlet ResultView *resultView;


@property (strong, nonatomic) IBOutlet ButtonExternalBackground *settingsButton;
@property (strong, nonatomic) IBOutlet UIView *settingsButtonBackground;
@property (strong, nonatomic) IBOutlet UILabel *settingsLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic) bool downloadingProjectInformation;
@property (nonatomic, strong) NSArray *projectInfo;


@end

@implementation MainMenuViewController
@synthesize platformModel = _platformModel;
@synthesize projectSelectionSubview = _projectSelectionSubview;
@synthesize evaluationView = _evaluationView;
@synthesize resultView = _resultView;
@synthesize projectInfo = _projectInfo;
@synthesize projectModel = _projectModel;
@synthesize scrollView = _scrollView;
@synthesize downloadingProjectInformation = _downloadingProjectInformation;
@synthesize ratingScreen = _ratingScreen;
@synthesize settingsButton = _settingsButton;
@synthesize settingsButtonBackground = _settingsButtonBackground;
@synthesize settingsLabel = _settingsLabel;
@synthesize infoLabel = _infoLabel;



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
    self.platformModel = [[ProjectPlatformModel alloc] init];
    //entypo buttons
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView setDelegate:self];
    [self.settingsLabel setText:@"\u2699"];
    [self.infoLabel setText:@"\u2139"];
    [self.evaluationView setDelegate:self];
    [self.resultView setDelegate:self];
    //external background button
    [self.settingsButton setViewToChangeIfSelected:self.settingsButtonBackground];
    //rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:   @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
}


//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    //get orientation
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];//[[UIDevice currentDevice] orientation];
    
    //show/hide detail project info based on orientation
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        
        //fit view for portrait mode
        [self.projectSelectionSubview fitForPortraitMode];

    } else {
        
        //fit view for landscape mode
        [self.projectSelectionSubview fitForLandscapeMode];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //tell subviews that view did appear so they can start to assign actions to buttons
    [self.projectSelectionSubview addActionsToSubviews];
    
    
    //adjust orientation of screen
    [self deviceOrientationDidChange:nil];
    
    
    //get project model from rating screen and set it as selected project, if it exists
    ProjectModel *model = nil;
    if ((!self.projectModel) && ((model = [self.ratingScreen getProjectModel]) != nil)) {
        
        //set selected project in plaform model
        self.projectInfo = [model getProjectInfoArray];
        NSArray *selectedProject = [NSArray arrayWithObjects:[self.projectInfo objectAtIndex:0],[self.projectInfo objectAtIndex:1], [self.projectInfo objectAtIndex:2] , nil];
        [self.platformModel setSelectedProject:selectedProject];
        
        
        //set project model and build screen
        self.projectModel = model;
        [self selectedProjectMayHaveChanged];
    }
    
}



- (void)resetProjectModel
{
    self.projectModel = nil;
    self.projectInfo = nil;
    self.platformModel = nil;
    self.platformModel = [[ProjectPlatformModel alloc] init];
    [self.ratingScreen setProjectModel:nil];
    
    [self selectedProjectMayHaveChanged];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//public method to be called when the modal view controller for project selection has dismissed itself
//all it does is to call selectedProjectMayHaveChanged
- (void)modalViewControllerHasBeenDismissed
{
    //call method to update screen
    [self selectedProjectMayHaveChanged];
}


//method that consistently updates the screen based on the selected project
//this involves the management of project models
- (void)selectedProjectMayHaveChanged
{
    //deactivate all user interaction
    [NSThread detachNewThreadSelector:@selector(deactivateUserInteraction) toTarget:self withObject:nil];
    
    //put activity indicator
    [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.projectSelectionSubview withObject:nil];
    [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.evaluationView withObject:nil];
    [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.resultView withObject:nil];
    
    //get selected project from project platform model
    NSArray *project = [self.platformModel getSelectedProject];
    
    //if no project selected, deactivate and return
    if (!project) {
        [self.projectSelectionSubview setEmpty];
        [self.evaluationView setEmpty];
        [self.resultView setEmpty];
        
        [self reactivateUserInteraction];
        return;
    }
    
    //project model already exists
    if (self.projectModel) {
        NSLog(@"Model already exists");
        
        //check if model refers to the selected project
        if (![self.projectModel.getProjectID isEqualToString:[project objectAtIndex:0]]) {
            NSLog(@"But is not the right one");
            self.projectInfo = nil;
            //start seperate thread that gets all information about a project from the webservice and builds the project model
            [NSThread detachNewThreadSelector:@selector(initializeProjectModel) toTarget:self withObject:nil];
            
        }
        
    //if project model does not exist
    } else {
        NSLog(@"Model does not exist");
        self.projectInfo = nil;
        //start seperate thread that gets all information about a project from the webservice and builds the project model
        [NSThread detachNewThreadSelector:@selector(initializeProjectModel) toTarget:self withObject:nil];
        
    }
    
    //wait
    while (!self.projectInfo) {
        //do nothing
        NSLog(@"waiting");
    }
    
    
    //update project info in project selection subview
    Project *selectedProject = [self.projectModel getProjectObject];
    [self.projectSelectionSubview setDisplayedProject:selectedProject];

    
    
    
    //if there are components in the project, enable the evaluation button in the main screen
    if ([self.projectModel numberOfComponents] > 0) {
        
        [self.evaluationView setActiveForEvaluation];

        
    } else {
        [self.evaluationView setDeactiveForEvaliation];

    }
    
    
    //if rating is complete, enable button to advance to results
    if ([self.projectModel ratingIsComplete]) {
        [self.resultView setActiveToShowResults];
    } else {
        [self.resultView setDeactiveToShowResults];
    }
    
    
    //remove activity indicator
    [self.projectSelectionSubview stopActivityIndicator];
    [self.evaluationView stopActivityIndicator];
    [self.resultView stopActivityIndicator];
    
    //reactivate all user interaction
    [self reactivateUserInteraction];
}


//deactivate entire view for user interaction
- (void)deactivateUserInteraction
{
    //deactivate the three subviews
    [self.evaluationView deactivateUserInteraction];
    [self.projectSelectionSubview deactivateUserInteraction];
    [self.resultView deactivateUserInteraction];
    [self.settingsButton setUserInteractionEnabled:NO];
    
}

//reactivate entire view for user interaction
- (void)reactivateUserInteraction
{
    
    //reactivate the three subviews
    [self.evaluationView reactivateUserInteraction];
    [self.projectSelectionSubview reactivateUserInteraction];
    [self.resultView reactivateUserInteraction];
    [self.settingsButton setUserInteractionEnabled:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //pass project model
        [self.ratingScreen setProjectModel:self.projectModel];
        
        //disappear
        [self dismissModalViewControllerAnimated:YES];
    } else {
        //deactivate all user interaction
        [NSThread detachNewThreadSelector:@selector(deactivateUserInteraction) toTarget:self withObject:nil];
        //put activity indicator
        [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.projectSelectionSubview withObject:nil];
        [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.evaluationView withObject:nil];
        [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self.resultView withObject:nil];
        //reload project details from collaboration platform
        [NSThread detachNewThreadSelector:@selector(updateSelectedProject) toTarget:self withObject:nil];
        
    }
    
}


- (void)updateSelectedProject
{
    //update characteristics
    self.projectModel = [self.projectModel updateCoreDataBaseForProjectID:[self.projectInfo objectAtIndex:0]];
    //wait for completion
    while (!self.projectModel) {
        //do nothing
    }
    //update screen
    [self selectedProjectMayHaveChanged];
}




//method to be called when evaluation button is pressed
//will make the main menu disappear and show evaluation screen
- (void)evaluationButtonPressed
{
    BOOL availableCharsDeleted = [self.projectModel ratingCharacteristicsHaveBeenDeleted];
    if ([self.projectModel ratingCharacteristicsHaveBeenAdded] || availableCharsDeleted) {
        
        //show alert to ask if new characteristics should be appled
        NSString *message = @"Your Rating Characteristics have been modified since this Project was previously rated. Do you want to apply the new Characteristics?";
        //chars will be deleted
        if (availableCharsDeleted) {
            message = [message stringByAppendingString:@"This will delete characteristics from your rating!"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Characteristics Changed" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        
    } else {
        //pass project model
        [self.ratingScreen setProjectModel:self.projectModel];
        
        //disappear
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

//method to be called when results button is pressed
//will segue to results screen
- (void)showResultsButtonPressed
{
   [self performSegueWithIdentifier:@"results" sender:self];
}




//method to be called to initialize projectmodel
//this downloads all information about a project including its components from the webservice
- (void)initializeProjectModel
{
    //build project Model
    NSArray *project = [self.platformModel getSelectedProject];
    self.projectModel = [[ProjectModel alloc] initWithProjectID:[project objectAtIndex:0]];
    self.projectInfo = [self.projectModel getProjectInfoArray];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"projectSelection"]) {
        ProjectSelectionViewController *projectSelectionVC = (ProjectSelectionViewController *)segue.destinationViewController;
        [projectSelectionVC setPlatformModel:self.platformModel];
        
        
    } else if ([segue.identifier isEqualToString:@"results"]) {
        //do something
        ResultsOverviewViewController *resultsOverViewVC = (ResultsOverviewViewController *)segue.destinationViewController;
        [resultsOverViewVC setProjectModel:self.projectModel];
    } else if ([segue.identifier isEqualToString:@"decisionTable"]) {
        DecisionTableViewController *decTVC = (DecisionTableViewController *)segue.destinationViewController;
        decTVC.projectModel = self.projectModel;
    } else if ([segue.identifier isEqualToString:@"settings"]) {
        SettingsViewController *settingsVC = (SettingsViewController *)segue.destinationViewController;
        [settingsVC setMainMenu:self];
    }
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setEvaluationView:nil];
    [self setProjectSelectionSubview:nil];
    [self setSettingsButton:nil];
    [self setSettingsButton:nil];
    [self setSettingsButtonBackground:nil];
    [self setSettingsLabel:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
}






@end

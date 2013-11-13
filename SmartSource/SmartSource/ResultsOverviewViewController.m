//
//  ResultsOverviewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.07.13.
//
//

#import "ResultsOverviewViewController.h"
#import "ComponentInfoViewController.h"
#import "ResultExplanationViewController.h"
#import "DecisionTableViewController.h"
#import "VeraRomanButton.h"
#import "ButtonExternalBackground.h"
#import "PDFExporter.h"
#import "SmartSourcePopoverController.h"
#import "UploadCompleteHandler.h"

@interface ResultsOverviewViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainSubView;

@property (strong, nonatomic) IBOutlet UIView *subviewLabelCore;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCore;

@property (strong, nonatomic) IBOutlet UIView *subviewLabelOutsourcing;
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutsourcing;


@property (strong, nonatomic) IBOutlet UIView *subviewLabelIndifferent;
@property (strong, nonatomic) IBOutlet UITableView *tableViewIndifferent;


@property (strong, nonatomic) UIPopoverController *popOver;
@property (strong, nonatomic) Component *lastComponentSelected;
@property (nonatomic) BOOL passComponentToDecisionTable;


@property (strong, nonatomic) NSArray *classificationResult;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UITableView *selectedTableView;

@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;


@end

@implementation ResultsOverviewViewController
@synthesize projectModel = _projectModel;
@synthesize classificationResult = _classificationResult;
@synthesize popOver = _popOver;
@synthesize lastComponentSelected = _lastComponentSelected;
@synthesize mainSubView = _mainSubView;
@synthesize subviewLabelCore = _subviewLabelCore;
@synthesize subviewLabelOutsourcing = _subviewLabelOutsourcing;
@synthesize subviewLabelIndifferent = _subviewLabelIndifferent;
@synthesize tableViewCore = _tableViewCore;
@synthesize tableViewOutsourcing = _tableViewOutsourcing;
@synthesize tableViewIndifferent = _tableViewIndifferent;
@synthesize passComponentToDecisionTable = _passComponentToDecisionTable;
@synthesize backButton = _backButton;
@synthesize backButtonBackground = _backButtonBackground;
@synthesize documentController = _documentController;

//new
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize selectedTableView = _selectedTableView;
@synthesize shareButton = _shareButton;



//uses the project model to build a new report and shows it
- (void)buildReportPdfAndShowItUserFriendly:(UIButton *)sender
{
    //check if printer friendly or not
    if ([sender.titleLabel.text isEqualToString:@"Create Report"]) {
        [self.projectModel createReportPdfAndReturnPathPrinterFriendly:NO];
    } else {
        [self.projectModel createReportPdfAndReturnPathPrinterFriendly:YES];
    }
    NSURL *url = [NSURL fileURLWithPath:[self.projectModel getProjectObject].pathReportPdf];
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:url];
    controller.delegate = self;
    [self.popOver dismissPopoverAnimated:NO];
    self.popOver = nil;
    [controller presentPreviewAnimated:YES];
}

//triggers modalWaitingSegue which starts uploadthread
- (void)uploadReport
{
    //dismiss view controller
    [self.popOver dismissPopoverAnimated:YES];
    self.popOver = nil;
    //show waiting popup which will automatically start the upload thread -->prepare for segue
    [self performSegueWithIdentifier:@"modalWaitingScreen" sender:self];
}

/*
 method to be executed in a seperate thread to upload report either creating
 a new one or using a previously created one. Notifies the passed handler once
 upload is complete or upload has failed.
 */
- (void)uploadReportAndNotifyViewController:(id<UploadCompleteHandler>)handler
{
    BOOL reportNecessary = ([self.projectModel getProjectObject].pathReportPdf == nil);
    BOOL success = [self.projectModel uploadPdfToCollaborationPlatformNewCreationNecessary:reportNecessary];
    while (![handler ableToRespond]) {
        //wait
    }
    if (success) {
        [handler uploadComplete];
    } else {
        [handler uploadFailed];
    }
}



- (IBAction)shareButtonPressed:(UIButton *)sender {
    
    //show popup to create new report, upload report directly or show old report if there is one
    if (self.popOver == nil) {
        
        //view controller
        UIViewController *viewC = [[UIViewController alloc] init];
        //three buttons
        CGFloat heightOfView = 150;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, heightOfView)];
        [view setBackgroundColor:[UIColor whiteColor]];
        //color for all button titles
        UIColor *colorForAllTitles = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0];
        //font for all button titles
        UIFont *fontForAllTitles = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:15.0];
        //button1
        UIButton *createReportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [createReportButton setFrame:CGRectMake(0, 0, 280, 50)];
        [createReportButton.titleLabel setFont:fontForAllTitles];
        [createReportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [createReportButton setTitleColor:colorForAllTitles forState:UIControlStateNormal];
        [createReportButton setTitle:@"Create Report" forState:UIControlStateNormal];
        [createReportButton addTarget:self action:@selector(buildReportPdfAndShowItUserFriendly:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:createReportButton];
        //button2
        UIButton *createReportPrinterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [createReportPrinterButton setFrame:CGRectMake(0, 50, 280, 50)];
        [createReportPrinterButton.titleLabel setFont:fontForAllTitles];
        [createReportPrinterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [createReportPrinterButton setTitleColor:colorForAllTitles forState:UIControlStateNormal];
        [createReportPrinterButton setTitle:@"Create printer friendly Report" forState:UIControlStateNormal];
        [createReportPrinterButton addTarget:self action:@selector(buildReportPdfAndShowItUserFriendly:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:createReportPrinterButton];
        //button3
        UIButton *exportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [exportButton setFrame:CGRectMake(0, 100, 280, 50)];
        [exportButton.titleLabel setFont:fontForAllTitles];
        [exportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [exportButton setTitleColor:colorForAllTitles forState:UIControlStateNormal];
        [exportButton setTitle:@"Export to CodeBeamer" forState:UIControlStateNormal];
        [exportButton addTarget:self action:@selector(uploadReport) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:exportButton];
        
    
        [viewC setView:view];
        
        //UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:viewC];
        SmartSourcePopoverController *popover = [[SmartSourcePopoverController alloc] initWithContentViewController:viewC andTintColor:[UIColor colorWithRed:1.0 green:0.53 blue:0.0 alpha:1.0]];
        popover.delegate = self;
        popover.popoverContentSize=CGSizeMake(280.0, heightOfView);
        
        self.popOver = popover;
        [self.popOver presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }
}


#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    UIViewController *viewController = [[UIViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    return viewController;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)backToMainMenu:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableViewCore setDataSource:self];
    [self.tableViewOutsourcing setDataSource:self];
    [self.tableViewIndifferent setDataSource:self];
    
    [self.tableViewCore setDelegate:self];
    [self.tableViewOutsourcing setDelegate:self];
    [self.tableViewIndifferent setDelegate:self];
    
    //backbutton
    [self.backButton setViewToChangeIfSelected:self.backButtonBackground];
    //entypo
    [self.shareButton setTitle:@"\uE715" forState:UIControlStateNormal];
    
	// Do any additional setup after loading the view.
    [NSThread detachNewThreadSelector:@selector(tellModelToCalculateResults) toTarget:self withObject:nil];
    
    
    //rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //if device orientation is portrait, handle it
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self deviceOrientationDidChange:nil];
    }

    
}




//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    //get orientation
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    //show/hide detail project info based on orientation
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        
        //fit view for portrait mode
        CGFloat heightOfView = self.mainSubView.frame.size.height;
        CGFloat widthOfView = self.mainSubView.frame.size.width;
        
        CGFloat heightOfLabel = (heightOfView - 80) / 3;
        CGFloat widthOfLabel = heightOfLabel;
        
        CGFloat yOriginFirstLabel = 20;
        CGFloat yOriginSecondLabel = 40 + heightOfLabel;
        CGFloat yOriginThirdLabel = 60 + (2 * heightOfLabel);
        
        CGFloat xOriginLabels = 20;
        CGFloat xOriginTableViews = 40 + widthOfLabel;
        
        CGFloat widthOfTableViews = widthOfView - (60 + widthOfLabel);
        
        
        //move labels
        [self.subviewLabelCore setFrame:CGRectMake(xOriginLabels, yOriginFirstLabel, widthOfLabel, heightOfLabel)];
        [self.subviewLabelOutsourcing setFrame:CGRectMake(xOriginLabels, yOriginSecondLabel, widthOfLabel, heightOfLabel)];
        [self.subviewLabelIndifferent setFrame:CGRectMake(xOriginLabels, yOriginThirdLabel, widthOfLabel, heightOfLabel)];
        
        //move table views
        [self.tableViewCore setFrame:CGRectMake(xOriginTableViews, yOriginFirstLabel, widthOfTableViews, heightOfLabel)];
        [self.tableViewOutsourcing setFrame:CGRectMake(xOriginTableViews, yOriginSecondLabel, widthOfTableViews, heightOfLabel)];
        [self.tableViewIndifferent setFrame:CGRectMake(xOriginTableViews, yOriginThirdLabel, widthOfTableViews, heightOfLabel)];
        
        [self.tableViewIndifferent reloadData];
        [self.tableViewCore reloadData];
        [self.tableViewOutsourcing reloadData];
        
    } else {
        //fit view for landscape mode
        //move labels
        [self.subviewLabelCore setFrame:CGRectMake(20, 20, 314, 267)];
        [self.subviewLabelOutsourcing setFrame:CGRectMake(354, 20, 314, 267)];
        [self.subviewLabelIndifferent setFrame:CGRectMake(688, 20, 314, 267)];
        
        //move table views
        [self.tableViewCore setFrame:CGRectMake(20, 307, 314, 360)];
        [self.tableViewOutsourcing setFrame:CGRectMake(354, 307, 314, 360)];
        [self.tableViewIndifferent setFrame:CGRectMake(688, 307, 314, 360)];
        
    
    }
    
    //show popover from right frame
    if (self.popOver) {
        [self.popOver presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [self setMainSubView:nil];
    [self setSubviewLabelCore:nil];
    [self setSubviewLabelOutsourcing:nil];
    [self setSubviewLabelIndifferent:nil];
    [self setTableViewCore:nil];
    [self setTableViewOutsourcing:nil];
    [self setTableViewIndifferent:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
}



- (void)tellModelToCalculateResults
{
    self.classificationResult = [self.projectModel calculateResults];
    [self.tableViewCore reloadData]; 
    [self.tableViewIndifferent reloadData];
    [self.tableViewOutsourcing reloadData];
}



- (void)showDetailInformation
{
    [self.popOver dismissPopoverAnimated:NO];
    [self performSegueWithIdentifier:@"detailInfo" sender:self];
}

- (void)showExplanation
{
    [self.popOver dismissPopoverAnimated:NO];
    [self performSegueWithIdentifier:@"explanation" sender:self];
}

- (void)showComponentInDecisionTable
{
    [self.popOver dismissPopoverAnimated:NO];
    self.passComponentToDecisionTable = YES;
    [self performSegueWithIdentifier:@"decisionTable" sender:self];
}


//shows popover with the selection of two things to do
- (void)showPopoberFromCell:(UITableViewCell *)cell {
    
    //if popover exists, dismiss it 
    if (self.popOver) {
        [self.popOver dismissPopoverAnimated: YES];
        self.popOver = nil;
    }
    
    //view controller
    UIViewController *viewC = [[UIViewController alloc] init];
    //view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    [view setBackgroundColor:[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0]];
    
    //name label in popup
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 50)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    //text label from cell with component name
    UIView *contentView = [cell viewWithTag:20];
    UILabel *textLabel = (UILabel *)[contentView viewWithTag:10];
    [nameLabel setText:textLabel.text];
    [view addSubview:nameLabel];
    
    
    //button1
    VeraRomanButton *detailInformationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailInformationButton setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    [detailInformationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [detailInformationButton setFrame:CGRectMake(0, 50, 280, 50)];
    [detailInformationButton setTitle:@"Detail Info" forState:UIControlStateNormal];
    [detailInformationButton addTarget:self action:@selector(showDetailInformation) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:detailInformationButton];
    
    //button2
    VeraRomanButton *explanationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [explanationButton setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    [explanationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [explanationButton setFrame:CGRectMake(0, 100, 280, 50)];
    [explanationButton setTitle:@"Show Explanation" forState:UIControlStateNormal];
    [explanationButton addTarget:self action:@selector(showExplanation) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:explanationButton];
    
    //button3
    //button2
    VeraRomanButton *decisionTableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [decisionTableButton setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    [decisionTableButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [decisionTableButton setFrame:CGRectMake(0, 150, 280, 50)];
    [decisionTableButton setTitle:@"Show in Decision Table" forState:UIControlStateNormal];
    [decisionTableButton addTarget:self action:@selector(showComponentInDecisionTable) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:decisionTableButton];
    
    
    [viewC setView:view];
    
    //build popover
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:viewC];
    popover.delegate = self;
    popover.popoverContentSize = view.frame.size;
    self.popOver = popover;
    
    //calculate position of cell in main view
    
    //frame into which the arrow of the popover points
    //CGRect rect = CGRectMake(cell.superview.frame.origin.x, (cell.superview.frame.origin.y + (indexPath.row * 44)), 30, 30);
    CGRect rect = CGRectMake((cell.contentView.frame.origin.x + cell.frame.size.width - 10), cell.contentView.frame.origin.y, 10, 10);
    [self.popOver presentPopoverFromRect:rect inView:cell.contentView permittedArrowDirections:(UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp) animated:YES];
    
}



//called by popover as soon as the popover is dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //set color of selected cell to unselected
    UITableViewCell *previouslySelectedCell = [self.selectedTableView cellForRowAtIndexPath:self.selectedIndexPath];
    UIView *cellsBackGroundView = [previouslySelectedCell.contentView viewWithTag:20];
    [cellsBackGroundView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    UILabel *textLabel = (UILabel *)[cellsBackGroundView viewWithTag:10];
    [textLabel setTextColor:[UIColor colorWithRed:0.98 green:0.95 blue:0.94 alpha:1.0]];
    
    //set popover and previously selected cell to nil
    self.popOver = nil;
    self.selectedIndexPath = nil;
    self.selectedTableView = nil;
    
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.classificationResult) {
        return 1;
    } else {
        
        return [[self.classificationResult objectAtIndex:(tableView.tag - 91)] count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.classificationResult) {
        //anders
        static NSString *CellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.contentView setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height)];
        
        
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.contentView setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height)];
        
        
        //get label
        UIView *contentView = [cell viewWithTag:20];
        UILabel *textLabel = (UILabel *)[contentView viewWithTag:10];
        
        //get component
        Component *comp = [[self.classificationResult objectAtIndex:(tableView.tag - 91)] objectAtIndex:indexPath.row];
        
        //NSLog(NSStringFromClass([textLabel class]));
        [textLabel setText:comp.name];
        return cell;
    }
    
    
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //get the selected component
    Component *comp = [[self.classificationResult objectAtIndex:(tableView.tag - 91)] objectAtIndex:indexPath.row];
    self.lastComponentSelected = comp;
    
    [self performSegueWithIdentifier:@"explanation" sender:self];
    
    
    /*
    //set color of previously selected cell
    if (self.selectedTableView) {
        UITableViewCell *previouslySelectedCell = [self.selectedTableView cellForRowAtIndexPath:self.selectedIndexPath];
        UIView *cellsBackGroundView = [previouslySelectedCell.contentView viewWithTag:20];
        [cellsBackGroundView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
        
        UILabel *textLabel = (UILabel *)[cellsBackGroundView viewWithTag:10];
        [textLabel setTextColor:[UIColor colorWithRed:0.98 green:0.95 blue:0.94 alpha:1.0]];
        
        if ([indexPath isEqual:self.selectedIndexPath]) {
            self.selectedIndexPath = nil;
            self.selectedTableView = nil;
            self.lastComponentSelected = nil;
            [self.popOver dismissPopoverAnimated: YES];
            self.popOver = nil;
        }
        
    }
    
    
    //change color of selected cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *cellView = [cell.contentView viewWithTag:20];
    [cellView setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    UILabel *textLabel = (UILabel *)[cellView viewWithTag:10];
    [textLabel setTextColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    
    
    //set selected index path in table view
    self.selectedTableView = tableView;
    self.selectedIndexPath = indexPath;
    
    //show popover
    [self showPopoberFromCell:[tableView cellForRowAtIndexPath:indexPath]];*/
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailInfo"]) {
        ComponentInfoViewController *compIVC = (ComponentInfoViewController *)segue.destinationViewController;
        [compIVC setComponent:self.lastComponentSelected andModel:self.projectModel];
    
    } else if ([segue.identifier isEqualToString:@"explanation"]) {
        ResultExplanationViewController *resExplanationVC = (ResultExplanationViewController *)segue.destinationViewController;
        [resExplanationVC setComponent:self.lastComponentSelected andModel:self.projectModel];
        
    } else if ([segue.identifier isEqualToString:@"decisionTable"]) {
        DecisionTableViewController *decTVC = (DecisionTableViewController *)segue.destinationViewController;
        [decTVC setProjectModel:self.projectModel];
        
        
        if (self.passComponentToDecisionTable) {
            [decTVC markComponentAsSelected:self.lastComponentSelected];
        }
    
    } else if ([segue.identifier isEqualToString:@"modalWaitingScreen"]) {
        //start upload thread
        [NSThread detachNewThreadSelector:@selector(uploadReportAndNotifyViewController:) toTarget:self withObject:segue.destinationViewController];
    }
}

@end

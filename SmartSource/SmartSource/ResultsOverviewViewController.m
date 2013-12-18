//
//  ResultsOverviewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.07.13.
//
//

#import "ResultsOverviewViewController.h"
#import "ResultExplanationViewController.h"
#import "DecisionTableViewController.h"
#import "VeraRomanButton.h"
#import "ButtonExternalBackground.h"
#import "PDFExporter.h"
#import "SmartSourcEPopoverController.h"
#import "UploadCompleteHandler.h"

@interface ResultsOverviewViewController ()
//references to views --> important for rearrangement in case of changes in device orientation
@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet UIView *subviewLabelCore;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCore;
@property (strong, nonatomic) IBOutlet UIView *subviewLabelOutsourcing;
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutsourcing;
@property (strong, nonatomic) IBOutlet UIView *subviewLabelIndifferent;
@property (strong, nonatomic) IBOutlet UITableView *tableViewIndifferent;
//pdf export
@property (strong, nonatomic) UIPopoverController *popOver;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
//temp variables to keep references til prepareForSegue is called
@property (strong, nonatomic) Component *lastComponentSelected;
@property (nonatomic) BOOL passComponentToDecisionTable;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UITableView *selectedTableView;
//results
@property (strong, nonatomic) NSArray *classificationResult;
//ui references
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;
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
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize selectedTableView = _selectedTableView;
@synthesize shareButton = _shareButton;

#pragma mark inherited methods

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


#pragma mark results calculation


- (void)tellModelToCalculateResults
{
    self.classificationResult = [self.projectModel calculateResults];
    [self.tableViewCore reloadData];
    [self.tableViewIndifferent reloadData];
    [self.tableViewOutsourcing reloadData];
}

#pragma mark PDF Export

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


# pragma IBActions

/*
 *  shows popover that offers three options to user
 *  1.) create report, 2.) create printer friendly report, 3.) upload report to collaboration platform
 *
 */
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
        
        SmartSourcePopoverController *popover = [[SmartSourcePopoverController alloc] initWithContentViewController:viewC andTintColor:[UIColor colorWithRed:1.0 green:0.53 blue:0.0 alpha:1.0]];
        popover.delegate = self;
        popover.popoverContentSize=CGSizeMake(280.0, heightOfView);
        self.popOver = popover;
        [self.popOver presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (IBAction)backToMainMenu:(id)sender {
    //just dismiss view controller
    [self.navigationController popViewControllerAnimated:YES];
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


#pragma mark device orientaiton

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

//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.classificationResult) {
        //different
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
}

#pragma mark prepareForSegue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //explanation screen --> pass project model
    if ([segue.identifier isEqualToString:@"explanation"]) {
        ResultExplanationViewController *resExplanationVC = (ResultExplanationViewController *)segue.destinationViewController;
        [resExplanationVC setComponent:self.lastComponentSelected andModel:self.projectModel];
    
    //decision table --> either pass component or none
    } else if ([segue.identifier isEqualToString:@"decisionTable"]) {
        DecisionTableViewController *decTVC = (DecisionTableViewController *)segue.destinationViewController;
        [decTVC setProjectModel:self.projectModel];
        if (self.passComponentToDecisionTable) {
            [decTVC markComponentAsSelected:self.lastComponentSelected];
        }
    
    //pdf upload waiting screen
    } else if ([segue.identifier isEqualToString:@"modalWaitingScreen"]) {
        //start upload thread
        [NSThread detachNewThreadSelector:@selector(uploadReportAndNotifyViewController:) toTarget:self withObject:segue.destinationViewController];
    }
}

@end

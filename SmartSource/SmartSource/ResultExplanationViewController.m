//
//  ResultExplanationViewController.m
//  SmartSource
//
//  Created by Lorenz on 18.08.13.
//
//

#import "ResultExplanationViewController.h"
#import "ScaleView.h"
#import "ComponentModel.h"
#import "VeraBoldLabel.h"
#import "VeraRomanLabel.h"
#import "SubCharacteristicsView.h"
#import "ButtonExternalBackground.h"
#import "SmartSourceFunctions.h"
#import "DecisionTableViewController.h"


@interface ResultExplanationViewController ()
//Model
@property (strong, nonatomic) ProjectModel *projectModel;
@property (strong, nonatomic) ComponentModel *currentComponent;
//Characteristics used
@property (strong, nonatomic) NSArray *superChars;
@property (strong, nonatomic) NSArray *chars;
//results
@property (nonatomic) float totalWeightOfSuperCharacteristics;
@property (nonatomic) float weightedSumOfSuperCharacteristics;
@property (nonatomic, strong) NSArray *valuesForCells;
@property (nonatomic, strong) NSString *explanation;
//Views
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *explanationTextView;
@property (strong, nonatomic) IBOutlet UIView *classificationResultsView;
@property (strong, nonatomic) IBOutlet UIView *resultImageView;
//Labels and values
@property (strong, nonatomic) IBOutlet ScaleView *scaleView;
@property (strong, nonatomic) IBOutlet UILabel *componentNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *componentDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *resultIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *resultClassificationLetterLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultSumWeightedAveragesLabel;
//buttons
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;
//expansion
//index path of cell to be expanded
@property (nonatomic, strong) NSIndexPath *cellExpansionIndexPath;
@property (nonatomic, strong) SubCharacteristicsView *expansionView;
@property (nonatomic) CGFloat heightOfEV;
@end

@implementation ResultExplanationViewController
@synthesize superChars = _superChars;
@synthesize chars = _chars;
@synthesize totalWeightOfSuperCharacteristics = _totalWeightOfSuperCharacteristics;
@synthesize weightedSumOfSuperCharacteristics = _weightedSumOfSuperCharacteristics;
@synthesize projectModel = _projectModel;
@synthesize tableView = _tableView;
@synthesize scaleView = _scaleView;
@synthesize componentNameLabel = _componentNameLabel;
@synthesize componentDescriptionTextView = _componentDescriptionTextView;
@synthesize resultClassificationLetterLabel = _resultClassificationLetterLabel;
@synthesize resultSumWeightedAveragesLabel = _resultSumWeightedAveragesLabel;
@synthesize currentComponent = _currentComponent;
@synthesize cellExpansionIndexPath = _cellExpansionIndexPath;
@synthesize expansionView = _expansionView;
@synthesize heightOfEV = _heightOfEV;
@synthesize backButton = _backButton;
@synthesize backButtonBackground = _backButtonBackground;
@synthesize valuesForCells = _valuesForCells;
@synthesize resultIconImageView = _resultIconImageView;
@synthesize explanation = _explanation;
@synthesize explanationTextView = _explanationTextView;
@synthesize classificationResultsView = _classificationResultsView;
@synthesize resultImageView = _resultImageView;



#pragma mark IBActions

//show decision table
- (IBAction)showComponentInDecisionTable:(id)sender {
    [self performSegueWithIdentifier:@"decisionTable" sender:self];
}

//back to results overview
- (IBAction)backToResultOverview:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Inherited methods


//view did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    //table view delegate
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    //backbutton
    [self.backButton setViewToChangeIfSelected:self.backButtonBackground];
    //no cell expanded when view loads
    self.cellExpansionIndexPath = nil;
    //device orientation handling
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:   @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //if device orientation is portrait, handle it
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self deviceOrientationDidChange:nil];
    }
    //fill labels with results
    [self updateLabelsFromResults];
}


//fill label with results
- (void)updateLabelsFromResults
{
    //component info labels
    [self.componentNameLabel setText:[self.currentComponent getComponentObject].name];
    [self.componentDescriptionTextView setText:self.explanation];
    //result labels
    [self.resultSumWeightedAveragesLabel setText:[NSString stringWithFormat:@"%.1f", self.weightedSumOfSuperCharacteristics]];
    //set evaluation label - high, medium low
    [self.resultIconImageView setImage:[SmartSourceFunctions getImageForWeightedAverageValue:self.weightedSumOfSuperCharacteristics]];
    [self.resultClassificationLetterLabel setText:[SmartSourceFunctions getOutIndCoreStringForWeightedAverageValue:self.weightedSumOfSuperCharacteristics]];
    [self.scaleView setValue:self.weightedSumOfSuperCharacteristics];
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [self setScaleView:nil];
    [self setComponentNameLabel:nil];
    [self setResultClassificationLetterLabel:nil];
    [self setResultSumWeightedAveragesLabel:nil];
    [self setScaleView:nil];
    [self setComponentDescriptionTextView:nil];
    [self setResultIconImageView:nil];
    [self setExplanationTextView:nil];
    [self setClassificationResultsView:nil];
    [self setResultImageView:nil];
    [super viewDidUnload];
}



#pragma mark Device Orientation

//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //get current orientaiton
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //differentiate between orientations
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self.explanationTextView setFrame:CGRectMake(0, 49, (self.view.frame.size.width -40), 60)];
        [self.classificationResultsView setFrame:CGRectMake(0, 114, (self.view.frame.size.width - 195), 150)];
        [self.resultImageView setFrame:CGRectMake((self.view.frame.size.width - 190), 114, 150, 150)];
        [self.tableView setFrame:CGRectMake(20, 294, (self.view.frame.size.width - 40), (self.view.frame.size.height - 294))];
    } else if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        //values
        CGFloat heightOfArea = 150;
        CGFloat widthOfTextView = 345;
        CGFloat yOriginOfArea = 49;
        CGFloat xOriginOfImageView = (self.view.frame.size.width - 190);
        CGFloat widthOfClassificationFactsView = ((xOriginOfImageView - 5) - (widthOfTextView + 5));
        CGFloat yOriginOfTableView = yOriginOfArea + heightOfArea + 30;
        //frames
        [self.explanationTextView setFrame:CGRectMake(0, yOriginOfArea, widthOfTextView, heightOfArea)];
        [self.classificationResultsView setFrame:CGRectMake((widthOfTextView + 5), yOriginOfArea, widthOfClassificationFactsView, heightOfArea)];
        [self.resultImageView setFrame:CGRectMake(xOriginOfImageView, yOriginOfArea, 150, 150)];
        [self.tableView setFrame:CGRectMake(20, yOriginOfTableView, (self.view.frame.size.width - 40), (self.view.frame.size.height - (yOriginOfTableView + 20)))];
    }
}


#pragma mark getters and setters

//set component to be displayed and project model
- (void)setComponent:(Component *)component andModel:(ProjectModel *)model
{
    //set model
    self.projectModel = model;
    self.currentComponent = [[ComponentModel alloc] initWithComponentId:component.componentID];
    self.totalWeightOfSuperCharacteristics = [self.currentComponent getTotalWeightOfSuperCharacteristics];
    
    NSDictionary *results = [self.currentComponent calculateDetailedResults];
    self.explanation = [results objectForKey:@"explanationText"];
    self.weightedSumOfSuperCharacteristics = [[results objectForKey:@"weightedSumOfSupercharacteristics"] floatValue];
    self.valuesForCells = [results objectForKey:@"valuesForCells"];
    self.superChars = [results objectForKey:@"superChars"];
    self.chars = [results objectForKey:@"chars"];
    [self.tableView reloadData];
}



#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //one section
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 54;
    }
    //increase height of cell to be expanded
    if (self.cellExpansionIndexPath && [indexPath isEqual:self.cellExpansionIndexPath]) {
        return 49 + self.heightOfEV;//expansionView.frame.size.height;
    }
    
    //else usual height
    return 49;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //number of supercharacteristics +1 for header
    if (self.superChars) {
        return [[self.superChars objectAtIndex:0] count] + 1;
    } else {
        return 0;
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
    //first row is header - headerCell
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"headerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
        
    //all other cells are supercharacteristic cells - superCharacteristicCell
    } else {
        //row -1 because value 0 has been used for header
        NSInteger row = indexPath.row - 1;
        //get cell
        static NSString *CellIdentifier = @"superCharacteristicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //get labels
        UIView *cellContentView = [cell viewWithTag:20];
        UILabel *superCharNameLabel = (UILabel *)[cellContentView viewWithTag:25];
        UILabel *superCharEvaluationLabel = (UILabel *)[cellContentView viewWithTag:21];
        UILabel *superCharAverageLabel = (UILabel *)[cellContentView viewWithTag:22];
        UILabel *superCharWeightLabel = (UILabel *)[cellContentView viewWithTag:23];
        UILabel *superCharWeightedAverageLabel = (UILabel *)[cellContentView viewWithTag:24];
        //set name label
        [superCharNameLabel setText:[[self.valuesForCells objectAtIndex:row] objectAtIndex:0]];
        //set average label        
        [superCharEvaluationLabel setText:[[self.valuesForCells objectAtIndex:row] objectAtIndex:1]];
        [superCharAverageLabel setText:[[self.valuesForCells objectAtIndex:row] objectAtIndex:2]];
        // set weight label
        [superCharWeightLabel setText:[[self.valuesForCells objectAtIndex:row] objectAtIndex:3]];
        //set weighted average label
        [superCharWeightedAverageLabel setText:[[self.valuesForCells objectAtIndex:row] objectAtIndex:4]];
        return cell;
    }
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //show complete explanation of subcharacteristics substantiations
    [self showHideSubCharacteristicsForCellAtIndexPath:indexPath];
}


#pragma mark Subcharacteristics expansion

/*
 *  method to be called that expands a cell to display a complete
 *  explanation of subcharacteristics values
 */
- (void)showHideSubCharacteristicsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    //not for first row
    if (indexPath.row == 0) {
        return;
    }
    //first cell is header cell
    NSInteger row = indexPath.row-1;
    //check if new selected cell is same as previously selected
    BOOL sameCell = [indexPath isEqual:self.cellExpansionIndexPath];
    UITableViewCell *previouslyySelectedCell;
    UIView *contentViewPreciousCell;
    UIImageView *arrowImagePrevious;
    //save old characteristics view in tmpvariable
    SubCharacteristicsView *tempCharView;
    //if expansion exists, hide it
    if (self.cellExpansionIndexPath) {
        //get old cell cell
        previouslyySelectedCell = [self.tableView cellForRowAtIndexPath:self.cellExpansionIndexPath];
        contentViewPreciousCell = [previouslyySelectedCell viewWithTag:20];
        arrowImagePrevious = (UIImageView *)[contentViewPreciousCell viewWithTag:26];
        //save old characteristics view in tmpvariable
        tempCharView = (SubCharacteristicsView *)self.expansionView;
    }
    UITableViewCell *cellCurrent;
    UIView *contentViewCurrent;
    UIImageView *arrowImageCurrent;
    CGRect frameOfCharacteristicsView;
    
    if (!sameCell) {
        //get new cell
        cellCurrent = [self.tableView cellForRowAtIndexPath:indexPath];
        contentViewCurrent = [cellCurrent viewWithTag:20];
        arrowImageCurrent = (UIImageView *)[contentViewCurrent viewWithTag:26];
        //build new view
        //initialize new characteristics subview
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SubCharacteristicsView" owner:self options:nil];
        self.expansionView = [subviewArray objectAtIndex:0];
        //get characteristics to pass to view
        NSArray *charsForView = [NSArray arrayWithObjects:[[self.chars objectAtIndex:0] objectAtIndex:row], [[self.chars objectAtIndex:1] objectAtIndex:row], nil];
        CGFloat widthOfExpansionView = self.tableView.frame.size.width - 49;
        //get values to pass to view
        NSString *valueSuperChar = [[self.valuesForCells objectAtIndex:row] objectAtIndex:2];
        CGFloat superCharValue = [valueSuperChar floatValue];
        float weight = ([[[self.superChars objectAtIndex:1] objectAtIndex:row] floatValue]/self.totalWeightOfSuperCharacteristics);
        float weightedAverage = ([[[self.superChars objectAtIndex:1] objectAtIndex:row] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
        
        //set view
        [self.expansionView setCharacteristics:charsForView width:widthOfExpansionView average:superCharValue weight:weight andWeightedAverage:weightedAverage];
        //hide behind content view to pull it out
        frameOfCharacteristicsView = self.expansionView.frame;
        self.heightOfEV = frameOfCharacteristicsView.size.height + 5;
        [self.expansionView setFrame:contentViewCurrent.frame];
        //put subview below content view
        [cellCurrent insertSubview:self.expansionView belowSubview:contentViewCurrent];
        [self.expansionView.superview sendSubviewToBack:self.expansionView];
    } else {
        self.expansionView = nil;
        self.cellExpansionIndexPath = nil;
    }
    
    //hide expansion view and return
    if (arrowImagePrevious) {
        [self rotateImage:arrowImagePrevious duration:0.2 curve:UIViewAnimationCurveEaseIn degrees:0];
    }
    if (!sameCell) {
        [self rotateImage:arrowImageCurrent duration:0.2 curve:UIViewAnimationCurveEaseIn degrees:90];
        //set index path
        self.cellExpansionIndexPath = indexPath;
    }
    if (tempCharView) {
        for (UIView *view in tempCharView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    //start animation
    [UIView animateWithDuration:0.2 animations:^{
        if (tempCharView) {
            [tempCharView.superview sendSubviewToBack:self.expansionView];
            [tempCharView setFrame:contentViewPreciousCell.frame];
        }
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        if (!sameCell) {
            [self.expansionView setFrame:frameOfCharacteristicsView];
        }
    } completion:^(BOOL finished) {
        if (tempCharView) {
            [tempCharView removeFromSuperview];
        }
    }];
}




#define M_PI   3.14159265358979323846264338327950288   /* pi */
#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

/*
 *  helper method to rotate image when expanding cell
 */
- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation(DEGREES_RADIANS(degrees));
    image.transform = transform;
    // Commit the changes
    [UIView commitAnimations];
}


#pragma mark prepareForSegue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"decisionTable"]) {
        DecisionTableViewController *decTVC = (DecisionTableViewController *)segue.destinationViewController;
        [decTVC setProjectModel:self.projectModel];
        [decTVC markComponentAsSelected:[self.currentComponent getComponentObject]];
        
    }
}

@end

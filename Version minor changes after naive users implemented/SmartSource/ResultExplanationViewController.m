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

//Views
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//Labels and values
@property (strong, nonatomic) IBOutlet ScaleView *scaleView;
@property (strong, nonatomic) IBOutlet UILabel *componentNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *componentDescriptionTextView;

@property (strong, nonatomic) IBOutlet UILabel *resultClassificationLetterLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultSumWeightedAveragesLabel;

//expansion
//index path of cell to be expanded
@property (nonatomic, strong) NSIndexPath *cellExpansionIndexPath;
@property (nonatomic, strong) SubCharacteristicsView *expansionView;
@property (nonatomic) CGFloat heightOfEV;

@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;


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






- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backToResultOverview:(id)sender {
    NSLog(@"ButtonPressed");
    [self.navigationController popViewControllerAnimated:YES];
}



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
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:   @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    [self updateLabelsFromResults];
    
    
    
}

- (void)calculateResults
{
    
    //calculate the sum of all weights of supercharacteristics
    float totalWeightOfSupercharacteristics = 0.0;
    for (int i=0; i<[[self.superChars objectAtIndex:1] count]; i++) {
        totalWeightOfSupercharacteristics += [[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue];
    }
    self.totalWeightOfSuperCharacteristics = totalWeightOfSupercharacteristics;
    
    
    float weightedSumOfSupercharacteristics = 0.0;
    
    NSMutableArray *mutableValuesForCells = [NSMutableArray array];
    
    //for every supercharacteristic
    for (int i=0; i<[[self.superChars objectAtIndex:0] count]; i++) {
        
        NSMutableArray *valuesForCell = [NSMutableArray array];
        
        //add name of characteristic
        [valuesForCell addObject:[[self.superChars objectAtIndex:0] objectAtIndex:i]];
        
        
        //add evaluation
        NSArray *subCharacteristicsValues = [[self.chars objectAtIndex:1] objectAtIndex:i];
        float sum = 0.0;
        //add all values
        for (int y=0; y<[subCharacteristicsValues count]; y++) {
            sum = sum + [[subCharacteristicsValues objectAtIndex:y] floatValue];
        }
        //devide the sum by the number of characteristics --> average and extract the rating of the supercharacteristic
        float superCharValue = sum/[subCharacteristicsValues count];
        
        //add rating average string name
        [valuesForCell addObject:[SmartSourceFunctions getHighMediumLowStringForFloatValue:superCharValue]];
        
        //add rating average string number
        [valuesForCell addObject:[NSString stringWithFormat:@"%.1f", superCharValue]];
        
        //add weight
        float weight = ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue]/self.totalWeightOfSuperCharacteristics);
        [valuesForCell addObject:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
        
        //add weighted average
        float weightedAverage = ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
        [valuesForCell addObject:[NSString stringWithFormat:@"%.1f", weightedAverage]];
        
        //add the weighted value to the end rating value
        weightedSumOfSupercharacteristics += ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
        
        //add array to mutableValuesForCells
        NSArray *result = [valuesForCell copy];
        [mutableValuesForCells addObject:result];
    }
    
    self.valuesForCells = [mutableValuesForCells copy];
    
    //check if sum of weighted averages is correct
    CGFloat sum = 0.0;
    for (NSArray *oneCellsValues in self.valuesForCells) {
        sum += [[oneCellsValues lastObject] floatValue];
    }
    
    //if sum is not the same then add difference to last superchars weighted average
    CGFloat roundedWeightedSumOfSupercharacteristics = [[NSString stringWithFormat:@"%.1f", weightedSumOfSupercharacteristics] floatValue];
    CGFloat roundedSumFromLabels = [[NSString stringWithFormat:@"%.1f", sum] floatValue];
    
    if (roundedSumFromLabels != roundedWeightedSumOfSupercharacteristics) {
        
        CGFloat difference = roundedSumFromLabels - roundedWeightedSumOfSupercharacteristics;
        if (difference < 0) {
            difference = difference * (-1);
        }
        
        NSMutableArray *lastCellsValues = [[self.valuesForCells lastObject] mutableCopy];
        CGFloat newWeightedAverage = [[[self.valuesForCells lastObject] lastObject] floatValue] + difference;
        [lastCellsValues replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%.1f", newWeightedAverage]];
        [mutableValuesForCells replaceObjectAtIndex:([self.valuesForCells count]-1) withObject:[lastCellsValues copy]];
        self.valuesForCells = [mutableValuesForCells copy];
    }

    
    self.weightedSumOfSuperCharacteristics = weightedSumOfSupercharacteristics;
    
    [self.tableView reloadData];
    
}



- (void)updateLabelsFromResults
{
    

    //component info labels
    [self.componentNameLabel setText:[self.currentComponent getComponentObject].name];
    [self.componentDescriptionTextView setText:[self.currentComponent getComponentObject].descr];
    
    
    
    //result labels
    [self.resultSumWeightedAveragesLabel setText:[NSString stringWithFormat:@"%.1f", self.weightedSumOfSuperCharacteristics]];
    
    //set evaluation label - high, medium low
    if (self.weightedSumOfSuperCharacteristics < 1.67) {
        [self.resultClassificationLetterLabel setText:@"OUTSOURCING"];
    } else if (self.weightedSumOfSuperCharacteristics < 2.34) {
        [self.resultClassificationLetterLabel setText:@"INDIFFERENT"];
    } else if (self.weightedSumOfSuperCharacteristics <= 3.0) {
        [self.resultClassificationLetterLabel setText:@"CORE"];
    }
    
    [self.scaleView setValue:self.weightedSumOfSuperCharacteristics];
}


//detect rotation
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //change size of table view to make it fit to interface orientation
}



//set component to be displayed and project model
- (void)setComponent:(Component *)component andModel:(ProjectModel *)model
{
    //set model
    self.projectModel = model;
    NSArray *returnedValues = [self.projectModel getCharsAndValuesArray:component.componentID];
    self.superChars = [returnedValues objectAtIndex:0];
    self.chars = [returnedValues objectAtIndex:1];
    
    self.currentComponent = [[ComponentModel alloc] initWithComponent:component];
    [self calculateResults];
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //one section
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //increase height of cell to be expanded
    if (self.cellExpansionIndexPath && [indexPath isEqual:self.cellExpansionIndexPath]) {
        return 54 + self.heightOfEV;//expansionView.frame.size.height;
    }
    
    //else usual height
    return 54;
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


- (void)showHideSubCharacteristicsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    //not for first row
    if (indexPath.row == 0) {
        return;
    }
    
    //first cell is header cell
    NSInteger row = indexPath.row-1;
    
    
    //check if new selected cell is same as previously
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
        self.heightOfEV = frameOfCharacteristicsView.size.height;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showHideSubCharacteristicsForCellAtIndexPath:indexPath];
}






- (void)viewDidUnload {
    [self setTableView:nil];
    [self setScaleView:nil];
    [self setComponentNameLabel:nil];
    [self setResultClassificationLetterLabel:nil];
    [self setResultSumWeightedAveragesLabel:nil];
    [self setScaleView:nil];
    [self setComponentDescriptionTextView:nil];
    [super viewDidUnload];
}
@end

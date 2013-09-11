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
@property (nonatomic, strong) NSArray *valuesOfSuperCharacteristics;

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


@end

@implementation ResultExplanationViewController
@synthesize superChars = _superChars;
@synthesize chars = _chars;
@synthesize totalWeightOfSuperCharacteristics = _totalWeightOfSuperCharacteristics;
@synthesize weightedSumOfSuperCharacteristics = _weightedSumOfSuperCharacteristics;
@synthesize valuesOfSuperCharacteristics = _valuesOfSuperCharacteristics;
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



- (IBAction)backToResultsOverView:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

    
}


//view did load
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //table view delegate
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
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
    NSMutableArray *valuesOfSuperChars = [NSMutableArray array];
    
    
    //for every supercharacteristic
    for (int i=0; i<[[self.superChars objectAtIndex:0] count]; i++) {
        
        //array with all values of subcharacteristics that belong to the current supercharacteristic
        NSArray *subCharacteristicsValues = [[self.chars objectAtIndex:1] objectAtIndex:i];
        float sum = 0.0;
        
        //add all values
        for (int y=0; y<[subCharacteristicsValues count]; y++) {
            sum = sum + [[subCharacteristicsValues objectAtIndex:y] floatValue];
        }
        
        //devide the sum by the number of characteristics --> average and extract the rating of the supercharacteristic
        float superCharValue = sum/[subCharacteristicsValues count];
        [valuesOfSuperChars addObject:[NSNumber numberWithFloat:superCharValue]];
        
        
        //add the weighted value to the end rating value
        weightedSumOfSupercharacteristics += ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
        
        
    }
    
    
    self.valuesOfSuperCharacteristics = [valuesOfSuperChars copy];
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
        
        
        NSNumber *valueSuperChar = [self.valuesOfSuperCharacteristics objectAtIndex:row];
        CGFloat superCharValue = [valueSuperChar floatValue];
        
        //set evaluation label - high, medium low
        if (superCharValue < 1.67) {
            [superCharEvaluationLabel setText:@"LOW"];
            [superCharEvaluationLabel setTextColor:[UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0]];
        } else if (superCharValue < 2.34) {
            [superCharEvaluationLabel setText:@"MEDIUM"];
            [superCharEvaluationLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0]];
        } else if (superCharValue <= 3.0) {
            [superCharEvaluationLabel setText:@"HIGH"];
            [superCharEvaluationLabel setTextColor:[UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0]];
        }
        
        //set average label        
        [superCharAverageLabel setText:[NSString stringWithFormat:@"%.1f", superCharValue]];
        
        // set weight label
        float weight = ([[[self.superChars objectAtIndex:1] objectAtIndex:row] floatValue]/self.totalWeightOfSuperCharacteristics);
        [superCharWeightLabel setText:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
        
        //set weighted average label
        float weightedAverage = ([[[self.superChars objectAtIndex:1] objectAtIndex:row] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
        [superCharWeightedAverageLabel setText:[NSString stringWithFormat:@"%.1f", weightedAverage]];
        
        //set name label
        [superCharNameLabel setText:[[self.superChars objectAtIndex:0] objectAtIndex:row]];
        
        
        
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
        NSNumber *valueSuperChar = [self.valuesOfSuperCharacteristics objectAtIndex:row];
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

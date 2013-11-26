//
//  WeightSuperCharacteristicsViewController.m
//  SmartSource
//
//  Created by Lorenz on 08.09.13.
//
//

#import "WeightSuperCharacteristicsViewController.h"
#import "Project+Factory.h"
#import "Component+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Slider.h"


@interface WeightSuperCharacteristicsViewController ()

@property (nonatomic, strong) ProjectModel *currentProject;
@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (nonatomic, strong) NSArray *superCharacteristics;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RatingTableViewViewController *delegate;
@property (strong, nonatomic) IBOutlet UILabel *componentRatingCompleteLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightingCompleteLabel;


@end

@implementation WeightSuperCharacteristicsViewController
@synthesize currentProject = _currentProject;
@synthesize projectNameLabel = _projectNameLabel;
@synthesize superCharacteristics = _superCharacteristics;
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize componentRatingCompleteLabel = _componentRatingCompleteLabel;
@synthesize weightingCompleteLabel = _weightingCompleteLabel;

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
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    //set name of project label
    Project *curProj = [self.currentProject getProjectObject];
    [self.projectNameLabel setText:curProj.name];
    
    if (self.delegate.componentRatingIsComplete) {
        [self.componentRatingCompleteLabel setText:@"\u2713"];
    } else {
        [self.componentRatingCompleteLabel setText:@""];
    }
    
    if (self.delegate.weightingIsComplete) {
        [self.weightingCompleteLabel setText:@"\u2713"];
    } else {
        [self.weightingCompleteLabel setText:@""];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)componentsButtonPressed:(id)sender {
    //make modal view controller disappear
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)backToMainMenu:(id)sender {
    //make modal view controller disappear
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.delegate returnToMainMenu];
    
}

//set project model
- (void)setRatingDelegate:(RatingTableViewViewController *)delegate
{
    //get model
    self.currentProject = [delegate getProjectModel];
    self.delegate = delegate;
    
    //get characteristics from first component of project
    self.superCharacteristics = [self.currentProject getSuperCharacteristics];
    
    [self.tableView reloadData];
}


//save weight from slider into model
- (void)saveValueForSlider:(Slider *)slider
{
    //get name of supercharacteristic
    UILabel *textLabel = (UILabel *)[slider.superview.superview viewWithTag:10];
    
    //save weight into model
    [self.currentProject saveWeightValue:slider.value forSuperCharacteristicWithName:textLabel.text];
}

- (void)saveContext
{
    if (![self.currentProject saveContext]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.superCharacteristics count];
}

//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get cell
    static NSString *CellIdentifier = @"superCharacteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //get supercharacteristic
    SuperCharacteristic *superChar = [self.superCharacteristics objectAtIndex:indexPath.row];
    
    //set label
    UIView *contentView = [cell viewWithTag:20];
    UILabel *text = (UILabel *)[contentView viewWithTag:10];
    text.text = superChar.name;
    
    //add action to slider
    UIView *sliderView = [contentView viewWithTag:15];
    Slider *slider = (Slider *)[sliderView viewWithTag:11];
    //change appearence
    UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"thumb.jpg"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"nothumb.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
    
    UIImage *sliderThumbImage = [UIImage imageNamed: @"thumb.jpg"];
    
    [slider setThumbImage:sliderThumbImage forState:UIControlStateNormal];
    [slider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [slider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    
    
    //set the sliders rating controller to self in order for it to be able to talk back to us and save its value
    [slider setSliderDelegate:self];
    
    
    //slider value according to stored value in core database
    slider.value = [superChar.weight floatValue];
    
    return cell;
        
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (void)viewDidUnload {
    [self setProjectNameLabel:nil];
    [self setTableView:nil];
    [self setComponentRatingCompleteLabel:nil];
    [self setWeightingCompleteLabel:nil];
    [super viewDidUnload];
}
@end

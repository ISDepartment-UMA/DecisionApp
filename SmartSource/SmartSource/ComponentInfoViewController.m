//
//  ComponentInfoViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.07.13.
//
//

#import "ComponentInfoViewController.h"
#import "Component+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "ButtonExternalBackground.h"
#import "SmartSourceFunctions.h"

@interface ComponentInfoViewController ()

//Views
@property (strong, nonatomic) IBOutlet UIView *projectInfoSubView;
@property (strong, nonatomic) IBOutlet UIView *componentEvaluationSubview;
@property (strong, nonatomic) IBOutlet UIView *componentInfoSubview;
@property (strong, nonatomic) IBOutlet UITableView *componentEvaluationTableView;

//Labels
//Project Info
@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *projectDescriptionTextView;

//Component Info
@property (strong, nonatomic) IBOutlet UILabel *componentNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *componentDescriptionTextView;


@property (strong, nonatomic) IBOutlet UILabel *componentPriorityLabel;
@property (strong, nonatomic) IBOutlet UILabel *componentLastModifierLabel;
@property (strong, nonatomic) IBOutlet UILabel *componentEstimatedHoursLabel;


//Model
@property (strong, nonatomic) ProjectModel *projectModel;
@property (strong, nonatomic) Component *currentComponent;

@property (strong, nonatomic) NSArray *superChars;
@property (strong, nonatomic) NSArray *chars;

@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;

@end

@implementation ComponentInfoViewController
@synthesize currentComponent = _currentComponent;
@synthesize superChars = _superChars;
@synthesize chars = _chars;
@synthesize projectModel = _projectModel;
@synthesize projectInfoSubView = _projectInfoSubView;
@synthesize componentEvaluationSubview = _componentEvaluationSubview;
@synthesize componentInfoSubview = _componentInfoSubview;
@synthesize componentEvaluationTableView = _componentEvaluationTableView;
@synthesize projectNameLabel = _projectNameLabel;
@synthesize projectDescriptionTextView = _projectDescriptionTextView;
@synthesize componentNameLabel = _componentNameLabel;
@synthesize componentPriorityLabel = _componentPriorityLabel;
@synthesize componentLastModifierLabel = _componentLastModifierLabel;
@synthesize componentEstimatedHoursLabel = _componentEstimatedHoursLabel;
@synthesize componentDescriptionTextView = _componentDescriptionTextView;
@synthesize backButton = _backButton;
@synthesize backButtonBackground = _backButtonBackground;


- (IBAction)backToResultsOverview:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)updateLabelsFromModel
{
    //set project labels
    Project *project = [self.projectModel getProjectObject];
    [self.projectNameLabel setText:project.name];
    [self.projectDescriptionTextView setText:project.descr];
    
    //set component labels
    [self.componentNameLabel setText:self.currentComponent.name];
    [self.componentDescriptionTextView setText:self.currentComponent.descr];
    [self.componentPriorityLabel setText:self.currentComponent.priority];
    [self.componentLastModifierLabel setText:self.currentComponent.modifier];
    [self.componentEstimatedHoursLabel setText:[self.currentComponent.estimatedhours stringValue]];
}


- (void)setComponent:(Component *)component andModel:(ProjectModel *)model;
{
    //set model
    self.projectModel = model;
    self.currentComponent = component;
    
    
    //initiate arrays of used supercharacteristics and characteristics
    NSMutableArray *usedSuperChars = [NSMutableArray array];
    NSMutableArray *usedChars = [NSMutableArray array];
    
    //initiate arrays for values
    NSMutableArray *valueSuperChars = [NSMutableArray array];
    NSMutableArray *valueChars = [NSMutableArray array];
    
    
    //iterate through all supercharacteristics
    SuperCharacteristic *superChar;
    
    //sort supercharacteristics
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSEnumerator *superCharEnumerator = [[self.currentComponent.ratedBy sortedArrayUsingDescriptors:descriptors] objectEnumerator];
    
    while ((superChar = [superCharEnumerator nextObject]) != nil) {
        
        //add supercharacteristic to used supercharacteristic array
        [usedSuperChars addObject:superChar.name];
        
        
        //add weight to array of supercharacteristic's values
        [valueSuperChars addObject:superChar.weight];
        
        //iterate through all characteristics of supercharacteristic
        Characteristic *characteristic;
        
        NSMutableArray *characteristicsOfSuperchar = [NSMutableArray array];
        NSMutableArray *valueOfCharacteristics = [NSMutableArray array];
        
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSEnumerator *charEnumerator = [[superChar.superCharacteristicOf sortedArrayUsingDescriptors:descriptors] objectEnumerator];
        
        while ((characteristic = [charEnumerator nextObject]) != nil) {
            
            //add characteristic to characteristic array
            [characteristicsOfSuperchar addObject:characteristic.name];
            
            //add characteristic value to array
            [valueOfCharacteristics addObject:[SmartSourceFunctions getHighMediumLowStringForFloatValue:[characteristic.value floatValue]]];
        }
        
        //add array of characteristics to characteristics array
        [usedChars addObject:characteristicsOfSuperchar];
        [valueChars addObject:valueOfCharacteristics];
        
        
    }
    
    
    
    self.superChars = [NSArray arrayWithObjects:[usedSuperChars copy], [valueSuperChars copy], nil];
    self.chars = [NSArray arrayWithObjects:[usedChars copy], [valueChars copy], nil];
    
    [self.componentEvaluationTableView reloadData];
    
    
}


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
	// Do any additional setup after loading the view.
    [self.componentEvaluationTableView setDataSource:self];
    [self.componentEvaluationTableView setDelegate:self];
    
    //backbutton
    [self.backButton setViewToChangeIfSelected:self.backButtonBackground];
    
    //rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //if device orientation is portrait, handle it
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self deviceOrientationDidChange:nil];
    }
    
    //set labels
    [self updateLabelsFromModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
        
        [self.projectInfoSubView setFrame:projectInfoRect];
        [self.componentInfoSubview setFrame:componentInfoRect];
        [self.componentEvaluationSubview setFrame:componentEvaluationRect];
        
        
        
        [self.view setNeedsDisplay];
        
    }
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        
        //projectinfo and component info subviews left of evaluationsubview
        //single values
        CGFloat widthOfAllViews = ((self.view.frame.size.width - 60) / 2);
        CGFloat heightOfEvaluationView = (self.view.frame.size.height - 110);
        CGFloat proportionProjectComponentInfo = 0.3;
        CGFloat heightOfProjectInfoView = (heightOfEvaluationView * proportionProjectComponentInfo);
        CGFloat heightOfComponentInfoView = ((heightOfEvaluationView * (1-proportionProjectComponentInfo)) - 20);
        
        
        //rects
        CGRect projectInfoRect = CGRectMake(20, 90, widthOfAllViews, heightOfProjectInfoView);
        CGRect componentInfoRect = CGRectMake(20, (110 + heightOfProjectInfoView), widthOfAllViews, heightOfComponentInfoView);
        CGRect componentEvaluationRect = CGRectMake((40 + widthOfAllViews), 90, widthOfAllViews, heightOfEvaluationView);
        
        [self.projectInfoSubView setFrame:projectInfoRect];
        [self.componentInfoSubview setFrame:componentInfoRect];
        [self.componentEvaluationSubview setFrame:componentEvaluationRect];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProjectInfoSubView:nil];
    [self setComponentEvaluationSubview:nil];
    [self setComponentInfoSubview:nil];
    [self setComponentEvaluationTableView:nil];
    [self setProjectNameLabel:nil];
    [self setComponentNameLabel:nil];
    [self setComponentPriorityLabel:nil];
    [self setComponentLastModifierLabel:nil];
    [self setComponentEstimatedHoursLabel:nil];
    [self setProjectDescriptionTextView:nil];
    [self setComponentDescriptionTextView:nil];
    [super viewDidUnload];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of used supercharacteristics +1
    NSArray *usedSuperChars = [self.superChars objectAtIndex:0];
    return [usedSuperChars count];//+1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *usedCharacteristics = [self.chars objectAtIndex:0];
    return ([[usedCharacteristics objectAtIndex:section] count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //header cell
    if (indexPath.row == 0) {
        
        static NSString *CellIdentifier = @"headerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag:20];
        NSArray *usedSuperChars = [self.superChars objectAtIndex:0];
        [textLabel setText:[usedSuperChars objectAtIndex:indexPath.section]];
        
        return cell;
        
        
    //info cell
    } else {
        
        static NSString *CellIdentifier = @"infoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        //set text label to characteristic's name
        NSArray *usedCharacteristics = [self.chars objectAtIndex:0];
        [cell.textLabel setFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:cell.detailTextLabel.font.pointSize]];
        
        //set detail text label to characteristic's value
        NSArray *valueOfCharacteristics = [self.chars objectAtIndex:1];
        
        NSInteger row = indexPath.row -1;
        cell.detailTextLabel.text = [[valueOfCharacteristics objectAtIndex:indexPath.section] objectAtIndex:row];
        [cell.detailTextLabel setTextColor:[SmartSourceFunctions getColorForStringRatingValue:cell.detailTextLabel.text]];
        cell.textLabel.text = [[usedCharacteristics objectAtIndex:indexPath.section] objectAtIndex:row];
        
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








#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



@end

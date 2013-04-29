//
//  ClassificationExplanationViewController.m
//  SmartSource
//
//  Created by Lorenz on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ClassificationExplanationViewController.h"
#import "Component.h"
#import "SuperCharacteristic.h"
#import "Characteristic.h"
#import <QuartzCore/QuartzCore.h>
#import "Slider.h"

@interface ClassificationExplanationViewController ()
@property (strong, nonatomic) ClassificationModel *resultModel;
@property (strong, nonatomic) NSArray *views;

@property (strong, nonatomic) NSArray *superChars;
@property (strong, nonatomic) NSArray *chars;


@property (nonatomic) float totalWeightOfSuperCharacteristics;
@property (nonatomic) float weightedSumOfSuperCharacteristics;
@property (nonatomic, strong) NSArray *valuesOfSuperCharacteristics;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;


@end

@implementation ClassificationExplanationViewController
@synthesize superChars = _superChars;
@synthesize chars = _chars;
@synthesize totalWeightOfSuperCharacteristics = _totalWeightOfSuperCharacteristics;
@synthesize views = _views;
@synthesize weightedSumOfSuperCharacteristics = _weightedSumOfSuperCharacteristics;
@synthesize valuesOfSuperCharacteristics = _valuesOfSuperCharacteristics;
@synthesize resultModel = _resultModel;
@synthesize masterPopoverController = _masterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)handleSwipeRightFrom:(UISwipeGestureRecognizer *)swipe
{
    NSLog(@"recieved");
    if ([self.view isEqual:[self.views objectAtIndex:1]]) {
            NSLog(@"goto First");
            [self toFirst];
        } else if ([self.view isEqual:[self.views objectAtIndex:2]]) {
            NSLog(@"goto Second");
            [self toSecond];
        }
}

- (void)handleSwipeLeftFrom:(UISwipeGestureRecognizer *)swipe
{
    NSLog(@"recieved");
    if ([self.view isEqual:[self.views objectAtIndex:0]]) {
        NSLog(@"goto Second");
        [self toSecond];
    } else if ([self.view isEqual:[self.views objectAtIndex:1]]) {
        NSLog(@"goto Third");
        [self toThird];
    }
    
    
}

- (void)viewDidLoad
{

    
    //frame of the screen
    CGRect frameOfScreen = self.navigationController.view.frame;

    //build views to put into the scroll view
    UIView *first = [self buildFirstScreen];
    UIView *second = [self buildSecondScreen];
    UIView *third = [self buildThirdScreen];
    
    
    
    
    

    
    /*
    //build scrollview with views and add it
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameOfScreen.size.height, frameOfScreen.size.width)];
    scroll.contentSize = CGSizeMake(frameOfScreen.size.height, first.frame.size.height);
    scroll.scrollEnabled = YES;
    scroll.showsHorizontalScrollIndicator = YES;
    scroll.bounces = NO;
    [scroll addSubview:first];
    
    [self.view addSubview:scroll];
    */
    self.view = first;
    
    
    
    self.views = [NSArray arrayWithObjects:self.view, second, third, nil];

    
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    

    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setComponent:(NSString *)componentID andModel:(ClassificationModel *)model
{
    //set model
    self.resultModel = model;
    NSArray *returnedValues = [self.resultModel getCharsAndValuesArray:componentID];
    self.superChars = [returnedValues objectAtIndex:0];
    self.chars = [returnedValues objectAtIndex:1];

    
}





//builds first screen for scroll view - first screen contains all supercharacteristics with their subcharacteristics and the calculations of averages
- (UIView *)buildFirstScreen
{
    //init the view to put on screen
    UIView *viewToPut = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 770, 100+([[self.superChars objectAtIndex:0] count]*250))];
    [viewToPut setContentMode:UIViewContentModeScaleAspectFit];
    [viewToPut setBackgroundColor:[UIColor whiteColor]];
    
    //initialize the weighted sum of supercharacteristics <=> end rating
    float weightedSumOfSupercharacteristics = 0.0;
    
    //build nextScreen-Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.text = @"Next Screen";
    [button setFrame:CGRectMake(self.navigationController.visibleViewController.view.frame.size.width-100, 0, 50, self.navigationController.visibleViewController.view.frame.size.height)];
    [button setImage:[UIImage imageNamed:@"forward.jpg"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toSecond) forControlEvents:UIControlEventTouchUpInside];
    [viewToPut addSubview:button];
    
    //descriotion headers
    UILabel *ratingDesc = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 400, 50)];
    [ratingDesc setContentMode:UIViewContentModeTop];
    [ratingDesc setNumberOfLines:0];
    [ratingDesc setText:@"Rating entered by user:"];
    [viewToPut addSubview:ratingDesc];
    
    UILabel *averageDescr = [[UILabel alloc] initWithFrame:CGRectMake(440, 20, 100, 50)];
    [averageDescr setContentMode:UIViewContentModeTop];
    [averageDescr setNumberOfLines:0];
    [averageDescr setText:@"Average:"];
    [viewToPut addSubview:averageDescr];
    
    
    //initiate array for the average values of the superchars
    NSMutableArray *valuesOfSuperchars = [NSMutableArray array];
    
    //for each supercharacteristic, add a tableview that contains its subcharacteristics and a label that presents its value
    for (int i=0; i<[[self.superChars objectAtIndex:0] count]; i++) {
        
        //table views
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(20, 70+(i*250), 400, 200) style:UITableViewStylePlain];
        [view setTag:(i+1)];
        [view setUserInteractionEnabled:NO];
        [view setDataSource:self];
        [viewToPut addSubview:view];
        
        //text labels
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(440, 90+(i*250), 200, 25)];
        [label setContentMode:UIViewContentModeTop];
        [label setBackgroundColor:[self getRGBForIndex:i]];
        [label setNumberOfLines:0];
        
        //calculate the sum of all weights of supercharacteristics
        float totalWeightOfSupercharacteristics = 0.0;
        for (int i=0; i<[[self.superChars objectAtIndex:1] count]; i++) {
            totalWeightOfSupercharacteristics += [[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue];
        }
        self.totalWeightOfSuperCharacteristics = totalWeightOfSupercharacteristics;
        
        //array with all values of subcharacteristics that belong to the current supercharacteristic
        NSArray *subCharacteristicsValues = [[self.chars objectAtIndex:1] objectAtIndex:i];
        float sum = 0.0;
        
        //add all values
        for (int y=0; y<[subCharacteristicsValues count]; y++) {
            sum = sum + [[subCharacteristicsValues objectAtIndex:y] floatValue];
        }
        
        //devide the sum by the number of characteristics --> average and extract the rating of the supercharacteristic
        float superCharValue = sum/[subCharacteristicsValues count];
        
        //high, medium or low
        if (superCharValue < 1.67) {
            label.text = [@"Rated Low - Ø=" stringByAppendingString:[NSString stringWithFormat: @"%.2f", superCharValue]];
        } else if (superCharValue < 2.34) {
            label.text = [@"Rated Medium - Ø=" stringByAppendingString:[NSString stringWithFormat: @"%.2f", superCharValue]];
        } else if (superCharValue <= 3.0) {
            label.text = [@"Rated High - Ø=" stringByAppendingString:[NSString stringWithFormat: @"%.2f", superCharValue]];      
        }
        
        //add text label with supercharacteristic's rating
        [label sizeToFit];
        [viewToPut addSubview:label];
        NSNumber *number = [NSNumber numberWithFloat:superCharValue];
        [valuesOfSuperchars addObject:number];
        UIView *sliderView = [self buildHighLowSliderView:superCharValue];
        sliderView.frame = CGRectMake(440, 120+(i*250), label.frame.size.width, label.frame.size.height);
        [viewToPut addSubview:sliderView];
        
        
        //add the weighted value to the end rating value
        weightedSumOfSupercharacteristics += ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue]/self.totalWeightOfSuperCharacteristics) * superCharValue;
    }
    
    
    self.weightedSumOfSuperCharacteristics = weightedSumOfSupercharacteristics;
    self.valuesOfSuperCharacteristics = [valuesOfSuperchars copy];
    
    //add swipe recongizer
    UISwipeGestureRecognizer *recognizerLeftFirst = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    [recognizerLeftFirst setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [viewToPut addGestureRecognizer:recognizerLeftFirst];
    
    
    
    return viewToPut;
    
}


//build second screen - second screen contains the calculation of the components end value by adding the weighted averages
- (UIView *)buildSecondScreen
{
    
    //frame of the screen
    CGRect frameOfScreen = self.navigationController.view.frame;
    
    //init the view to put on screen
    UIView *viewToPut = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameOfScreen.size.width, frameOfScreen.size.height)];
    [viewToPut setBackgroundColor:[UIColor whiteColor]];
    [viewToPut setContentMode:UIViewContentModeScaleAspectFit];
    
    //swipe recognizer
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toThird)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [viewToPut addGestureRecognizer:rightRecognizer];
    
    //build nextScreen-Button and back-Button
    UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
    next.titleLabel.text = @"Next Screen";
    [next setFrame:CGRectMake(self.navigationController.visibleViewController.view.frame.size.width-100, 0, 50, self.navigationController.visibleViewController.view.frame.size.height)];
    [next setImage:[UIImage imageNamed:@"forward.jpg"] forState:UIControlStateNormal];
    [next addTarget:self action:@selector(toThird) forControlEvents:UIControlEventTouchUpInside];
    [viewToPut addSubview:next];
    
    //build back-Button
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.titleLabel.text = @"Next Screen";
    [back setFrame:CGRectMake(0, 0, 50, self.navigationController.visibleViewController.view.frame.size.height)];
    [back addTarget:self action:@selector(toFirst) forControlEvents:UIControlEventTouchUpInside];
    [back setImage:[UIImage imageNamed:@"back.jpg"] forState:UIControlStateNormal];
    [viewToPut addSubview:back];
    
    
    //header description labels
    UILabel *descr1 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 400, 50)];
    [descr1 setContentMode:UIViewContentModeTop];
    [descr1 setNumberOfLines:0];
    [descr1 setText:@"Average Values of Supercharacteristics"];
    [viewToPut addSubview:descr1];
     
    UILabel *descr2 = [[UILabel alloc] initWithFrame:CGRectMake(470, 20, 150, 50)];
    [descr2 setContentMode:UIViewContentModeTop];
    [descr2 setNumberOfLines:0];
    [descr2 setText:@" * Relative Weight"];
    [viewToPut addSubview:descr2];
    
    //number formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundUp];


    
    //iterate the superchars and build text labels for the average values
    for (int i=0; i<[[self.superChars objectAtIndex:0] count]; i++) {
        
        //text labels for average values
        UILabel *averageValue = [[UILabel alloc] initWithFrame:CGRectMake(70, 70+(i*100), 400, 50)];
        [averageValue setContentMode:UIViewContentModeTop];
        [averageValue setBackgroundColor:[self getRGBForIndex:i]];
        [averageValue setNumberOfLines:0];
        NSString *value = [formatter stringFromNumber:[self.valuesOfSuperCharacteristics objectAtIndex:i]];
        [averageValue setText:[[[[self.superChars objectAtIndex:0] objectAtIndex:i] stringByAppendingString:@" - Average Value: "] stringByAppendingString:value]];
        [viewToPut addSubview:averageValue];
        
        //text labels for relative weight
        UILabel *relativeWeight = [[UILabel alloc] initWithFrame:CGRectMake(480, 70+(i*100), 50, 50)];
        [relativeWeight setContentMode:UIViewContentModeTop];
        [relativeWeight setBackgroundColor:[self getRGBForIndex:i]];
        [relativeWeight setNumberOfLines:0];
        relativeWeight.text = [[[[@" * " stringByAppendingString:[[[self.superChars objectAtIndex:1] objectAtIndex:i] stringValue]] stringByAppendingString:@"/"] stringByAppendingString:[[NSNumber numberWithFloat:self.totalWeightOfSuperCharacteristics] stringValue]] stringByAppendingString:@" "];
        [viewToPut addSubview:relativeWeight];
        
        //text labels for product of average values and relative weight
        UILabel *product = [[UILabel alloc] initWithFrame:CGRectMake(540, 70+(i*100), 80, 50)];
        [product setContentMode:UIViewContentModeTop];
        [product setBackgroundColor:[self getRGBForIndex:i]];
        [product setNumberOfLines:0];
        float weightedValue = ([[[self.superChars objectAtIndex:1] objectAtIndex:i] floatValue] / self.totalWeightOfSuperCharacteristics)*[[self.valuesOfSuperCharacteristics objectAtIndex:i] floatValue];
        product.text = [@" = " stringByAppendingString:[NSString stringWithFormat: @"%.2f", weightedValue]];
        [viewToPut addSubview:product];
        
        
        
    }
    
    //line view for sum
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(440, 50 + ([[self.superChars objectAtIndex:0] count] * 100), 200, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [viewToPut addSubview:lineView];
    
    //description label
    UILabel *descr3 = [[UILabel alloc] initWithFrame:CGRectMake(250, 60 + ([[self.superChars objectAtIndex:0] count] * 100), 220, 50)];
    [descr3 setContentMode:UIViewContentModeTop];
    [descr3 setNumberOfLines:0];
    [descr3 setText:@"Sum of weighted averages:"];
    [viewToPut addSubview:descr3];
    
    
    //label with sum
    UILabel *sum = [[UILabel alloc] initWithFrame:CGRectMake(540, 60 + ([[self.superChars objectAtIndex:0] count] * 100) , 50, 50)];
    [sum setContentMode:UIViewContentModeTop];
    [sum setNumberOfLines:0];
    [sum setText:[@" = " stringByAppendingString:[NSString stringWithFormat: @"%.2f", self.weightedSumOfSuperCharacteristics]]];
    [viewToPut addSubview:sum];
    
    
    //slider
    UIView *slider = [self buildABCSliderView:self.weightedSumOfSuperCharacteristics];
    [slider setFrame:CGRectMake(480, 110 + ([[self.superChars objectAtIndex:0] count] * 100) , 200, 50)];
    [viewToPut addSubview:slider];
    
    //swipe recognizer
    UISwipeGestureRecognizer *recognizerRightSecond = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    [recognizerRightSecond setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [viewToPut addGestureRecognizer:recognizerRightSecond];
    
    UISwipeGestureRecognizer *recognizerLeftSecond = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    [recognizerLeftSecond setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [viewToPut addGestureRecognizer:recognizerLeftSecond];
    
    return viewToPut;
}



- (UIView *)buildThirdScreen
{
    
    //frame of the screen
    CGRect frameOfScreen = self.navigationController.view.frame;
    
    //init the view to put on screen
    UIView *viewToPut = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameOfScreen.size.width, frameOfScreen.size.height)];
    [viewToPut setContentMode:UIViewContentModeScaleAspectFit];
    [viewToPut setBackgroundColor:[UIColor whiteColor]];
    

    //build back-Button
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.titleLabel.text = @"Next Screen";
    [back setFrame:CGRectMake(0, 0, 50, self.navigationController.visibleViewController.view.frame.size.height)];
    [back addTarget:self action:@selector(toSecond) forControlEvents:UIControlEventTouchUpInside];
    [back setImage:[UIImage imageNamed:@"back.jpg"] forState:UIControlStateNormal];
    [viewToPut addSubview:back];

    
    //description label
    UILabel *descr3 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 220, 50)];
    [descr3 setContentMode:UIViewContentModeTop];
    [descr3 setNumberOfLines:0];
    [descr3 setText:@"Sum of weighted averages:"];
    [viewToPut addSubview:descr3];
    
    
    //label with sum
    UILabel *sum = [[UILabel alloc] initWithFrame:CGRectMake(70, 80 , 200, 50)];
    [sum setContentMode:UIViewContentModeTop];
    [sum setNumberOfLines:0];
    [sum setText:[NSString stringWithFormat: @"%.2f", self.weightedSumOfSuperCharacteristics]];
    [sum setTextAlignment:UITextAlignmentCenter];
    sum.layer.borderColor = [UIColor blackColor].CGColor;
    sum.layer.borderWidth = 3.0;
    [viewToPut addSubview:sum];
    
    
    //slider
    UIView *slider = [self buildABCSliderView:self.weightedSumOfSuperCharacteristics];
    [slider setFrame:CGRectMake(300, 80 , 200, 50)];
    [viewToPut addSubview:slider];
    
    //text labels with end rating of component
    UILabel *ratingHeader = [[UILabel alloc] initWithFrame:CGRectMake(150, 200, 300, 50)];
    [ratingHeader setContentMode:UIViewContentModeCenter];
    [ratingHeader setTextAlignment:UITextAlignmentCenter];
    [ratingHeader setFont:[UIFont fontWithName:@"American Typewriter" size:20]];
    [ratingHeader setText:@"Component Classification:"];
    [viewToPut addSubview:ratingHeader];
    
    UILabel *end = [[UILabel alloc] initWithFrame:CGRectMake(150, 260, 300, 150)];
    [end setContentMode:UIViewContentModeCenter];
    [end setTextAlignment:UITextAlignmentCenter];
    end.layer.borderColor = [UIColor blackColor].CGColor;
    end.layer.borderWidth = 3.0;
    [end setFont:[UIFont fontWithName:@"American Typewriter" size:120]];
    
    
    
    
    //prepare output
    NSString *classification = @"";
    NSString *weightedAverage = @"";
    NSString *message = @"";
    if (self.weightedSumOfSuperCharacteristics < 1.67) {
        classification = @"C";
        weightedAverage = @"Low";
        message = @"The Component is likely to be outsourced.";
    } else if (self.weightedSumOfSuperCharacteristics < 2.34) {
        classification = @"B";
        weightedAverage = @"Medium";
        message = @"Sourcing location indifferent: In-house preferred but outsourcing possible.";
    } else if (self.weightedSumOfSuperCharacteristics <= 3.1) {
        classification = @"A";
        weightedAverage = @"High";
        message = @"It is a Core Component and likely to be kept in-house.";
        
    }
    
    UILabel *diagnosis = [[UILabel alloc] initWithFrame:CGRectMake(150, 410, 300, 200)];
    [diagnosis setContentMode:UIViewContentModeCenter];
    [diagnosis setTextAlignment:UITextAlignmentCenter];
    [diagnosis setFont:[UIFont fontWithName:@"American Typewriter" size:20]];
    [diagnosis setText:message];
    [diagnosis setNumberOfLines:0];
    [viewToPut addSubview:diagnosis];
    
    //put output into the label and put label on screen
    [end setText:classification];
    [viewToPut addSubview:end];
    
    
    //swipe
    UISwipeGestureRecognizer *recognizerRightThird = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    [recognizerRightThird setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [viewToPut addGestureRecognizer:recognizerRightThird];
    
    
    
    return viewToPut;
}




//methods, that switch the displayed screen to first, second or third
- (void)toSecond
{
    self.view = [self.views objectAtIndex:1];
    
}

- (void)toThird
{
    self.view = [self.views objectAtIndex:2];
}

- (void)toFirst
{
    self.view = [self.views objectAtIndex:0];
}


//builds the same color as used in the chart
//index: -0 for Component A -1 for Component B -2 for Component c
- (UIColor *)getRGBForIndex:(int)index {

    
    int i = 6 - index;
    float red = 0.5 + 0.5 * cos(i);
	float green = 0.5 + 0.5 * sin(i);
    float blue = 0.5 + 0.5 * cos(1.5 * i + M_PI / 4.0);
    
    UIColor *color = [UIColor colorWithRed:1 green:green blue:0 alpha:0.3];
    return color;
	
}


- (UIView *)buildHighLowSliderView:(float)value
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    [slider setUserInteractionEnabled:NO];
    [slider setMaximumValue:3.0];
    [slider setMinimumValue:1.0];
    [slider setMinimumTrackTintColor:[UIColor darkGrayColor]];
    [slider setMaximumTrackTintColor:[UIColor darkGrayColor]];
    slider.value = value;
    
    [view addSubview:slider];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 25, 25)];
    [label1 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label1 setTextAlignment:UITextAlignmentLeft];
    [label1 setText:@"|"];
    [view addSubview:label1];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 25, 25)];
    [label4 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label1 setTextAlignment:UITextAlignmentLeft];
    [label4 setText:@"L"];
    [view addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 25, 25)];
    [label5 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label5 setTextAlignment:UITextAlignmentLeft];
    [label5 setText:@"|"];
    [view addSubview:label5];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(75, 25, 23, 25)];
    [label2 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label2 setTextAlignment:UITextAlignmentLeft];
    [label2 setText:@"M"];
    [view addSubview:label2];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 25, 25)];
    [label6 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label6 setTextAlignment:UITextAlignmentLeft];
    [label6 setText:@"|"];
    [view addSubview:label6];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(125, 25, 25, 25)];
    [label3 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label3 setTextAlignment:UITextAlignmentLeft];
    [label3 setText:@"H"];
    [view addSubview:label3];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(150, 25, 10, 25)];
    [label7 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label7 setTextAlignment:UITextAlignmentLeft];
    [label7 setText:@"|"];
    [view addSubview:label7];
    return view;
}



- (UIView *)buildABCSliderView:(float)value
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    [slider setUserInteractionEnabled:NO];
    [slider setMaximumValue:3.0];
    [slider setMinimumValue:1.0];
    [slider setMinimumTrackTintColor:[UIColor darkGrayColor]];
    [slider setMaximumTrackTintColor:[UIColor darkGrayColor]];
    slider.value = value;
    
    [view addSubview:slider];
    
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 25, 25)];
    [label1 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label1 setTextAlignment:UITextAlignmentLeft];
    [label1 setText:@"|"];
    [view addSubview:label1];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 25, 25)];
    [label4 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label1 setTextAlignment:UITextAlignmentLeft];
    [label4 setText:@"C"];
    [view addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 25, 25)];
    [label5 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label5 setTextAlignment:UITextAlignmentLeft];
    [label5 setText:@"|"];
    [view addSubview:label5];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(75, 25, 23, 25)];
    [label2 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label2 setTextAlignment:UITextAlignmentLeft];
    [label2 setText:@"B"];
    [view addSubview:label2];
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 25, 25)];
    [label6 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label6 setTextAlignment:UITextAlignmentLeft];
    [label6 setText:@"|"];
    [view addSubview:label6];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(125, 25, 25, 25)];
    [label3 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label3 setTextAlignment:UITextAlignmentLeft];
    [label3 setText:@"A"];
    [view addSubview:label3];
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(150, 25, 10, 25)];
    [label7 setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
    [label7 setTextAlignment:UITextAlignmentLeft];
    [label7 setText:@"|"];
    [view addSubview:label7];
    
    return view;
    
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag != 99) {
        if ([[self.superChars objectAtIndex:0] count] > 0) {
            return [[self.superChars objectAtIndex:0] objectAtIndex:(tableView.tag-1)];
        } else {
            return 0;
        }
    } else {
        return @"Weight of Supercharacteristics";
    }
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag != 99) {
        if ([[self.chars objectAtIndex:0] count] > 0) {
            return [[[self.chars objectAtIndex:0] objectAtIndex:(tableView.tag-1)] count];
        } else {
            return 0;
        }
    } else {
        return [[self.superChars objectAtIndex:0] count];
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag != 99) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = [[[self.chars objectAtIndex:0] objectAtIndex:(tableView.tag-1)] objectAtIndex:indexPath.row];
        
        UIColor *color = [self getRGBForIndex:(tableView.tag-1)];
        [cell.contentView setBackgroundColor:color];
        [cell.textLabel setBackgroundColor:color];
        [cell.detailTextLabel setBackgroundColor:color];
        
        float charValue = [[[[self.chars objectAtIndex:1] objectAtIndex:(tableView.tag-1)] objectAtIndex:indexPath.row] floatValue];
        
        if (charValue < 1.67) {
            cell.detailTextLabel.text = @"Low";
        } else if (charValue < 2.34) {
            cell.detailTextLabel.text = @"Medium";
        } else if (charValue <= 3.0) {
            cell.detailTextLabel.text = @"High";
        }
        
        
        [tableView sizeToFit];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        
        cell.textLabel.text = [[self.superChars objectAtIndex:0] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[[[[self.superChars objectAtIndex:1] objectAtIndex:indexPath.row] stringValue] stringByAppendingString:@"/"] stringByAppendingString:[[NSNumber numberWithFloat:self.totalWeightOfSuperCharacteristics] stringValue]];
        
        UIColor *color = [self getRGBForIndex:indexPath.row];
        [cell.contentView setBackgroundColor:color];
        [cell.textLabel setBackgroundColor:color];
        [cell.detailTextLabel setBackgroundColor:color];
        
        [tableView sizeToFit];

        return cell;
    }
 
    
    
}





@end

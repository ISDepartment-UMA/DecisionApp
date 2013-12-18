//
//  ResultTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DecisionTableViewController.h"
#import "Project.h"
#import "Component.h"
#import "SuperCharacteristic.h"
#import "Characteristic.h"
#import "SmartSourceSplitViewController.h"
#import "SmartSourceAppDelegate.h"
#import "VeraRomanLabel.h"
#import "VeraBoldLabel.h"
#import "ComponentModel.h"
#import "SmartSourceFunctions.h"
#import "ButtonExternalBackground.h"

@interface DecisionTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ProjectModel *projectModel;
@property (strong, nonatomic) NSArray *columns;

//string values of superchars nameOfSuperChar -> valueOfSuperChar (high, medium or low)
@property (strong, nonatomic) NSDictionary *valuesOfSuperCharsComponent;
@property (strong, nonatomic) ComponentModel *componentModel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackground;
@end

@implementation DecisionTableViewController
@synthesize columns = _columns;
@synthesize projectModel = _projectModel;
@synthesize tableView = _tableView;
@synthesize valuesOfSuperCharsComponent = _valuesOfSuperCharsComponent;
@synthesize componentModel = _componentModel;
@synthesize backButton = _backButton;
@synthesize backButtonBackground = _backButtonBackground;

#pragma mark Inherited methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    //backbutton
    [self.backButton setViewToChangeIfSelected:self.backButtonBackground];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //get columns from model
    self.columns = [self.projectModel getColumnsForDecisionTable];
}

#pragma mark IBActions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Getters & Setters

/*
 *  method to set the component that should be integrated into the decision table
 */
- (void)markComponentAsSelected:(Component *)component
{
    //init component model
    self.componentModel = [[ComponentModel alloc] initWithComponentId:component.componentID];
    //get superchar values
    NSMutableDictionary *superCharValueDic = [[self.componentModel getDictionaryWithSuperCharValues] mutableCopy];
    
    //extract dictionary with string values of superchars --> high, medium or low
    NSEnumerator *superCharNameEnumerator = [superCharValueDic keyEnumerator];
    NSString *superCharName;
    NSMutableDictionary *superCharValueDicNew = [NSMutableDictionary dictionary];
    while ((superCharName = (NSString *)[superCharNameEnumerator nextObject]) != nil) {
        float superCharValue = [[superCharValueDic objectForKey:superCharName] floatValue];
        NSString *stringValue = [SmartSourceFunctions getHighMediumLowStringForFloatValue:superCharValue];
        [superCharValueDicNew setObject:stringValue forKey:superCharName];
    }
    //save dictionary with string values of superchars
    self.valuesOfSuperCharsComponent = [superCharValueDicNew copy];
    [self.tableView reloadData];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self.columns objectAtIndex:0] objectAtIndex:2] count];
    
}

//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //header....
    if (indexPath.row == 0) {
        //header cell in first row
        static NSString *CellIdentifier = @"headerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        VeraBoldLabel *superCharTitleLabel = (VeraBoldLabel *)[cell viewWithTag:20];
        //names of supercharacteristics in header cell
        for (int i=0; i<([self.columns count] -1); i++) {
            VeraBoldLabel *superCharTitleLabelCopy = [superCharTitleLabel copy];
            [superCharTitleLabelCopy setFrame:CGRectMake((20 + (155 * i)), 5, 150, 40)];
            [superCharTitleLabelCopy setTag:(i+1)];
            [superCharTitleLabelCopy setText:[[self.columns objectAtIndex:i] objectAtIndex:0]];
            [cell.contentView addSubview:superCharTitleLabelCopy];
        }
        //remove title label
        [superCharTitleLabel removeFromSuperview];
        //move weighted value label
        VeraBoldLabel *weightedValueLabel = (VeraBoldLabel *)[cell viewWithTag:21];
        [weightedValueLabel setFrame:CGRectMake((25 + (155 * ([self.columns count]-1))), 5, 150, 40)];
        return cell;
        
    //content....
    } else {
        static NSString *CellIdentifier = @"contentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        VeraRomanLabel *superCharValueLabel = (VeraRomanLabel *)[cell viewWithTag:20];
        
        //values in content cells
        for (int i=0; i < ([self.columns count]-1); i++) {
            //copy value label
            VeraBoldLabel *superCharValueLabelCopy = [superCharValueLabel copy];
            [superCharValueLabelCopy setFrame:CGRectMake((20 + (155 * i)), 5, 150, 40)];
            [superCharValueLabelCopy setTag:(i+1)];
            //combination of possible ratings
            int rating = [[[[self.columns objectAtIndex:i] objectAtIndex:2] objectAtIndex:(indexPath.row-1)] intValue];
            
            //set valueString and color of Supercharsubstantiation
            [superCharValueLabelCopy setText:[SmartSourceFunctions getHighMediumLowStringForIntValue:rating]];
            [superCharValueLabelCopy setTextColor:[SmartSourceFunctions getColorForStringRatingValue:superCharValueLabelCopy.text]];
            [cell.contentView addSubview:superCharValueLabelCopy];
        }
        //remove superCharValue template
        [superCharValueLabel removeFromSuperview];
        
        //weighted value
        VeraBoldLabel *weightedValue = (VeraBoldLabel *)[cell viewWithTag:21];
        [weightedValue setFrame:CGRectMake((25 + (155 * ([self.columns count]-1))), 5, 150, 40)];
        //stringValue and color
        [weightedValue setText:[[[self.columns lastObject] objectAtIndex:2] objectAtIndex:(indexPath.row-1)]];
        [weightedValue setTextColor:[SmartSourceFunctions getColorForStringClassificationValue:weightedValue.text]];
        
        /*
         *  insert selected component if it exists
         */
        if (self.valuesOfSuperCharsComponent) {
            //check if this cell's combination of supercharacteristics is the right one
            BOOL allSuperCharacteristicsValuesTheSame = YES;
            for (int i=0; i<([self.columns count] -1); i++) {
                NSString *nameOfSuperChar = [[self.columns objectAtIndex:i] objectAtIndex:0];
                NSString *valueOfSuperCharForSelectedComponent = [self.valuesOfSuperCharsComponent objectForKey:nameOfSuperChar];
                CGFloat rating = [[[[self.columns objectAtIndex:i] objectAtIndex:2] objectAtIndex:(indexPath.row-1)] floatValue];
                NSString *valueOfSuperCharInThisCell = [SmartSourceFunctions getHighMediumLowStringForFloatValue:rating];
                if (![valueOfSuperCharForSelectedComponent isEqualToString:valueOfSuperCharInThisCell]) {
                    allSuperCharacteristicsValuesTheSame = NO;
                    break;
                }
            }
            
            //if all values of supercharacteristics are the same
            UILabel *componentLabel = (UILabel *)[cell viewWithTag:22];
            if (allSuperCharacteristicsValuesTheSame) {
                //mark cell as selected
                [componentLabel setText:[self.componentModel getComponentObject].name];
                CGFloat maximumlabelheight = componentLabel.frame.size.height;
                CGFloat maximumlabelwidth = cell.frame.size.width - (30 + (155 * ([self.columns count])));
                CGSize maximumLabelSize = CGSizeMake(maximumlabelwidth, maximumlabelheight);
                CGSize expectedLabelSize = [[self.componentModel getComponentObject].name sizeWithFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:15.0] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
                [componentLabel setFrame:CGRectMake((30 + (155 * ([self.columns count]))), 5, expectedLabelSize.width, 40)];
                [componentLabel setHidden:NO];
            //else remove component to ensure consistency when cells are reused
            } else if (componentLabel) {
                [componentLabel setHidden:YES];
            }
        }
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end

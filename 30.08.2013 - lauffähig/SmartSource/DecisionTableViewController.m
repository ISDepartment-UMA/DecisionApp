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

@interface DecisionTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *columns;
@property (strong, nonatomic) NSDictionary *valuesOfSuperCharsComponent;
@property (strong, nonatomic) ComponentModel *componentModel;
@end

@implementation DecisionTableViewController
@synthesize columns = _columns;
@synthesize projectModel = _projectModel;
@synthesize tableView = _tableView;
@synthesize valuesOfSuperCharsComponent = _valuesOfSuperCharsComponent;
@synthesize componentModel = _componentModel;






- (void)viewDidLoad
{
    [super viewDidLoad];
    //get context
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    

}

- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)markComponentAsSelected:(Component *)component
{
    self.componentModel = [[ComponentModel alloc] initWithComponent:component];
    NSMutableDictionary *superCharValueDic = [[self.componentModel getDictionaryWithSuperCharValues] mutableCopy];
    NSEnumerator *superCharNameEnumerator = [superCharValueDic keyEnumerator];
    NSString *superCharName;
    NSMutableDictionary *superCharValueDicNew = [NSMutableDictionary dictionary];
    while ((superCharName = (NSString *)[superCharNameEnumerator nextObject]) != nil) {
        
        float superCharValue = [[superCharValueDic objectForKey:superCharName] floatValue];
        NSString *stringValue = [SmartSourceFunctions getHighMediumLowStringForFloatValue:superCharValue];
        [superCharValueDicNew setObject:stringValue forKey:superCharName];
        
    }
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        
        [superCharTitleLabel removeFromSuperview];
        
        //move weighted value label
        VeraBoldLabel *weightedValueLabel = (VeraBoldLabel *)[cell viewWithTag:21];
        [weightedValueLabel setFrame:CGRectMake((25 + (155 * ([self.columns count]-1))), 5, 150, 40)];
        
        return cell;
        
        
        
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
            
            switch (rating) {
                case 1:
                    [superCharValueLabelCopy setText:@"LOW"];
                    [superCharValueLabelCopy setTextColor:[UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0]];
                    break;
                case 2:
                    [superCharValueLabelCopy setText:@"MEDIUM"];
                    [superCharValueLabelCopy setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0]];
                    
                    break;
                case 3:
                    [superCharValueLabelCopy setText:@"HIGH"];
                    [superCharValueLabelCopy setTextColor:[UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0]];
                default:
                    break;
            }
            
            [cell.contentView addSubview:superCharValueLabelCopy];
        }
        
        [superCharValueLabel removeFromSuperview];
        
        //weighted value
        VeraBoldLabel *weightedValue = (VeraBoldLabel *)[cell viewWithTag:21];
        [weightedValue setFrame:CGRectMake((25 + (155 * ([self.columns count]-1))), 5, 150, 40)];
        
        [weightedValue setText:[[[self.columns lastObject] objectAtIndex:2] objectAtIndex:(indexPath.row-1)]];
        if ([weightedValue.text isEqualToString:@"OUTSOURCING"]) {
            [weightedValue setTextColor:[UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0]];
        } else if ([weightedValue.text isEqualToString:@"INDIFFERENT"]) {
            [weightedValue setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0]];
        } else if ([weightedValue.text isEqualToString:@"CORE"]) {
            [weightedValue setTextColor:[UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0]];
        }
        
        if (self.valuesOfSuperCharsComponent) {
            
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
            
            if (allSuperCharacteristicsValuesTheSame) {
                //mark cell as selected
                UILabel *componentLabel = (UILabel *)[cell viewWithTag:22];
                [componentLabel setText:[self.componentModel getComponentObject].name];
                
                
                CGFloat maximumlabelheight = componentLabel.frame.size.height;
                CGFloat maximumlabelwidth = cell.frame.size.width - (30 + (155 * ([self.columns count])));
                CGSize maximumLabelSize = CGSizeMake(maximumlabelwidth, maximumlabelheight);
                CGSize expectedLabelSize = [[self.componentModel getComponentObject].name sizeWithFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:15.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
                [componentLabel setFrame:CGRectMake((30 + (155 * ([self.columns count]))), 5, expectedLabelSize.width, 40)];
                [componentLabel setHidden:NO];
                
            }
        }
    
        return cell;
        
        

        
        
    }
    
    
}



//RootViewController.m
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 50;
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

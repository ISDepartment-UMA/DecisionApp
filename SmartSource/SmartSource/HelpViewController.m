//
//  HelpViewController.m
//  SmartSource
//
//  Created by Lorenz on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (nonatomic, strong) NSArray *contactInformation;
@property (nonatomic, strong) NSArray *technicalIssues;
@property (strong, nonatomic) IBOutlet UILabel *contactTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *technicalIssuesTextLabel;

@end

@implementation HelpViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize contactInformation = _contactInformation;
@synthesize technicalIssues = _technicalIssues;
@synthesize contactTextLabel = _contactTextLabel;
@synthesize technicalIssuesTextLabel = _technicalIssuesTextLabel;



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
    [self.navigationController setNavigationBarHidden:NO];
    
    NSString *contactInformationString = @"Tommi Kramer\nUniversität Mannheim\nLehrstuhl für ABWL und Wirtschaftsinformatik\nL 15, 1-6 - Room 510\nD - 68161 Mannheim\nPhone: +49 621 181-1697";
    [self.contactTextLabel setText:contactInformationString];
    
    NSString *technicalIssuesString = @"Robert Lorenz Törmer\nUniversität Mannheim\nLehrstuhl für ABWL und Wirtschaftsinformatik";
    [self.technicalIssuesTextLabel setText:technicalIssuesString];
}


- (IBAction)sendEmailButtonPressed:(UIButton *)sender {
    
    if (sender.tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:kramer@uni-mannheim.de"]];
    } else if (sender.tag == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:rtoermer@students.uni-mannheim.de"]];
    }
}

- (void)viewDidUnload
{

    [super viewDidUnload];
    [self setTechnicalIssuesTextLabel:nil];
    [self setContactTextLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

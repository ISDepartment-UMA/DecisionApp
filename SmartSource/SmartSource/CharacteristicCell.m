//
//  CharacteristicCell.m
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import "CharacteristicCell.h"
#import "Characteristic+Factory.h"
#import "RatingTableViewViewController.h"
#import "SmartSourceAppDelegate.h"

@interface CharacteristicCell()

@property (nonatomic, strong) Characteristic *currentCharacteristic;
@property (nonatomic, weak) RatingTableViewViewController *delegate;

@end

@implementation CharacteristicCell

@synthesize currentCharacteristic = _currentCharacteristic;
@synthesize delegate = _delegate;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (CharacteristicCell *)initWithCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(RatingTableViewViewController *)delegate
{
    //set characteristic of the cell
    self.currentCharacteristic = currentCharacteristic;
    
    //set delegate
    self.delegate = delegate;
    
    
    //build cell
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"characteristicCell"];
    [self setFrame:CGRectMake(0, 0, 703, 44)];
    
    //name characteristic accordingly
    self.textLabel.text = currentCharacteristic.name;
    [self.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.textLabel setBounds:CGRectMake(0, 0, 50, 44)];
    
    
    
    //building buttons, textlabels and add them to cell
    //low has tag 1, medium tag 2, high tag 3
    
    //get the right value for the characteristic
    NSInteger value = [currentCharacteristic.value integerValue];
    
    //high
    CGRect HighButtonFrame = CGRectMake(500, 10, 50, 25);
    UIButton *highRadioButton = [self getRadioButton];
    [highRadioButton setFrame:HighButtonFrame];
    highRadioButton.tag = 3;
    if (value == 3) {
        highRadioButton.selected = YES;
    }
    [self.contentView addSubview:highRadioButton];
    CGRect highTextFrame = CGRectMake(550, 10, 50, 25);
    UILabel *highTextLabel = [[UILabel alloc] initWithFrame:highTextFrame];
    highTextLabel.text = @"high";
    [highTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:highTextLabel];
    
    //medium
    CGRect MediumButtonFrame = CGRectMake(350, 10, 50, 25);
    UIButton *mediumRadioButton = [self getRadioButton];
    [mediumRadioButton setFrame:MediumButtonFrame];
    mediumRadioButton.tag = 2;
    if (value == 2) {
        mediumRadioButton.selected = YES;
    }
    [self.contentView addSubview:mediumRadioButton];
    CGRect mediumTextFrame = CGRectMake(400, 10, 70, 25);
    UILabel *mediumTextLabel = [[UILabel alloc] initWithFrame:mediumTextFrame];
    mediumTextLabel.text = @"medium";
    [mediumTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:mediumTextLabel];
    
    //low
    CGRect LowButtonFrame = CGRectMake(250, 10, 50, 25);
    UIButton *lowRadioButton = [self getRadioButton];
    lowRadioButton.tag = 1;
    if (value == 1) {
        lowRadioButton.selected = YES;
    }
    [lowRadioButton setFrame:LowButtonFrame];
    [self.contentView addSubview:lowRadioButton];
    CGRect lowTextFrame = CGRectMake(300, 10, 50, 25);
    UILabel *lowTextLabel = [[UILabel alloc] initWithFrame:lowTextFrame];
    lowTextLabel.text = @"low";
    [lowTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:lowTextLabel];
    
    //set interaction style
    self.selectionStyle =UITableViewCellSelectionStyleNone;
    
    
    return self;
}

// building the radio button
- (UIButton *)getRadioButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"checkedbox.png"] forState:UIControlStateSelected];
    [button setFrame:CGRectMake(0, 0, 17, 17)];
    [button addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return button;
}


//checks the button and saves the state into the core database
//not clean
- (void)checkboxButton:(UIButton *)button
{
    //store in database
    self.currentCharacteristic.value = [NSNumber numberWithInt:button.tag];
    
    //check button
    //check for other buttons in the same cell and uncheck them
    for (UIButton *radiobutton in [button.superview subviews]) {
        if ([radiobutton isKindOfClass:[button class]] && ![radiobutton isEqual:button]) {
            [radiobutton setSelected:NO];
        }
    }
    
    //check the touched button
    if (!button.selected) {
        button.selected = !button.selected;
    }
    

    //savecontext
    [self.delegate saveContext];
    
    //check for completeness
    [self.delegate checkForCompleteness];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  CharacteristicCell.m
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import "CharacteristicCell.h"
#import "Characteristic.h"

@interface CharacteristicCell()
@property (nonatomic, strong) Characteristic *currentCharacteristic;
@property (nonatomic, weak) id<CharacteristicCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@end

@implementation CharacteristicCell
@synthesize currentCharacteristic = _currentCharacteristic;
@synthesize delegate = _delegate;
@synthesize mainSubView = _mainSubView;
@synthesize titleLabel = _titleLabel;


//main method to pass the characteristic to be displayed and set the delegate
- (void)setCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(id<CharacteristicCellDelegate>)delegate
{
    //set characteristic of the cell
    self.currentCharacteristic = currentCharacteristic;
    //set delegate
    self.delegate = delegate;
    //name characteristic accordingly
    self.titleLabel.text = currentCharacteristic.name;
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    //building buttons, textlabels and add them to cell
    //low has tag 1, medium tag 2, high tag 3
    //get the right value for the characteristic
    NSInteger value = [currentCharacteristic.value integerValue];
    //if characteristic has not been rated before, change the background color
    if (value == 0) {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.05];
    }
    UIView *evaluationView = [self viewWithTag:89];
    if (!evaluationView) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"EvaluationView" owner:self options:nil];
        evaluationView = [subviewArray objectAtIndex:0];
        [evaluationView setTag:89];
        [evaluationView setFrame:CGRectMake((self.mainSubView.frame.size.width - 400), 0, 400, 50)];
        [self addSubview:evaluationView];
    }
    for (int i=11; i<=13; i++) {
        UIView *subView = [evaluationView viewWithTag:i];
        UIButton *checkButton = (UIButton *)[subView viewWithTag:21];
        [checkButton addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageViewOfButton = (UIImageView *)[subView viewWithTag:22];
        if (value == (i-10)) {
            [imageViewOfButton setImage:[UIImage imageNamed:@"Checkbox-Selected.png"]];
        } else {
            [imageViewOfButton setImage:[UIImage imageNamed:@"Checkbox-not-Selected.png"]];
        }
    }
    //set interaction style
    self.selectionStyle =UITableViewCellSelectionStyleNone;
}

// building the radio button
- (UIButton *)getRadioButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"Checkbox-not-Selected.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Checkbox-Selected.png"] forState:UIControlStateSelected];
    [button setFrame:CGRectMake(0, 0, 22, 22)];
    [button addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//checks the button and saves the state into the core database
//not clean
- (void)checkboxButton:(UIButton *)button
{
    UIView *buttonsSuperView = button.superview;
    UIView *evaluationView = buttonsSuperView.superview;
    UIImageView *buttonImageView = (UIImageView *)[buttonsSuperView viewWithTag:22];
    [buttonImageView setImage:[UIImage imageNamed:@"Checkbox-Selected.png"]];
    
    //store in database
    NSInteger valueOfCharacteristic = buttonsSuperView.tag - 10;
    self.currentCharacteristic.value = [NSNumber numberWithInt:valueOfCharacteristic];
    
    for (int i=11; i<=13; i++) {
        if (i == buttonsSuperView.tag) {
            continue;
        } else {
            UIView *subView = [evaluationView viewWithTag:i];
            UIImageView *imageViewOfButton = (UIImageView *)[subView viewWithTag:22];
            [imageViewOfButton setImage:[UIImage imageNamed:@"Checkbox-not-Selected.png"]];
        }
    }
    //savecontext
    [self.delegate saveContext];
    //check for completeness
    [self.delegate checkForCompleteness];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end

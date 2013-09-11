//
//  RadioButton.m
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import "RadioButton.h"
#import "RatingTableViewViewController.h"

@interface RadioButton()

@property (nonatomic, strong) Characteristic *currentCharacteristic;
@property (nonatomic, strong) ComponentModel *componentModel;

@end
@implementation RadioButton

@synthesize currentCharacteristic = _currentCharacteristic;
@synthesize componentModel = _componentModel;

// building the radio button
- (RadioButton *)initWithCharacteristic:(Characteristic *)characteristic andComponentModel:(ComponentModel *)component
{
    self = [super init];
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    self.componentModel = component;

    
    [self setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"checkedbox.png"] forState:UIControlStateSelected];
    [self setFrame:CGRectMake(0, 0, 17, 17)];
    [self addTarget:component action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
    self.currentCharacteristic = characteristic;
    
    
    return self;
}

- (Characteristic *)getCurrentCharacteristic
{
    return self.currentCharacteristic;
}

- (void)setCurrentCharacteristic:(Characteristic *)charact
{
    self.currentCharacteristic = charact;
}





@end

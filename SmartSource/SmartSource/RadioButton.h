//
//  RadioButton.h
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import <UIKit/UIKit.h>
#import "Characteristic+Factory.h"
#import "ComponentModel.h"



@interface RadioButton : UIButton

- (RadioButton *)initWithCharacteristic:(Characteristic *)characteristic andComponentModel:(ComponentModel *)component;
- (Characteristic *)getCurrentCharacteristic;
- (void)setCurrentCharacteristic:(Characteristic *)charact;



@end

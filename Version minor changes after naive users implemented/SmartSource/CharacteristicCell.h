//
//  CharacteristicCell.h
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import <UIKit/UIKit.h>
#import "Characteristic+Factory.h"
#import "RatingTableViewViewController.h"

@interface CharacteristicCell : UITableViewCell

//- (CharacteristicCell *)initWithCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(RatingTableViewViewController *)delegate;
- (void)setCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(RatingTableViewViewController *)delegate;

@end

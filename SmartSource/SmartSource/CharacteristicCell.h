//
//  CharacteristicCell.h
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import <UIKit/UIKit.h>
#import "Characteristic+Factory.h"
#import "CharacteristicCellDelegate.h"

@interface CharacteristicCell : UITableViewCell

- (void)setCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(id<CharacteristicCellDelegate>)delegate;

@end

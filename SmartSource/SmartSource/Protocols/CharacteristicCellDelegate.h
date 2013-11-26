//
//  CharacteristicCellDelegate.h
//  SmartSource
//
//  Created by Lorenz on 19.11.13.
//
//

#import <Foundation/Foundation.h>

@protocol CharacteristicCellDelegate <NSObject>

- (void)checkForCompleteness;
- (void)saveContext;
- (NSNumber *)getValueForCohesion;
- (NSNumber *)getValueForCoupling;
@end

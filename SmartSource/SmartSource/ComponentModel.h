//
//  ComponentModel.h
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Component+Factory.h"
#import "SuperCharacteristic+Factory.h"


@interface ComponentModel : NSObject

- (ComponentModel *)initWithComponent:(Component *)component;
- (NSArray *)getCharacteristics;
- (NSArray *)getComponentInfo;
- (void)saveWeight:(NSNumber *)weight forSuperCharacteristic:(NSString *)superChar;
- (BOOL)saveContext;

@end

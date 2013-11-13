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

- (ComponentModel *)initWithComponentId:(NSString *)componentId;
- (NSArray *)getCharacteristics;
- (NSArray *)getComponentInfo;
- (BOOL)saveContext;
- (Component *)getComponentObject;
- (NSDictionary *)getDictionaryWithSuperCharValues;
- (CGFloat)getTotalWeightOfSuperCharacteristics;
- (NSDictionary *)calculateDetailedResults;
- (NSArray *)getCharsAndValuesArray;

@end

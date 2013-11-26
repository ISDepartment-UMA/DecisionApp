//
//  SODAFunctions.h
//  SmartSource
//
//  Created by Lorenz on 16.11.13.
//
//

#import <Foundation/Foundation.h>
#import "Graph.h"

@interface SODAFunctions : NSObject
+ (CGFloat)getCohesionOfClusterWithRequirementsSubset:(NSSet *)requirementsSubset inRequirementsGraph:(Graph *)requirementsGraph;
+ (CGFloat)getCouplingOfClusterWithRequirementsSubset:(NSSet *)requirementsSubset inRequirementsGraph:(Graph *)requirementsGraph;
+ (NSDictionary *)getCouplingValuesForClusteringDictionary:(NSDictionary *)clusters inRequirementsGraph:(Graph *)requirementsGraph;
+ (NSNumber *)get123ValueForLinearValue:(CGFloat)linearFloatValue;
@end

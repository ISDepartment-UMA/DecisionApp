//
//  GraphEdge.h
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import <Foundation/Foundation.h>

@class GraphNode;

@interface GraphEdge : NSObject

//initializers
- (id)init;
- (id)initWithFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode;
- (id)initWithFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode weight:(float)weight;
- (BOOL)isEqualToGraphEdge:(GraphEdge*)other;
//get edge
+ (GraphEdge *)edge;
+ (GraphEdge *)edgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode;
+ (GraphEdge *)edgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode weight:(float)weight;
//getters
- (GraphNode *)getV1;
- (GraphNode *)getV2;
- (CGFloat)getWeight;
- (GraphNode *)getNodeOtherThan:(GraphNode *)node;
- (NSString *)stringForRequirementNodes;
@end

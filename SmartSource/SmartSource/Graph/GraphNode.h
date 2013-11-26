//
//  GraphNode.h
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import <Foundation/Foundation.h>
#import "GraphEdge.h"

@interface GraphNode : NSObject


//initializers
- (id)init;
- (id)initWithValue:(id)value;
+ (GraphNode *)node;
+ (GraphNode *)nodeWithValue:(id)value;
//getters and setters
- (id)getValue;
- (void)addEdgeToSet:(GraphEdge *)edge;
- (void)removeEdgeFromSet:(GraphEdge *)edge;
- (BOOL)isEqualToGraphNode:(GraphNode*)otherNode;
- (NSSet *)getEdges;
- (NSString *)stringForRequirementNode;
@end

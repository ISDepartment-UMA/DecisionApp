//
//  Graph.h
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import <Foundation/Foundation.h>
#import "GraphEdge.h"
#import "GraphNode.h"

@interface Graph : NSObject

- (GraphNode *)nodeWithValue:(id)value;

//getters and setters
- (NSSet *)getAllNodes;
- (NSSet *)getAllEdges;

//add edge
- (GraphEdge*)addEdgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode;
- (GraphEdge*)addEdgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode withWeight:(float)weight;

//get an empty graph
+ (Graph *)graph;

//subgraphs, interedges --> SODA
- (Graph *)getSubgraphForNodeSet:(NSSet *)nodeSet;
- (NSSet *)getAllEdgesLinkedWithNodes:(NSSet *)pNodes;
- (BOOL)containsNode:(GraphNode *)node;
@end

//
//  Graph.m
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import "Graph.h"
#import "GraphNode.h"
#import "Requirement.h"

/*
 *
 *      weighted undirected-Graph!
 *
 */


@interface Graph()

@property (nonatomic, strong) NSMutableSet *nodes;
@property (nonatomic, strong) NSMutableSet *edges;
@end

@implementation Graph
@synthesize nodes = _nodes;

#pragma mark initializers
- (id)init
{
    if ( (self = [super init]) ) {
        self.nodes = [NSMutableSet set];
        self.edges = [NSMutableSet set];
    }
    return self;
}

- (id)initWithNodes:(NSSet *)nodes
{
    if ( (self = [super init]) ) {
        self.nodes = [nodes mutableCopy];
        self.edges = [NSMutableSet set];
    }
    return self;
}

+ (Graph *)graph
{
    return [[self alloc] init];
}

#pragma mark Getters & Setters

- (NSSet *)getAllNodes
{
    return [self.nodes copy];
}

- (NSSet *)getAllEdges
{
    return [self.edges copy];
}

//if graph contains this node, it returns it
- (GraphNode *)getNodeFromGraph:(GraphNode *)node
{
    GraphNode *existing = nil;
    for (GraphNode *present in self.nodes) {
        if ([present isEqual:node]) {
            existing = present;
            break;
        }
    }
    return existing;
}

//if graph contains this edge, return it
- (GraphEdge *)getEdgeFromGraph:(GraphEdge *)edge
{
    GraphEdge *existing = nil;
    for (GraphEdge *present in self.edges) {
        if ([present isEqual:edge]) {
            existing = present;
            break;
        }
    }
    return existing;
}


/*
 *  checks if the graph contains a node with the passed value
 *  and creates a node if not existent
 *  returns the appropriate node
 */
- (GraphNode *)nodeWithValue:(id)value
{
    //node as it should be
    GraphNode *node = [GraphNode nodeWithValue:value];
    //if node with value already exists, return it
    GraphNode *existing = [self getNodeFromGraph:node];
    if (!existing) {
        //else, create it
        [self.nodes addObject:node];
        existing = node;
    }
    return existing;
}

//checks if the graph contains the passed node
- (BOOL)containsNode:(GraphNode *)node
{
    //if node with value already exists, return it
    GraphNode *existing = [self getNodeFromGraph:node];
    if (!existing) {
        return NO;
    }
    return YES;
    
}


/*
 *  checks if the graph contains this edge and adds it, if not existing
 *  undirected-Graph: the method that checks for existence uses the
 *  "isEqual" method from GraphEdge.m --> both nodes are compared to both
 *  other nodes --> direction does not matter
 */
- (GraphEdge *)addEdgeFromNode:(GraphNode *)v1 toNode:(GraphNode *)v2
{
    //edge as it should be
    GraphEdge *edge = [GraphEdge edgeFromNode:v1 toNode:v2];
    GraphEdge *existing = [self getEdgeFromGraph:edge];
    //check if node exists
    if (!existing) {
        [self.edges addObject:edge];
        //edges related to a node are kept at the node and updated
        [v1 addEdgeToSet:edge];
        [v2 addEdgeToSet:edge];
        return edge;
    } else {
        return existing;
    }
}

//same as without weight, but with weight
- (GraphEdge *)addEdgeFromNode:(GraphNode*)v1 toNode:(GraphNode*)v2 withWeight:(float)weight
{
    //edge as it should be
    GraphEdge *edge = [GraphEdge edgeFromNode:v1 toNode:v2 weight:weight];
    GraphEdge *existing = [self getEdgeFromGraph:edge];
    //check if node exists
    if (!existing) {
        [self.edges addObject:edge];
        //edges related to a node are kept at the node and updated
        [v1 addEdgeToSet:edge];
        [v2 addEdgeToSet:edge];
        return edge;
    } else {
        return existing;
    }
}


/*
 *  creates a subgraph of the the current graph that is built up by
 *  the nodes passed in the set. the subgraph will contain all edges
 *  between nodes from this set that are also present in the current
 *  graph
 */
- (Graph *)getSubgraphForNodeSet:(NSSet *)nodeSet
{
    //output graph
    Graph *output = [[Graph alloc] initWithNodes:nodeSet];
    
    //iterate node subset
    for (GraphNode *currentNode in nodeSet) {
        //find same node in full graph
        GraphNode *currentNodeToUse = nil;
        for (GraphNode *nodeInFull in self.nodes) {
            if ([nodeInFull isEqual:currentNode]) {
                currentNodeToUse = nodeInFull;
            }
        }
        if (!currentNodeToUse) {
            return nil;
        }
        //get all edges that are inside the subgraph
        for (GraphEdge *edge in [currentNodeToUse getEdges]) {
            //if other node also in subset, then add it to edges
            GraphNode *otherNode = [edge getV2];
            if ([otherNode isEqual:currentNodeToUse]) {
                otherNode = [edge getV1];
            }

            for (GraphNode *compareNode in nodeSet) {
                if ([otherNode isEqual:compareNode]) {
                    //both nodes are inside the subset --> edge should be in the subgraph
                    [output addEdgeFromNode:[output nodeWithValue:[currentNodeToUse getValue]] toNode:[output nodeWithValue:[otherNode getValue]] withWeight:[edge getWeight]];
                    break;
                }
            }
        }
    }
    return output;
}


/*
 *  returns a set of all edges from the current graph that involve
 *  at least one of the nodes passed in pNodes. 
 *  = all interedges of the subgraph built up by the nodes in pNode
 */
- (NSSet *)getAllEdgesLinkedWithNodes:(NSSet *)pNodes
{
    NSMutableSet *output = [NSMutableSet set];
    for (GraphNode *currentNode in pNodes) {
        NSSet *edges = [currentNode getEdges];
        for (GraphEdge *currentEdge in edges) {
            //check if edge already in output
            BOOL found = NO;
            for (GraphEdge *outputEdge in output) {
                if ([currentEdge isEqual:outputEdge]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [output addObject:currentEdge];
            }
        }
    }
    return output;
}

@end

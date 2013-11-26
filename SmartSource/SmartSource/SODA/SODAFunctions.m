//
//  SODAFunctions.m
//  SmartSource
//
//  Created by Lorenz on 16.11.13.
//
//

#import "SODAFunctions.h"
#import "GraphEdge.h"
#import "GraphNode.h"
#import "Requirement.h"

@implementation SODAFunctions

/*
 *  calculates the cohesion value of a subgraph of an entire requirementsGraph
 *  the subgraph is defined and built up by a set of requirements (nodes) and the edges between
 *  them in the entire requirements graph
 *
 */
+ (CGFloat)getCohesionOfClusterWithRequirementsSubset:(NSSet *)requirementsSubset inRequirementsGraph:(Graph *)requirementsGraph
{
    
    //get total weight of edges of subgraph - only internal edges
    Graph *subGraph = [requirementsGraph getSubgraphForNodeSet:requirementsSubset];
    CGFloat weightOfIntraEdges = 0.0;
    for (GraphEdge *intraEdge in [subGraph getAllEdges]) {
        weightOfIntraEdges += [intraEdge getWeight];
    }
    //get total weight of edges that belong to internal vertices - includes edges to external vertices
    NSMutableSet *interEdges = [[requirementsGraph getAllEdgesLinkedWithNodes:requirementsSubset] mutableCopy];
    CGFloat weightOfInterEdges = 0.0;
    for (GraphEdge *interEdge in interEdges) {
        weightOfInterEdges += [interEdge getWeight];
    }
    //avoid error
    if (weightOfInterEdges == 0) {
        return 0.0;
    }
    //calculate intraEdges/allEdges --> cohesion
    CGFloat cohesion = (weightOfIntraEdges/weightOfInterEdges);
    return  cohesion;
}

+ (CGFloat)getCouplingOfClusterWithRequirementsSubset:(NSSet *)requirementsSubset inRequirementsGraph:(Graph *)requirementsGraph
{
    //weight of edges that link requirements of the subgraph to external requirements
    CGFloat weightOfEdgesToExternalNode = 0.0;
    //subgraph built by requirements subset
    Graph *subGraph = [requirementsGraph getSubgraphForNodeSet:requirementsSubset];
    NSSet *internalNodes = [subGraph getAllNodes];
    //iterate internal nodes
    for (GraphNode *internalNode in internalNodes) {
        //look for same node in complete graph
        GraphNode *nodeInEntireGraph = [requirementsGraph nodeWithValue:[internalNode getValue]];
        //iterate edges
        for (GraphEdge *edgeFromNode in [nodeInEntireGraph getEdges]) {
            //if edge leads to node outside the subgraph, add its weight
            if (![subGraph containsNode:[edgeFromNode getNodeOtherThan:nodeInEntireGraph]] ) {
                weightOfEdgesToExternalNode += [edgeFromNode getWeight];
            }
        }
    }
    
    return weightOfEdgesToExternalNode;
}


/*
 *  takes a dictionary of cluster requirements and a graph of their interdependencies
 *  parameter clusters: dictionary with 
 *          keys: nsstring of cluster identifiers
 *          values: nsset of nodes from the requirements graph that belong to the cluster
 *
 *  the method calculates the quotient of the total weight of the edges that lead out of one cluster and the total weight of all inter-cluster edges (edges that connect the clusters of the entire graph)
 *  this provides a relative value for the coupling of these clusters
 *
 *  return value: dictionary of cluster identifiers and relative coupling values
 *
 */
+ (NSDictionary *)getCouplingValuesForClusteringDictionary:(NSDictionary *)clusters inRequirementsGraph:(Graph *)requirementsGraph
{
    //all interedges of the graph
    NSMutableSet *overAllInterEdges = [NSMutableSet set];
    NSMutableDictionary *sumWeightOfInterEdges = [NSMutableDictionary dictionaryWithCapacity:[clusters count]];
    //iterate clusters
    NSArray *clusterIDArray = [clusters allKeys];
    for (NSString *clusterID in clusterIDArray) {
        CGFloat weightInterEdgesThisCluster = 0.0;
        //build subgraph for this cluster
        Graph *subGraph = [requirementsGraph getSubgraphForNodeSet:[clusters objectForKey:clusterID]];
        NSSet *internalNodes = [subGraph getAllNodes];
        for (GraphNode *internalNode in internalNodes) {
            //look for same node in complete graph
            GraphNode *nodeInEntireGraph = [requirementsGraph nodeWithValue:[internalNode getValue]];
            //iterate edges
            for (GraphEdge *edgeFromNode in [nodeInEntireGraph getEdges]) {
                //if edge leads to node outside the subgraph, add its weight
                if (![subGraph containsNode:[edgeFromNode getNodeOtherThan:nodeInEntireGraph]] ){
                    //add weight to sum of this cluster
                    weightInterEdgesThisCluster += [edgeFromNode getWeight];
                    //add edge to set of overall interedges
                    if (![overAllInterEdges containsObject:edgeFromNode]) {
                        [overAllInterEdges addObject:edgeFromNode];
                    }
                }
            }
            //write sum into dictionary
            [sumWeightOfInterEdges setObject:[NSNumber numberWithFloat:weightInterEdgesThisCluster] forKey:clusterID];
        }
    }
    
    //get total weight of interedges
    CGFloat totalWeightOfInterEdges = 0.0;
    for (GraphEdge *oneInterEdge in overAllInterEdges) {
        totalWeightOfInterEdges += [oneInterEdge getWeight];
    }
    
    //prevent 0 as a divisor
    if (totalWeightOfInterEdges > 0) {
        //calculate relative value for each cluster (aka subset of requirements)
        for (NSString *clusterID in clusterIDArray) {
            NSNumber *weightInterEdgesThisCluster = [sumWeightOfInterEdges objectForKey:clusterID];
            CGFloat relativeValue = [weightInterEdgesThisCluster floatValue]/totalWeightOfInterEdges;
            [sumWeightOfInterEdges setObject:[NSNumber numberWithFloat:relativeValue] forKey:clusterID];
        }
        NSDictionary *output = [sumWeightOfInterEdges copy];
        return output;
    }
    //return array of 0s in case totalWeightOfInterEdges = 0
    for (NSString *clusterID in clusterIDArray) {
        [sumWeightOfInterEdges setObject:[NSNumber numberWithFloat:0.0] forKey:clusterID];
    }
    NSDictionary *output = [sumWeightOfInterEdges copy];
    return output;
    
}

/*
 *  takes a relative value between 0 and 1 and returns 
 *  a categorization into low(1), medium(2), or high(3)
 */
+ (NSNumber *)get123ValueForLinearValue:(CGFloat)linearFloatValue
{
    if (linearFloatValue <= 0.33) {
        return [NSNumber numberWithInt:1];
    } else if (linearFloatValue <= 0.66) {
        return [NSNumber numberWithInt:2];
    } else if (linearFloatValue <= 1.0) {
        return [NSNumber numberWithInt:3];
    } else {
        return [NSNumber numberWithInt:0];
    }
}
@end

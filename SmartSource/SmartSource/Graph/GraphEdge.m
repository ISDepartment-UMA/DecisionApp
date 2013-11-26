//
//  GraphEdge.m
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import "GraphEdge.h"
#import "GraphNode.h"
#import "Requirement.h"

@interface GraphEdge()

//undirected-Graph --> which one is v1 and which one is v2 does not matter!
@property (nonatomic, strong) GraphNode *v1;
@property (nonatomic, strong) GraphNode *v2;
@property (nonatomic) CGFloat weight;

@end
@implementation GraphEdge
@synthesize v1 = _v1;
@synthesize v2 = _v2;
@synthesize weight = _weight;

#pragma mark initializers

- (id)init
{
    if( (self = [super init]) ) {
        self.v1 = nil;
        self.v2 = nil;
        self.weight = 0;
    }
    return self;
}

- (id)initWithFromNode:(GraphNode *)v1 toNode:(GraphNode *)v2
{
    if( (self = [super init]) ) {
        self.v1 = v1;
        self.v2 = v2;
        self.weight = 0;
    }
    return self;
}

- (id)initWithFromNode:(GraphNode*)v1 toNode:(GraphNode*)v2 weight:(float)weight
{
    if( (self = [super init]) ) {
        self.v1 = v1;
        self.v2= v2;
        self.weight = weight;
    }
    return self;
}

//get an edge
+ (GraphEdge *)edge {
    return (GraphEdge *)[[self alloc] init];
}

//get an edge
+ (GraphEdge *)edgeFromNode:(GraphNode*)v1 toNode:(GraphNode*)v2 {
    return (GraphEdge *)[[self alloc] initWithFromNode:v1 toNode:v2];
}

//get an edge
+ (GraphEdge *)edgeFromNode:(GraphNode*)v1 toNode:(GraphNode*)v2 weight:(float)weight {
    return (GraphEdge *)[[self alloc] initWithFromNode:v1 toNode:v2 weight:weight];
}


#pragma mark Getters & Setters
- (GraphNode *)getV1
{
    return self.v1;
}


- (GraphNode *)getV2
{
    return self.v2;
}

- (CGFloat)getWeight
{
    return self.weight;
}

#pragma mark comparisons

//comparison of an edge to another object of unknown class
//uses the comparison to GraphEdge, if class is right
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGraphEdge:other];
}

//comparison of two GraphEdges
- (BOOL)isEqualToGraphEdge:(GraphEdge*)other {
    if (self == other) {
       return YES;
    }
    //undirected graph --> compare both nodes of one edge to both nodes in other edge
    BOOL firstOptioForTrue = ([self.v1 isEqualToGraphNode:other.v1] && [self.v2 isEqualToGraphNode:other.v2]);
    BOOL secondOptionForTrue = ([self.v2 isEqualToGraphNode:other.v1] && [self.v1 isEqualToGraphNode:other.v2]);
    if (firstOptioForTrue || secondOptionForTrue) {
        return YES;
    } else {
        return NO;
    }
}

/*
 * checks if one of the nodes of the edge is equal to the
 * passed one and returns the other node of the edge
 * if non of the two is equal to the passed one, the method
 * returns nil
 *
 */
- (GraphNode *)getNodeOtherThan:(GraphNode *)node
{
    if ([self.v1 isEqual:node]) {
        return self.v2;
    } else if ([self.v2 isEqual:node]){
        return self.v1;
    } else {
        return nil;
    }
}

// copy with zone
- (GraphEdge *)copyWithZone:(NSZone *)zone
{
    return [[GraphEdge allocWithZone:zone] initWithFromNode:self.v1 toNode:self.v2 weight:self.weight];
}

#pragma mark Requirement Graph Methods
/*
 *  in case both nodes of the edge are requirements, this method
 *  returns a string with both names
 *  since the stringForRequirementsNode method will check for class,
 *  this method is safe
 */
- (NSString *)stringForRequirementNodes
{
    NSString *output = [NSString stringWithFormat:@"%@ - %@", [self.v1 stringForRequirementNode], [self.v2 stringForRequirementNode]];
    return output;
}

@end

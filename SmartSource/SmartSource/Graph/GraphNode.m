//
//  GraphNode.m
//  danmaku
//
//  Created by Lorenz on 16.11.13.
//

#import "GraphNode.h"
#import "GraphEdge.h"
#import "Requirement.h"

@interface GraphNode()
@property (nonatomic) NSMutableSet *edges;
@property (nonatomic) id value;
@end

@implementation GraphNode
@synthesize edges = _edges;
@synthesize value = _value;


#pragma mark initializers

- (id)init {
    if((self = [super init])) {
		self.value = nil;
		self.edges = [NSMutableSet set];
	}
    return self; 
}

- (id)initWithValue:(id)value {
    if ((self = [super init])) {
		self.value = value;
        self.edges = [NSMutableSet set];
	}
    return self; 
}

- (id)initWithValue:(id)value andEdges:(NSSet *)edges
{
    if ((self = [super init])) {
		self.value = value;
        self.edges = [edges mutableCopy];
	}
    return self;
}

+ (GraphNode *)node
{
    return [[GraphNode alloc] init];
}

+ (GraphNode *)nodeWithValue:(id)value
{
    return [[GraphNode alloc] initWithValue:value];
}

+ (GraphNode *)nodeWithValue:(id)value andEdges:(NSSet *)edges
{
    return [[GraphNode alloc] initWithValue:value];
}

#pragma mark Getters & Setters

- (id)getValue
{
    return  _value;
}

- (NSSet *)getEdges
{
    return [_edges copy];
}



/*
 *  edges related to a node are kept at the node and updated
 *  once an edge is added
 */
- (void)addEdgeToSet:(GraphEdge *)edge
{
    [self.edges addObject:edge];
}

- (void)removeEdgeFromSet:(GraphEdge *)edge
{
    GraphEdge *existing = [self.edges member:edge];
    if (existing) {
        [self.edges removeObject:existing];
    }
}

/*
 *  comparison of a node with another object of unknown class
 *  uses the comparator with another node
 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGraphNode:other];
}

/*
 *  comparison of two nodes
 *  two nodes are equal, if their values are equal
 *  --> special for requirements: comparison of their id here
 *  --> isEqual- method cannot be implemented in NSManagedObject class
 */
- (BOOL)isEqualToGraphNode:(GraphNode*)other {
    if (self == other){
        return YES;
    }
    //if both are requirements, compare ids
    if (([self.value isKindOfClass:[Requirement class]]) && ([[other getValue] isKindOfClass:[Requirement class]])) {
        //compare requirement ids and return
        return [((Requirement *)self.value).requirementID isEqualToString:((Requirement *)[other value]).requirementID];
    }
    
    return [self.value isEqual:[other getValue]];
}

// copy with zone
- (GraphNode *)copyWithZone:(NSZone *)zone {
    return [[GraphNode allocWithZone: zone] initWithValue:self.value andEdges:self.edges];
}

#pragma mark Requirements specific methods

/*
 *  if node value is of class requirement, return its name
 */
- (NSString *)stringForRequirementNode
{
    if ([self.value isKindOfClass:[Requirement class]]) {
        return ((Requirement *)self.value).name;
    } else if (!self.value) {
        return @"null";
    } else {
        return @"not a requirement";
    }
}

@end

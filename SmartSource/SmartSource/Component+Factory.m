//
//  Component+Factory.m
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Component+Factory.h"
#import "Project+Factory.h"
#import "SBJson.h"

@implementation Component (Factory)

+ (Component *)addNewComponent:(NSString *)componentID toProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Component *comp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"id =%@", componentID];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        comp = [NSEntityDescription insertNewObjectForEntityForName:@"Component" inManagedObjectContext:context];
        comp.id = componentID;
        comp.projectID = projectID;
        
        NSDictionary *componentInformation = [self getComponentForID:componentID];
        comp.name = [componentInformation objectForKey:@"name"];
        comp.descr = [componentInformation objectForKey:@"description"];
        comp.partOf = [Project addNewProject:projectID toManagedObjectContext:context withTimestamp:nil];
                       
    } else {
        comp = [matches lastObject];
    }
                       
return comp;
                       
                       
}
                       
//returns an nsdictionary with component info for a given component id
+ (NSDictionary *)getComponentForID:(NSString *)componentID
{
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    
    if (loginData != nil) {
        serviceUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8081/axis2/services/DataFetcher/getComponentInfo?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
}
@end

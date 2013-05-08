//
//  Project+Factory.m
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Project+Factory.h"
#import "SBJson.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"

@implementation Project (Factory)

+ (Project *)addNewProject:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context withTimestamp:(NSDate *)timestamp
{
    Project *pro = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        pro = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
        pro.projectID = projectID;
        
        //get further project information
        NSDictionary *projectInformation = [self getProjectInfo:projectID];
        pro.name = [projectInformation objectForKey:@"name"];
        pro.descr = [projectInformation objectForKey:@"description"];
        pro.timestamp = timestamp;
        
        
    } else {
        pro = [matches lastObject];
    }
    
    return pro;
    
    
}

//prepares the core database for the rating of the project and returns a 2 dimensional array
//1st dimension: - 0 for supercharacteristics names - 1 for subcharacteristics names of supercharacteristic at value of 0
+ (Project *)initProjectFromID:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context
{
    
    //
    //getting characteristics from core database
    //get all supercharacteristics
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //initialize arrays for super- and subcharacteristics
    NSMutableArray *superchar = [NSMutableArray array];
    NSMutableArray *subchar = [NSMutableArray array];
    
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //add name of supercharacteristic to array of supercharacteristics
        [superchar addObject:tmpasc.name];
        
        
        //prepare array for names of subcharacteristics
        NSMutableArray *tmp = [NSMutableArray array];
        
        //iterate through subcharacteristics
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *enumerator = [tmpasc.availableSuperCharacteristicOf sortedArrayUsingDescriptors:descriptors];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            
            //add name of subcharacteristic to array of subcharacteristics
            [tmp addObject:tmpcharacteristic.name];
            
            
            //iterate through all components of the project and add this characteristic to it
            NSArray *componentsOfProject = [self getAllComponentsForProjectId:projectID];
            
            for (int y=0; y<[componentsOfProject count]; y++) {
                NSString *componentID = [[componentsOfProject objectAtIndex:y] objectAtIndex:0];
                [Characteristic addNewCharacteristic:tmpcharacteristic.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:tmpasc.name withWeight:[NSNumber numberWithInt:3] andComponent:componentID andProject:projectID andManagedObjectContext:context];
            }
            
            
        }
        
        //add array of subcharacteristics to the array of subcharacteristics
        [subchar addObject:tmp];
    }
    

    
    //search for right project and return it
    NSFetchRequest *requestA = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    requestA.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    
    NSSortDescriptor *sortDescriptionA = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    requestA.sortDescriptors = [NSArray arrayWithObject:sortDescriptionA];
    NSError *errorA = nil;
    NSArray *matchesA = [context executeFetchRequest:requestA error:&errorA];
    return [matchesA lastObject];
    
}



//import all components of a project from the webservice
+ (NSArray *)getAllComponentsForProjectId:(NSString *)projectID
{
    
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceURL = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        
        //decode url to pass it in http request
        serviceURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    //building the url
    NSString *url = [[[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getAllComponentsForProject?url="] stringByAppendingString:serviceURL] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *components = [responsedic objectForKey:@"return"];
    
    //if the project has just one component, return it
    if ([components isKindOfClass:[NSDictionary class]]) {
        NSString *id = [NSString stringWithFormat:@"%d", [[components objectForKey:@"id"] integerValue]];
        NSString *name = [components objectForKey:@"name"];
        NSString *descr = [components objectForKey:@"description"];
        return [NSArray arrayWithObject:[NSArray arrayWithObjects:id, name, descr, nil]];
        
        //else it consists of more than one component --> NSDictionaries inside an NSArray
    } else {
        NSEnumerator *enumerator = [components objectEnumerator];
        NSMutableArray *output = [NSMutableArray arrayWithCapacity:1];
        
        NSDictionary *temp;
        while ((temp = [enumerator nextObject]) != nil) {
            NSString *id = [NSString stringWithFormat:@"%d", [[temp objectForKey:@"id"] integerValue]];
            NSString *name = [temp objectForKey:@"name"];
            NSString *description = [temp objectForKey:@"description"];
            [output addObject:[NSArray arrayWithObjects:id, name, description, nil]];
        }
        return output;
    }
    
    
    
}



//retrieves project Information for a passed projectID
+ (NSDictionary *)getProjectInfo:(NSString *)projectID
{
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        serviceUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSString *url = [[[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getInfoForProjectObject?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
    
}
@end

//
//  WebServiceConnector.m
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import "WebServiceConnector.h"
#import "SBJson.h"
#import "Project+Factory.h"

@implementation WebServiceConnector

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
+ (NSDictionary *)getProjectInfoDictionary:(NSString *)projectID
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


//returns an nsdictionary with component info for a given component id
+ (NSDictionary *)getComponentForID:(NSString *)componentID
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
    
    NSString *url = [[[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getComponentInfo?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
}

// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
+ (NSArray *)getAllProjectNames
{
    
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        
        //decode url to pass it in http request
        serviceUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    //JSON request to web service
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSString *url = [[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getAllProjects?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *projectsTotal = [responsedic objectForKey:@"return"];
    
    
    //difference between one returned project and more than one
    @try {
        NSEnumerator *projects = [projectsTotal objectEnumerator];
        id next = [projects nextObject];
        
        //only one project returned
        if ([next isKindOfClass:[NSArray class]]) {
            NSString *id = [NSString stringWithFormat:@"%d", [[next objectAtIndex:0] integerValue]];
            NSString *name = [next objectAtIndex:1];
            NSString *description = [next objectAtIndex:2];
            
            return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        }
        
        //more than one project returned
        NSMutableArray *allProjects;
        NSEnumerator *oneproject = [next objectEnumerator];
        
        //retrieve project name, id and description in 2-dimensional array
        //0: ID 1:Name 2:Description
        NSArray *current = [oneproject nextObject];
        NSString *id = [NSString stringWithFormat:@"%d", [[current objectAtIndex:0] integerValue]];
        NSString *name = [current objectAtIndex:1];
        NSString *description = [current objectAtIndex:2];
        
        allProjects = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        
        NSDictionary *temp;
        while ((temp = [projects nextObject]) != nil) {
            NSEnumerator *temp2 = [temp objectEnumerator];
            NSArray *current = [temp2 nextObject];
            NSString *id = [NSString stringWithFormat:@"%d", [[current objectAtIndex:0] integerValue]];
            NSString *name = [current objectAtIndex:1];
            NSString *description = [current objectAtIndex:2];
            [allProjects addObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        }
        
        //return
        NSLog([NSString stringWithFormat:@"%d", [allProjects count]]);
        return allProjects;
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:@"", @"Fehler!", @"",  nil]];
    }
}

//retrieves project Information for a passed projectID
+ (NSArray *)getProjectInfoArray:(NSString *)projectID
{
    if (!projectID) {
        return nil;
    }
    
    
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        //decode url to pass it in http request
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
    
    
    return [NSArray arrayWithObjects:[[returnedObjects objectForKey:@"id"] stringValue], [returnedObjects objectForKey:@"name"], [returnedObjects objectForKey:@"description"], [returnedObjects objectForKey:@"category"], [returnedObjects objectForKey:@"start"], [returnedObjects objectForKey:@"end"], [returnedObjects objectForKey:@"creator"], nil];
}



@end

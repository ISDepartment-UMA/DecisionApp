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
    
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    //building the url
    NSString *url = [[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getAllComponentsForProject?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID];
    
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    id responsedic = [parser objectWithString:json_string error:nil];
    return responsedic;
    
    /*
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
    }*/
    
    
    
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
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSString *url = [[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getComponentInfo?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    return responsedic;
}

// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
+ (NSArray *)getAllProjectNames
{
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    //JSON request to web service
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getAllProjects?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password];// stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSArray *responsedic = [parser objectWithString:json_string error:nil];
    

    
    return responsedic;

}

+ (void)checkLoginData
{
    NSLog(@"checkLoginData");
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    
    if (loginData != nil) {
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    }
    
    //JSON request to web service
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/checkLoginData?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password];// stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSArray *responsedic = [parser objectWithString:json_string error:nil];
    
    
    if ([responsedic count] > 0) {
        NSLog([responsedic lastObject]);
    } else {
        NSLog([NSString stringWithFormat:@"%d", [responsedic count]]);
        NSLog(serviceUrl);
        NSLog(login);
        NSLog(password);
        NSLog(javaServiceURL);
    }
    
}



//retrieves project Information for a passed projectID
+ (NSArray *)getProjectInfoArray:(NSString *)projectID
{
    NSDictionary *responsedic = [self getProjectInfoDictionary:projectID];
    return [NSArray arrayWithObjects:[responsedic objectForKey:@"id"], [responsedic objectForKey:@"name"], [responsedic objectForKey:@"description"], [responsedic objectForKey:@"category"], [responsedic objectForKey:@"start"], [responsedic objectForKey:@"end"], [responsedic objectForKey:@"creator"], nil];
    
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
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    
    NSString *url = [[[[[[[[javaServiceURL stringByAppendingString:@"DataFetcher/getInfoForProjectObject?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    return responsedic;
    
    
}




@end

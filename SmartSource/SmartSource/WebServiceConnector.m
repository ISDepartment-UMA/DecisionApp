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
#import "SettingsModel.h"
@implementation WebServiceConnector

//static login variables
static NSString *serviceUrl;
static NSString *login;
static NSString *password;
static NSString *javaServiceURL;

#pragma mark helper methods to perform requests

/*
 fills the static login variables of this class with the crendentials
 stored in nsuser defaults
 */
+ (BOOL)getUserCredentials
{
    //login data
    NSArray *loginData = [SettingsModel getLoginData];
    javaServiceURL = [SettingsModel getWebServiceUrl];
    if (!javaServiceURL) {
        return NO;
    }
    if (loginData) {
        serviceUrl = [loginData objectAtIndex:0];
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
        return YES;
    } else {
        return NO;
    }
}


/*
 performs the request specified in the passed url, parses the returned
 json string to an id object and returns it
 */
+ (id)performRequestWithUrl:(NSString *)url andTimeOutInterval:(CGFloat)numberOfSeconds
{
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:numberOfSeconds];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    id responsedic = [parser objectWithString:json_string error:nil];
    return responsedic;
}


#pragma mark public retrieval methods

//import all components of a project from the webservice
+ (NSArray *)getAllComponentsForProjectId:(NSString *)projectID
{
    if (![WebServiceConnector getUserCredentials]) {
        return nil;
    }
    //building the url
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/getAllComponentsForProject?url=%@&login=%@&password=%@&projectID=%@", javaServiceURL, serviceUrl, login, password, projectID];
    return [WebServiceConnector performRequestWithUrl:url andTimeOutInterval:10.0];
}



//returns an nsdictionary with component info for a given component id
+ (NSDictionary *)getComponentForID:(NSString *)componentID
{
    //login data
    if (![WebServiceConnector getUserCredentials]) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/getComponentInfo?url=%@&login=%@&password=%@&componentID=%@", javaServiceURL, serviceUrl, login, password, componentID];
    //sending request
    return (NSDictionary *)[WebServiceConnector performRequestWithUrl:url andTimeOutInterval:5.0];
}


// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
+ (NSArray *)getAllProjectNames
{
    //login data
    if (![WebServiceConnector getUserCredentials]) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/getAllProjects?url=%@&login=%@&password=%@", javaServiceURL, serviceUrl, login, password];
    //sending request
    return (NSArray *)[WebServiceConnector performRequestWithUrl:url andTimeOutInterval:10.0];
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
    if (![WebServiceConnector getUserCredentials]) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/getInfoForProjectObject?url=%@&login=%@&password=%@&projectID=%@", javaServiceURL, serviceUrl, login, password, projectID];
    //sending request
    return (NSDictionary *)[WebServiceConnector performRequestWithUrl:url andTimeOutInterval:5.0];
}

//checks the passed login data for the passed javaServiceURL
+ (NSString *)checkLoginData:(NSArray *)loginData withServiceUrl:(NSString *)javaServiceURL
{
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/checkLoginData?url=%@&login=%@&password=%@", javaServiceURL, [loginData objectAtIndex:0], [loginData objectAtIndex:1], [loginData objectAtIndex:2]];
    //sending request
    id responsedic = [self performRequestWithUrl:url andTimeOutInterval:2.0];
    if (!responsedic) {
        return @"timeoutError";
    } else {
        return [(NSArray *)responsedic lastObject];
    }
}

//checks connection to webserice
+ (BOOL)checkConnectionToWebService:(NSString *)javaWebServiceUrl
{
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/clientHello", javaWebServiceUrl];
    //sending request
    NSArray *responsedic = [WebServiceConnector performRequestWithUrl:url andTimeOutInterval:2.0];
    //if server hello received, return true
    if (([responsedic count] > 0) && ([[responsedic lastObject] isEqualToString:@"serverHello"])) {
        return YES;
    } else {
        return NO;
    }
}


+ (NSArray *)getRequirementsAndInterdependenciesForProject:(NSString *)projectID
{
    if (![WebServiceConnector getUserCredentials]) {
        return nil;
    }
    //building the url
    NSString *url = [NSString stringWithFormat:@"%@DataFetcher/getAllRequirementsForProject?url=%@&login=%@&password=%@&projectID=%@", javaServiceURL, serviceUrl, login, password, projectID];
    NSArray *requirements = [WebServiceConnector performRequestWithUrl:url andTimeOutInterval:10.0];
    return requirements;
}


+ (BOOL)uploadFileWithPath:(NSString *)filePath withName:(NSString *)fileName toProject:(NSString *)projectID
{
    //login data
    if (![WebServiceConnector getUserCredentials]) {
        return NO;
    }
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    //NSURL *url = [NSURL URLWithString:[javaServiceURL stringByAppendingString:@"DataPoster/pdfUpload"]];
    NSString *urlString = [[[[[[[[javaServiceURL stringByAppendingString:@"DataPoster/pdfUpload?url="] stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID];
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:[[NSData alloc] initWithContentsOfFile:filePath]]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
        
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSArray *responsedic = [parser objectWithString:returnString error:nil];
    if ([[responsedic lastObject] isEqualToString:@"Success"]) {
        return YES;
    } else {
        return NO;
    }
}

@end

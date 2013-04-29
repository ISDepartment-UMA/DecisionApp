//
//  CodeBeamerModel.m
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import "CodeBeamerModel.h"
#import "SBJson.h"
#import "Project+Factory.h"
#import "AlertView.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Component+Factory.h"
#import "SmartSourceAppDelegate.h"

@interface CodeBeamerModel()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (strong, nonatomic) NSArray *allProjects;
@property (strong, nonatomic) NSArray *selectedProject;


@end

@implementation CodeBeamerModel


- (NSArray *)getSelectedProject
{
    return _selectedProject;
}
- (void)setSelectedProject:(NSArray *)projectID
{
    _selectedProject = [projectID copy];
}


- (CodeBeamerModel *)init
{
    //initialize
    self = [super init];
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    return self;
}

// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
- (NSArray *)getAllProjectNames
{
    
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    
    
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
    NSString *url = [[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8081/axis2/services/DataFetcher/getAllProjects?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&response=application/json"];
    
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
- (NSArray *)getProjectInfo:(NSString *)projectID
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
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8081/axis2/services/DataFetcher/getInfoForProjectObject?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    
    
    return [NSArray arrayWithObjects:[[returnedObjects objectForKey:@"id"] stringValue], [returnedObjects objectForKey:@"name"], [returnedObjects objectForKey:@"description"], [returnedObjects objectForKey:@"category"], [returnedObjects objectForKey:@"start"], [returnedObjects objectForKey:@"end"], [returnedObjects objectForKey:@"creator"], nil];
}

- (NSArray *)getStoredProjects
{
    
    
    //get all projects from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //initiate array of available projects
    NSMutableArray *availableProjects = [NSMutableArray array];
    
    
    //put id, name and description of all projects into available projects
    for (int i=0; i<[matches count]; i++) {
        Project *currProject = [matches objectAtIndex:i];
        [availableProjects addObject:[NSArray arrayWithObjects:currProject.projectID, currProject.name, currProject.descr, nil]];
    }
    
    return [availableProjects copy];
}

//reacts to the user's selection in the alert view to delete the project rating
- (void)deleteProjectWithID:(NSString *)projectID
{
    
        //then delete the current rating from the core database
        //look for project in core database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
        request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        //delete project
        //deletion rule in core database is set to cascade, so deleting the project will delete all components, supercharacteristics and characteristics
        [self.managedObjectContext deleteObject:[matches objectAtIndex:0]];
        
        //save context
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
}

//checks weather the rating of the currently displayed project is complete or not
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([matches count] == 0) {
        return NO;
    }
    Project *project = [matches lastObject];
    NSEnumerator *componentEnumerator = [project.consistsOf objectEnumerator];
    
    //iterate through components
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        
        //iterate through all SuperCharacteristics
        SuperCharacteristic *superChar;
        NSEnumerator *superCharEnumerator = [comp.ratedBy objectEnumerator];
        while ((superChar = [superCharEnumerator nextObject]) != nil) {
            
            //iterate through all characteristics and add their values to the value of supercharacteristic
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superChar.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                if ([characteristic.value intValue] == 0) {
                    NSLog(@"hier");
                    return NO;
                }
            }
        }
    }
    NSLog(@"hier2");
    
    return YES;
    
}

@end

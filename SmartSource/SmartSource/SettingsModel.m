//
//  SettingsModel.m
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import "SettingsModel.h"
#import "SmartSourceAppDelegate.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "AvailableCharacteristic+Factory.h"
#import "WebServiceConnector.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"

@interface SettingsModel()
@end

@implementation SettingsModel

#pragma mark Initializer

//initializer simply fetches NSManagedObejctContext from app delegate
- (SettingsModel *)init
{
    //initialize
    self = [super init];
    return self;
}

#pragma mark Login Data

+ (void)setWebServiceUrl:(NSString *)webServiceUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //if last character is not /, then append /
    NSString *lastChar = [webServiceUrl substringFromIndex:([webServiceUrl length]-1)];
    if (![lastChar isEqualToString:@"/"]) {
        webServiceUrl = [webServiceUrl stringByAppendingString:@"/"];
    }
    [defaults setObject:webServiceUrl forKey:@"javaWebserviceConnection"];
}

+ (NSString *)getWebServiceUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"javaWebserviceConnection"];
}

+ (void)setLoginData:(NSArray *)loginData
{
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:loginData forKey:@"loginData"];
}

+ (NSArray *)getLoginData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"loginData"];
    
}

+ (NSString *)checkLoginData:(NSArray *)loginData
{
    //login Data from Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *javaServiceURL = [defaults objectForKey:@"javaWebserviceConnection"];
    //check connection
    NSString *response = [WebServiceConnector checkLoginData:loginData withServiceUrl:javaServiceURL];
    return response;
}

+ (BOOL)checkConnectionToWebServer:(NSString *)javaWebServiceUrl
{
    //check connection
    //if last character is not /, then append /
    NSString *lastChar = [javaWebServiceUrl substringFromIndex:([javaWebServiceUrl length]-1)];
    if (![lastChar isEqualToString:@"/"]) {
        javaWebServiceUrl = [javaWebServiceUrl stringByAppendingString:@"/"];
    }
    return [WebServiceConnector checkConnectionToWebService:javaWebServiceUrl];
    
}

#pragma mark Characteristics

- (void)addNewSuperCharacteristicWithName:(NSString *)superCharacteristicName
{
    //do not add empty name
    if ([superCharacteristicName isEqualToString:@""]) {
        return;
    }
    //add new supercharacteristic
    [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:superCharacteristicName toManagedObjectContext:self.managedObjectContext];
}

- (void)addNewCharacteristicWithName:(NSString *)characteristicName toSuperCharacteristicNamed:(NSString *)superCharacteristicName
{
    //do not add empty name
    if ([characteristicName isEqualToString:@""]) {
        return;
    }
    //add new characteristic
    [AvailableCharacteristic addNewAvailableCharacteristic:characteristicName toSuperCharacteristic:superCharacteristicName toManagedObjectContext:self.managedObjectContext];
}

- (void)changeNameOfSuperCharacteristicFrom:(NSString *)formerName to:(NSString *)newName
{
    //replace name
    [AvailableSuperCharacteristic replaceAvailableSuperCharacteristic:formerName withAvailableCharacteristic:newName inManagedObjectContext:self.managedObjectContext];
    //replace name in every project that uses supercharacterstic
    [SuperCharacteristic replaceSupercharacteristic:formerName withSupercharacteristic:newName inEveryProjectinManagedObjectContext:self.managedObjectContext];
}

- (void)changeNameOfCharacteristicFrom:(NSString *)formerName to:(NSString *)newName
{
    //replace name
    [AvailableCharacteristic replaceAvailableCharacteristic:formerName withAvailableCharacteristic:newName inManagedObjectContext:self.managedObjectContext];
    //replace name in every project that uses this characteristic
    [Characteristic replaceCharacteristic:formerName withCharacteristic:newName inEveryProjectinManagedObjectContext:self.managedObjectContext];
    
}

- (void)deleteSuperCharacteristicNamed:(NSString *)name
{
    [AvailableSuperCharacteristic deleteAvailableSuperCharacteristicNamed:name fromManagedObjectContext:self.managedObjectContext];
}



//delete available characteristic with name
- (void)deleteCharacteristicNamed:(NSString *)name
{
    [AvailableCharacteristic deleteAvailableCharacteristicNamed:name fromManagedObjectContext:self.managedObjectContext];
}


//returns a multidimensional array of supercharacteristics and subcharacteristics
//0->superchars     1->subchars
//index i of subchars contains array with all subchars that belong to superchar of index i
- (NSArray *)getSuperCharacteristicsAndCharacteristics
{
    //getting characteristics from core database
    NSArray *matches = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
    
    //initialize arrays for super- and subcharacteristics
    NSMutableArray *superchar = [NSMutableArray array];
    NSMutableArray *subchar = [NSMutableArray array];
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //add supercharacteristics name to array
        [superchar addObject:tmpasc.name];
        
        //add all subcharacteristics names to array
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *enumerator = [NSArray arrayWithArray:[tmpasc.availableSuperCharacteristicOf allObjects]];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            [tmp addObject:tmpcharacteristic.name];
            
        }
        [tmp sortUsingSelector:@selector(compare:)];
        [subchar addObject:tmp];
    }
    
    return [NSArray arrayWithObjects:superchar, subchar, nil];
}

- (void)restoreDefaultSettings
{    
    //delete all supercharacteristics
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request1.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches1 = [self.managedObjectContext executeFetchRequest:request1 error:&error];
    
    for (int i=0; i<[matches1 count]; i++) {
        //delete supercharacteristic, cascade will delete all characteristics that belong to it
        [self.managedObjectContext deleteObject:[matches1 objectAtIndex:i]];
    }
    
    //delete all projects
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request2.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSArray *matches2 = [self.managedObjectContext executeFetchRequest:request2 error:&error];
    
    for (int i=0; i<[matches2 count]; i++) {
        //delete supercharacteristic, cascade will delete all characteristics that belong to it
        [self.managedObjectContext deleteObject:[matches2 objectAtIndex:i]];
    }
    
    //insert root rating characteristics
    [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Software Object Communication" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication of Requirements" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication among Developers" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Business Process Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Functional Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Technical Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    
}
@end

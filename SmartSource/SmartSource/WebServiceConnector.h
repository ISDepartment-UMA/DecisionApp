//
//  WebServiceConnector.h
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import <Foundation/Foundation.h>

@interface WebServiceConnector : NSObject
+ (NSArray *)getAllComponentsForProjectId:(NSString *)projectID;
+ (NSDictionary *)getProjectInfoDictionary:(NSString *)projectID;
+ (NSDictionary *)getComponentForID:(NSString *)componentID;
+ (NSArray *)getAllProjectNames;
+ (NSArray *)getProjectInfoArray:(NSString *)projectID;
+ (NSString *)checkLoginData:(NSArray *)loginData withServiceUrl:(NSString *)javaServiceURL;
+ (BOOL)checkConnectionToWebService:(NSString *)javaWebServiceUrl;
+ (BOOL)uploadFileWithPath:(NSString *)filePath withName:(NSString *)fileName toProject:(NSString *)projectID;
+ (NSArray *)getRequirementsAndInterdependenciesForProject:(NSString *)projectID;
@end

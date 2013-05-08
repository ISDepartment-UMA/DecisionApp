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

@end

//
//  SettingsModel.h
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import <Foundation/Foundation.h>

@interface SettingsModel : NSObject

//instance methods - managed object context needed
- (void)addNewSuperCharacteristicWithName:(NSString *)superCharacteristicName;
- (void)addNewCharacteristicWithName:(NSString *)characteristicName toSuperCharacteristicNamed:(NSString *)superCharacteristicName;
- (void)changeNameOfSuperCharacteristicFrom:(NSString *)formerName to:(NSString *)newName;
- (void)changeNameOfCharacteristicFrom:(NSString *)formerName to:(NSString *)newName;
- (void)deleteSuperCharacteristicNamed:(NSString *)name;
- (void)deleteCharacteristicNamed:(NSString *)name;
- (NSArray *)getSuperCharacteristicsAndCharacteristics;
- (void)restoreDefaultSettings;
//class variables
+ (void)setWebServiceUrl:(NSString *)webServiceUrl;
+ (NSString *)getWebServiceUrl;
+ (void)setLoginData:(NSArray *)loginData;
+ (NSArray *)getLoginData;
+ (NSString *)checkLoginData:(NSArray *)loginData;
+ (BOOL)checkConnectionToWebServer:(NSString *)javaWebServiceUrl;

@end

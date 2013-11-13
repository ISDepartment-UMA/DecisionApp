//
//  PDFExporter.h
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import <Foundation/Foundation.h>
#import "ProjectModel.h"

@interface PDFExporter : NSObject

- (NSString *)generatePdfPrinterFriendly:(BOOL)printerFriendly;
- (PDFExporter *)initWithProjectModel:(ProjectModel *)projectModel;

@end

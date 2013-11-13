//
//  PDFExporter.m
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import "PDFExporter.h"
#import "Component.h"
#import "UIColor+SmartSourceColors.h"
#import "ComponentModel.h"
#import "SmartSourceFunctions.h"
#import "SuperCharacteristic.h"




@interface PDFExporter ()

@property (nonatomic, strong) ProjectModel *projectModel;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) NSArray *resultArray;

@end
@implementation PDFExporter
@synthesize projectModel = _projectModel;
@synthesize currentPage = _currentPage;
@synthesize resultArray = _resultArray;

//static variables
static CGSize pageSize;
static CGSize landscapePageSize;
static UIFont *titleFont;
static UIFont *explanationFont;
static UIFont *classificationHeaderFont;
static UIFont *headerMiniFont;
static UIFont *tableHeaderFont;
static UIFont *tableContentFont;
//distances
static float leftBorderScreen;
static float kBorderInset = 20.0;
static float kBorderWidth = 0.0;
static float tableLineWidth = 0.2f;
static float kMarginInset = 0.2f;
//colors
static UIColor *tableLineColor;
static UIColor *tableContentFontColor;
static UIColor *backGroundColor;


#pragma mark Initializer and creation methods

- (PDFExporter *)initWithProjectModel:(ProjectModel *)projectModel;
{
    self = [super init];
    self.projectModel = projectModel;
    self.resultArray = [projectModel calculateResults];
    return self;
}


- (NSString *)generatePdfPrinterFriendly:(BOOL)printerFriendly
{
    //page size - default dinA4 size
    pageSize = CGSizeMake(612, 792);
    landscapePageSize = CGSizeMake(pageSize.height, pageSize.width);
    leftBorderScreen = kBorderInset + kBorderWidth;
    //font definition
    titleFont = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:15.0];
    explanationFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:12.0];
    classificationHeaderFont = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:15.0];
    headerMiniFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:6.0];
    tableContentFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:8.0];
    tableHeaderFont = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:8.0];
    //color definition
    if (printerFriendly) {
        backGroundColor = [UIColor whiteColor];
        tableLineColor = [UIColor blackColor];
        tableContentFontColor = [UIColor colorDarkGray];
    } else {
        backGroundColor = [UIColor colorDarkGray];
        tableLineColor = [UIColor colorDarkWhite];
        tableContentFontColor = [UIColor colorDarkWhite];
    }
    
    //document path
    NSString *fileName = [[@"SmartSourcer Results - " stringByAppendingString:[self.projectModel getProjectName]] stringByAppendingString:@".pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    [self generatePdfWithFilePath:pdfFileName];
    return pdfFileName;
}


- (void)generatePdfWithFilePath:(NSString *)thefilePath
{
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, nil);
    
    self.currentPage = 0;
    
    if (self.currentPage == 0) {
        //draw overview over outsourcing recommendations
        [self drawOverview];
    }
    
    for (NSArray *category in self.resultArray) {
        for (Component *currComponent in category) {
            [self drawComponentExplanationForComponent:currComponent];
        }
    }
    
    //draw overview table
    [self drawOverViewTable];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (CGContextRef)startNewPageInPortraitMode:(BOOL)portrait
{
    //start new page
    self.currentPage++;
    CGSize sizeToUse = pageSize;
    if (!portrait) {
        sizeToUse = landscapePageSize;
    }
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, sizeToUse.width, sizeToUse.height), nil);
    //if pdf is not to be printerfriendly, draw rect with backgroundcolor
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [backGroundColor set];
    CGContextFillRect(currentContext, CGRectMake(0, 0, sizeToUse.width, sizeToUse.height));
    return currentContext;
}






# pragma mark Initial Overview

- (void)drawOverview
{
    // Mark the beginning of a new page.
    CGContextRef currentContext = [self startNewPageInPortraitMode:YES];
    
    CGContextSetRGBFillColor(currentContext, 0.53, 0.53, 0.53, 1.0);
    NSString *projectTitle = [self.projectModel getProjectName];
    UIFont *font = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:25.0];
    CGSize stringSize = [projectTitle sizeWithFont:font constrainedToSize: CGSizeMake(pageSize.width - 2*leftBorderScreen, pageSize.height - 2*leftBorderScreen) lineBreakMode:UILineBreakModeWordWrap];
    CGRect renderingRect = CGRectMake(((pageSize.width/2) - (0.5*stringSize.width)), (leftBorderScreen + 50), stringSize.width, stringSize.height);
    [projectTitle drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    //results
    CGContextSetRGBFillColor(currentContext, 1.0, 0.58, 0.0, 1.0);
    NSString *const1 = @"SmartSourcer Results";
    stringSize = [const1 sizeWithFont:font constrainedToSize: CGSizeMake(pageSize.width - 2*leftBorderScreen, pageSize.height - 2*leftBorderScreen) lineBreakMode:UILineBreakModeWordWrap];
    renderingRect = CGRectMake(((pageSize.width/2) - (0.5*stringSize.width)), (renderingRect.origin.y + renderingRect.size.height + 10), stringSize.width, stringSize.height);
    [const1 drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    
    //titles
    CGFloat widthOfImage = (pageSize.width - (2*leftBorderScreen) - 40) / 3;
    renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + renderingRect.size.height + 50), widthOfImage, 31);
    font = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:15.0];
    UIColor *titleFontColor = [UIColor blackColor];
    UIColor *titleBackGroundColor = [UIColor colorWithRed:1.0 green:0.53 blue:0.0 alpha:1.0];
    [self drawString:@"Core" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((leftBorderScreen + widthOfImage + 20), renderingRect.origin.y, widthOfImage, 31);
    [self drawString:@"Outsourcing" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((leftBorderScreen + 2*widthOfImage + 40), renderingRect.origin.y, widthOfImage, 31);
    [self drawString:@"Indifferent" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    
    
    //title images
    UIImage *imageCore = [UIImage imageNamed:@"Result_In.png"];
    renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + 30), widthOfImage, ((widthOfImage/imageCore.size.width)*imageCore.size.height));
    [imageCore drawInRect:renderingRect];
    
    UIImage *imageOutsourcing = [UIImage imageNamed:@"Result_Out.png"];
    renderingRect = CGRectMake((leftBorderScreen + widthOfImage + 20), renderingRect.origin.y, widthOfImage, ((widthOfImage/imageCore.size.width)*imageCore.size.height));
    [imageOutsourcing drawInRect:renderingRect];
    
    UIImage *imageIndifferent = [UIImage imageNamed:@"Result_Un.png"];
    renderingRect = CGRectMake((leftBorderScreen + 2*widthOfImage + 40), renderingRect.origin.y, widthOfImage, ((widthOfImage/imageCore.size.width)*imageCore.size.height));
    [imageIndifferent drawInRect:renderingRect];
    
    //put components into overview
    CGFloat originOfOverviewTable = renderingRect.origin.y + renderingRect.size.height + 20;
    renderingRect = CGRectMake(leftBorderScreen, originOfOverviewTable, widthOfImage, 30);
    font = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:12.0];
    
    //drawing from left to right, one compponent of each category at a time
    NSInteger maxNumberOfComponentsInCategory = MAX([[self.resultArray objectAtIndex:0] count], MAX([[self.resultArray objectAtIndex:1] count], [[self.resultArray objectAtIndex:2] count]));
    //iterate lines
    for (int i=0; i<maxNumberOfComponentsInCategory; i++) {
        //calculate maximum height of component
        CGSize stringSizeOut = CGSizeMake(0.0, 0.0);
        CGSize stringSizeInd = CGSizeMake(0.0, 0.0);
        Component *currComp;
        Component *currCompOut;
        Component *currCompInd;
        if ([[self.resultArray objectAtIndex:0] count] > i) {
            currComp = [[self.resultArray objectAtIndex:0] objectAtIndex:i];
            stringSize = [currComp.name sizeWithFont:font constrainedToSize:CGSizeMake(widthOfImage, 100) lineBreakMode:UILineBreakModeWordWrap];
        }
        if ([[self.resultArray objectAtIndex:2] count] > i) {
            currCompOut = [[self.resultArray objectAtIndex:2] objectAtIndex:i];
            stringSizeOut = [currCompOut.name sizeWithFont:font constrainedToSize:CGSizeMake(widthOfImage, 100) lineBreakMode:UILineBreakModeWordWrap];
            
        }
        if ([[self.resultArray objectAtIndex:1] count] > i) {
            currCompInd = [[self.resultArray objectAtIndex:1] objectAtIndex:i];
            stringSizeInd = [currCompInd.name sizeWithFont:font constrainedToSize:CGSizeMake(widthOfImage, 100) lineBreakMode:UILineBreakModeWordWrap];
            
        }
        CGFloat maxHeightOfComp = MAX(stringSize.height, MAX(stringSizeOut.height, stringSizeInd.height));
        //if one of the three exceeds page size, start new page
        if ((renderingRect.origin.y + maxHeightOfComp) > ((self.currentPage * pageSize.height) - leftBorderScreen)) {
            //start new page
            currentContext = [self startNewPageInPortraitMode:YES];
            
            //draw title labels again
            //titles
            renderingRect = CGRectMake(leftBorderScreen, leftBorderScreen, widthOfImage, 31);
            font = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:15.0];
            [self drawString:@"Core" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
            renderingRect = CGRectMake((leftBorderScreen + widthOfImage + 20), renderingRect.origin.y, widthOfImage, 31);
            [self drawString:@"Outsourcing" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
            renderingRect = CGRectMake((leftBorderScreen + 2*widthOfImage + 40), renderingRect.origin.y, widthOfImage, 31);
            [self drawString:@"Indifferent" withFont:font inRect:renderingRect withColor:titleFontColor backGroundColor:titleBackGroundColor andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
            font = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:12.0];
            //adjust rendering rect
            renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + renderingRect.size.height + 20), widthOfImage, (maxHeightOfComp + 20));
        } else {
            renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y), widthOfImage, (maxHeightOfComp + 20));
        }
        //draw components
        if (currComp) {
            [self drawString:currComp.name withFont:font inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        }
        if (currCompOut) {
            CGRect outRect = CGRectMake((leftBorderScreen + renderingRect.size.width + 20), renderingRect.origin.y, renderingRect.size.width, renderingRect.size.height);
            [self drawString:currCompOut.name withFont:font inRect:outRect withColor:[UIColor blackColor] backGroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        }
        if (currCompInd) {
            CGRect indRect = CGRectMake((leftBorderScreen + 2*renderingRect.size.width + 40), renderingRect.origin.y, renderingRect.size.width, renderingRect.size.height);
            [self drawString:currCompInd.name withFont:font inRect:indRect withColor:[UIColor blackColor] backGroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        }
        
        renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + maxHeightOfComp + 30), widthOfImage, 30);
        
    }
}


#pragma mark Component Explanation

- (void)drawComponentExplanationForComponent:(Component *)component
{
    //start new page
    CGContextRef currentContext = [self startNewPageInPortraitMode:NO];
    
    //draw title
    CGRect renderingRect = CGRectMake(leftBorderScreen, leftBorderScreen, (landscapePageSize.width - 2*leftBorderScreen), 30);
    [self drawString:component.name withFont:titleFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorOrange] andTextAlignment:NSTextAlignmentLeft inContext:currentContext];
    //get result details
    ComponentModel *componentModel = [[ComponentModel alloc] initWithComponentId:component.componentID];
    NSDictionary *componentResults = [componentModel calculateDetailedResults];
    //width of views
    CGFloat widthOfImage = 150;
    CGFloat widthOfExplanation = (345.0/1024.0) * (landscapePageSize.width - (2*leftBorderScreen));
    CGFloat widthOfClassification = landscapePageSize.width - 2*leftBorderScreen - widthOfExplanation - widthOfImage - 10;
    //draw explanation
    renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + renderingRect.size.height + 5), widthOfExplanation, 150);
    [self drawString:[componentResults objectForKey:@"explanationText"] withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentLeft inContext:currentContext];
    //draw category
    CGFloat yOriginOfCategory = renderingRect.origin.y;
    renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width + 5), renderingRect.origin.y, (widthOfClassification/2), 60);
    [self drawString:@"Classification" withFont:classificationHeaderFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentRight inContext:currentContext];
    renderingRect = CGRectMake(renderingRect.origin.x, (renderingRect.origin.y + renderingRect.size.height), renderingRect.size.width, 30);
    [self drawString:@"Sum of Weighted Averages" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentRight inContext:currentContext];
    renderingRect = CGRectMake(renderingRect.origin.x, (renderingRect.origin.y + renderingRect.size.height), renderingRect.size.width, 60);
    [self drawString:@"Scale" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentRight inContext:currentContext];
    CGFloat weightedAverage = [[componentResults objectForKey:@"weightedSumOfSupercharacteristics"] floatValue];
    NSString *classification = [SmartSourceFunctions getOutIndCoreStringForWeightedAverageValue:weightedAverage];
    renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width), yOriginOfCategory, renderingRect.size.width, 60);
    [self drawString:classification withFont:classificationHeaderFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake(renderingRect.origin.x, (renderingRect.origin.y + renderingRect.size.height), renderingRect.size.width, 30);
    [self drawString:[NSString stringWithFormat:@"%.1f", weightedAverage] withFont:classificationHeaderFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor colorLightGray] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake(renderingRect.origin.x, (renderingRect.origin.y + renderingRect.size.height), renderingRect.size.width, 60);
    [self drawScaleViewInRect:renderingRect forValue:weightedAverage];
    
    //draw icon
    renderingRect = CGRectMake((landscapePageSize.width - leftBorderScreen - widthOfImage), yOriginOfCategory, widthOfImage, widthOfImage);
    UIImage *rightImage = [SmartSourceFunctions getImageForWeightedAverageValue:weightedAverage];
    [rightImage drawInRect:renderingRect];
    
    //header supercharactersitics
    renderingRect = CGRectMake(leftBorderScreen, (renderingRect.origin.y + renderingRect.size.height + 10), (landscapePageSize.width - (2*leftBorderScreen)), 30);
    [self drawString:@"SUPERCHARACTERISTICS" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorOrange] andTextAlignment:NSTextAlignmentLeft inContext:currentContext];
    
    //draw header line from right to left
    //text
    renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width - 70), renderingRect.origin.y, 70, renderingRect.size.height);
    [self drawString:@"Weighted Average" withFont:headerMiniFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //placeholder
    renderingRect = CGRectMake((renderingRect.origin.x - 3.19), renderingRect.origin.y, 3.19, renderingRect.size.height);
    [[UIColor colorDarkGray] set];
    CGContextFillRect(currentContext, renderingRect);
    //text
    renderingRect = CGRectMake((renderingRect.origin.x - 70), renderingRect.origin.y, 70, renderingRect.size.height);
    [self drawString:@"Weight" withFont:headerMiniFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //placeholder
    renderingRect = CGRectMake((renderingRect.origin.x - 3.19), renderingRect.origin.y, 3.19, renderingRect.size.height);
    [[UIColor colorDarkGray] set];
    CGContextFillRect(currentContext, renderingRect);
    //text
    renderingRect = CGRectMake((renderingRect.origin.x - 70), renderingRect.origin.y, 70, renderingRect.size.height);
    [self drawString:@"Rating Average" withFont:headerMiniFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //placeholder
    renderingRect = CGRectMake((renderingRect.origin.x - 3.19), renderingRect.origin.y, 3.19, renderingRect.size.height);
    [[UIColor colorDarkGray] set];
    CGContextFillRect(currentContext, renderingRect);
    //text
    renderingRect = CGRectMake((renderingRect.origin.x - 70), renderingRect.origin.y, 70, renderingRect.size.height);
    [self drawString:@"Evaluation" withFont:headerMiniFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //placeholder
    renderingRect = CGRectMake((renderingRect.origin.x - 3.19), renderingRect.origin.y, 3.19, renderingRect.size.height);
    [[UIColor colorDarkGray] set];
    CGContextFillRect(currentContext, renderingRect);
    
    //supercharacteristics
    CGFloat yOriginOfCells = renderingRect.origin.y + renderingRect.size.height + 5;
    CGFloat heightOfAllPreviousSubCharViews = 0.0;
    NSArray *valuesForCells = [componentResults objectForKey:@"valuesForCells"];
    for (int i=0; i<[valuesForCells count]; i++) {
        //get characteristics
        NSArray *chars = [componentResults objectForKey:@"chars"];
        NSArray *subCharacteristicsValues = [[chars objectAtIndex:1] objectAtIndex:i];
        NSArray *subCharacteristicsUsed = [[chars objectAtIndex:0] objectAtIndex:i];
        CGFloat yOriginOfThisCell = (yOriginOfCells + 35*i + heightOfAllPreviousSubCharViews);
        //if not enough space on current page, start new page
        CGFloat heightOfSuperCharContent = 75 + ([subCharacteristicsUsed count])*30;
        //if height of content is smaller than 165 -> upsize it
        heightOfSuperCharContent = MAX(heightOfSuperCharContent, 165.0);
        if ((yOriginOfThisCell + heightOfSuperCharContent) > (landscapePageSize.height - leftBorderScreen)) {
            //start new page
            currentContext = [self startNewPageInPortraitMode:NO];
            yOriginOfThisCell = leftBorderScreen;
            heightOfAllPreviousSubCharViews = 0.0;
        }
        //draw cell
        renderingRect =  CGRectMake(leftBorderScreen, yOriginOfThisCell, (landscapePageSize.width - (2*leftBorderScreen)), 30);
        [[UIColor colorLightGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //draw arrow
        renderingRect = CGRectMake((leftBorderScreen + 9.26), (renderingRect.origin.y + 3.5), 11.48, 23);
        UIImage *arrow = [UIImage imageNamed:@"evaluation_pfeil.png"];
        [arrow drawInRect:renderingRect];
        //draw placeholder
        renderingRect = CGRectMake((leftBorderScreen +30), yOriginOfThisCell, 3.19, 30);
        [[UIColor colorDarkGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //draw superchar name
        renderingRect = CGRectMake((leftBorderScreen + 36), yOriginOfThisCell, 300, 30);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:0] withFont:titleFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentLeft inContext:currentContext];
        //headers
        //weighted average
        renderingRect = CGRectMake((landscapePageSize.width - leftBorderScreen - 70), yOriginOfThisCell, 70, 30);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:4] withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //placeholder
        renderingRect = CGRectMake((renderingRect.origin.x - 3.19), yOriginOfThisCell, 3.19, renderingRect.size.height);
        [[UIColor colorDarkGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //weight
        renderingRect = CGRectMake((renderingRect.origin.x - 70), yOriginOfThisCell, 70, renderingRect.size.height);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:3] withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //placeholder
        renderingRect = CGRectMake((renderingRect.origin.x - 3.19), yOriginOfThisCell, 3.19, renderingRect.size.height);
        [[UIColor colorDarkGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //rating average
        renderingRect = CGRectMake((renderingRect.origin.x - 70), yOriginOfThisCell, 70, renderingRect.size.height);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:2] withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //placeholder
        renderingRect = CGRectMake((renderingRect.origin.x - 3.19), yOriginOfThisCell, 3.19, renderingRect.size.height);
        [[UIColor colorDarkGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //evaluation
        renderingRect = CGRectMake((renderingRect.origin.x - 70), yOriginOfThisCell, 70, renderingRect.size.height);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:1] withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //placeholder
        renderingRect = CGRectMake((renderingRect.origin.x - 3.19), yOriginOfThisCell, 3.19, renderingRect.size.height);
        [[UIColor colorDarkGray] set];
        CGContextFillRect(currentContext, renderingRect);
        
        //draw subcharacteristics
        //size of rect
        CGFloat heightOfSubCharRect = heightOfSuperCharContent - 35; //35 of cell header and placeholder
        CGFloat widthOfSubCharRect = landscapePageSize.width - 2*leftBorderScreen - 33.19;
        CGFloat xOriginOfSubCharRect = leftBorderScreen + 33.19;
        CGFloat yOriginOfSubCharRect = yOriginOfThisCell + 35;
        renderingRect = CGRectMake((leftBorderScreen + 33.19), (yOriginOfThisCell + 35), widthOfSubCharRect, heightOfSubCharRect);
        
        
        heightOfAllPreviousSubCharViews += (renderingRect.size.height + 10);
        [[UIColor colorLightGray] set];
        CGContextFillRect(currentContext, renderingRect);
        //header
        //characteristics
        CGFloat oneWidthEntity = (widthOfSubCharRect/5.0);
        renderingRect = CGRectMake(xOriginOfSubCharRect, yOriginOfSubCharRect, (2*oneWidthEntity), 40);
        [self drawString:@"CHARACTERISTICS" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        renderingRect = CGRectMake((xOriginOfSubCharRect + 1.5*oneWidthEntity), yOriginOfSubCharRect, oneWidthEntity, 40);
        [self drawString:@"RATING" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        renderingRect = CGRectMake((xOriginOfSubCharRect + 2.5*oneWidthEntity), yOriginOfSubCharRect, oneWidthEntity, 40);
        [self drawString:@"AVERAGE" withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        renderingRect = CGRectMake((xOriginOfSubCharRect + 4*oneWidthEntity), yOriginOfSubCharRect, oneWidthEntity, 40);
        [self drawString:@"WEIGHTED AVG." withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //content of subcharacteristics
        CGFloat yOriginOfSubcharacteristics = yOriginOfSubCharRect + 40;
        //add subchar values for average
        CGFloat sumOfSubchars = 0.0;
        for (int y=0; y<[subCharacteristicsUsed count]; y++) {
            NSString *subCharName = [subCharacteristicsUsed objectAtIndex:y];
            NSInteger value = [[subCharacteristicsValues objectAtIndex:y] integerValue];
            sumOfSubchars += value;
            //draw name
            renderingRect = CGRectMake((xOriginOfSubCharRect + 5), (yOriginOfSubcharacteristics + y*30), (2*oneWidthEntity - 20), 30);
            [self drawString:subCharName withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentLeft inContext:currentContext];
            //draw rating
            renderingRect = CGRectMake((renderingRect.origin.x + 1.5*oneWidthEntity), renderingRect.origin.y, oneWidthEntity, 30);
            NSString *valueString = [SmartSourceFunctions getHighMediumLowStringForIntValue:value];
            UIColor *valueColor = [SmartSourceFunctions getColorForStringRatingValue:valueString];
            [self drawString:valueString withFont:explanationFont inRect:renderingRect withColor:valueColor backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        }
        //arrow
        renderingRect = CGRectMake((xOriginOfSubCharRect + 2.5*oneWidthEntity - 16), (yOriginOfSubCharRect + ((heightOfSubCharRect/2) - 40)), 33, 100);
        UIImage *arrow1 = [UIImage imageNamed:@"Pfeil.png"];
        [arrow1 drawInRect:renderingRect];
        CGFloat yOriginOfScaleView = renderingRect.origin.y + 55;
        //average string
        NSString *stringNumericValue = [[valuesForCells objectAtIndex:i] objectAtIndex:2];
        NSString *stringLabelValue = [SmartSourceFunctions getHighMediumLowStringForFloatValue:[stringNumericValue floatValue]];
        UIColor *textColor = [SmartSourceFunctions getColorForStringRatingValue:stringLabelValue];
        renderingRect = CGRectMake((xOriginOfSubCharRect + 2.5*oneWidthEntity), (yOriginOfSubCharRect + 40), oneWidthEntity, 30);
        [self drawString:stringLabelValue withFont:titleFont inRect:renderingRect withColor:textColor backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        renderingRect = CGRectMake(renderingRect.origin.x, (renderingRect.origin.y + 20), renderingRect.size.width, renderingRect.size.height);
        [self drawString:stringNumericValue withFont:explanationFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //scale view
        renderingRect = CGRectMake(renderingRect.origin.x, yOriginOfScaleView, renderingRect.size.width, renderingRect.size.height);
        [self drawHighMediumLowScaleViewInRect:renderingRect withValue:[stringNumericValue floatValue]];
        //arrow
        renderingRect = CGRectMake((xOriginOfSubCharRect + 3.5*oneWidthEntity), (yOriginOfSubCharRect + ((heightOfSubCharRect/2) - 40)), 33, 100);
        [arrow1 drawInRect:renderingRect];
        //weight
        renderingRect = CGRectMake((xOriginOfSubCharRect + 3.75*oneWidthEntity), (yOriginOfSubCharRect + ((heightOfSubCharRect/2) - 5)), 50, 30);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:3] withFont:titleFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //arrow
        renderingRect = CGRectMake((xOriginOfSubCharRect + 4.25*oneWidthEntity), (yOriginOfSubCharRect + ((heightOfSubCharRect/2) - 40)), 33, 100);
        [arrow1 drawInRect:renderingRect];
        //weighted average
        renderingRect = CGRectMake((xOriginOfSubCharRect + 4.6*oneWidthEntity), (yOriginOfSubCharRect + ((heightOfSubCharRect/2) - 5)), 50, 30);
        [self drawString:[[valuesForCells objectAtIndex:i] objectAtIndex:4] withFont:titleFont inRect:renderingRect withColor:[UIColor colorDarkWhite] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        
        
    }
    
    
    
}

- (void)drawScaleViewInRect:(CGRect)frame forValue:(CGFloat)value
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //draw background rect
    [[UIColor colorLightGray] set];
    CGContextFillRect(currentContext, frame);
    //draw bar with entities
    [[UIColor blackColor] set];
    CGFloat xOrigin = frame.origin.x + ((frame.size.width - 162.42) / 2.0);
    CGRect renderingRect = CGRectMake(xOrigin, (frame.origin.y + 23), 162.42, 5.7);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake(xOrigin, (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((xOrigin + 52.6), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((xOrigin + 106.74), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((xOrigin + 160.87), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    //draw labels
    UIFont *miniFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:6.0];
    renderingRect = CGRectMake(xOrigin,  (frame.origin.y + 33), 54.14, 17.32);
    [self drawString:@"OUTSOURCING" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((xOrigin + 54.14),  (frame.origin.y + 33), 54.14, 17.32);
    [self drawString:@"INDIFFERENT" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((xOrigin + 108.28),  (frame.origin.y + 33), 54.14, 17.32);
    [self drawString:@"CORE" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //draw triangle
    UIImage *triangle = [UIImage imageNamed:@"Dreieck.png"];
    CGFloat absoluteValue = (((value-1)/2.0) * 162.00);
    renderingRect = CGRectMake((xOrigin + absoluteValue - 7), (frame.origin.y + 14), 14, 12.37);
    [triangle drawInRect:renderingRect];
    
}

- (void)drawHighMediumLowScaleViewInRect:(CGRect)frame withValue:(CGFloat)value
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //background color clear
    //draw bar with entities
    [[UIColor blackColor] set];
    CGFloat xOrigin = frame.origin.x + ((frame.size.width - 116.02) / 2.0);
    CGRect renderingRect = CGRectMake(xOrigin, (frame.origin.y + 23), 116.02, 5.7);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake(xOrigin, (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((xOrigin + 37.13), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((xOrigin + 75.8), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    renderingRect = CGRectMake((2*frame.origin.x + frame.size.width - xOrigin - 1.54), (frame.origin.y + 28.4), 1.54, 9.89);
    CGContextFillRect(currentContext, renderingRect);
    //draw labels
    UIFont *miniFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:6.0];
    renderingRect = CGRectMake(xOrigin,  (frame.origin.y + 33), 38.67, 17.32);
    [self drawString:@"LOW" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((xOrigin + 38.67),  (frame.origin.y + 33), 38.67, 17.32);
    [self drawString:@"MEDIUM" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    renderingRect = CGRectMake((xOrigin + 77.34),  (frame.origin.y + 33), 38.67, 17.32);
    [self drawString:@"HIGH" withFont:miniFont inRect:renderingRect withColor:[UIColor blackColor] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //draw triangle
    UIImage *triangle = [UIImage imageNamed:@"Dreieck.png"];
    CGFloat absoluteValue = (((value-1)/2.0) * 115.0);
    renderingRect = CGRectMake((xOrigin + absoluteValue - 7), (frame.origin.y + 14), 14, 12.37);
    [triangle drawInRect:renderingRect];
    
}

#pragma mark OverView Table
//constant values for overview table
static CGFloat widthOfComponentName = 90;
CGFloat widthOfResult = 60;
CGFloat widthOfSuperCharacteristic = 75;
static CGFloat widthOfTitle = 300;
static CGFloat heightOfHeader = 50;

- (void)drawHeaderAndTableFrameForOverViewTableFromYOrigin:(CGFloat)yOrigin inContext:(CGContextRef)currentContext
{
    //horizontal line
    [self drawHorizontalLineWithDistanceFromTop:yOrigin];
    //first vertical line
    [self drawVerticalLineFromYOrigin:yOrigin withXValue:leftBorderScreen];
    //component header
    CGRect renderingRect = CGRectMake(leftBorderScreen, yOrigin, widthOfComponentName, heightOfHeader);
    [self drawString:@"Component" withFont:tableHeaderFont inRect:renderingRect withColor:[UIColor colorOrange] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //second vertical line
    [self drawVerticalLineFromYOrigin:yOrigin withXValue:(renderingRect.origin.x + renderingRect.size.width)];
    renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width), renderingRect.origin.y, widthOfResult, heightOfHeader);
    [self drawString:@"Result" withFont:tableHeaderFont inRect:renderingRect withColor:[UIColor colorOrange] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    //third vertical line
    [self drawVerticalLineFromYOrigin:yOrigin withXValue:(renderingRect.origin.x + renderingRect.size.width)];
    //supercharacteristics names
    Component *someComponent = [[[[self.projectModel getProjectObject] consistsOf] objectEnumerator] nextObject];
    ComponentModel *componentModel = [[ComponentModel alloc] initWithComponentId:someComponent.componentID];
    NSArray *superChars = [[componentModel getCharsAndValuesArray] objectAtIndex:0];
    //iterate supercharacteristics
    for (int i=0; i<[[superChars objectAtIndex:0] count]; i++) {
        //supercharacteristic with weight
        NSString *nameOfSuperCharacteristic = [NSString stringWithFormat:@"%@\r(%@)",[[superChars objectAtIndex:0] objectAtIndex:i], [[superChars objectAtIndex:2] objectAtIndex:i]];
        renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width), renderingRect.origin.y, widthOfSuperCharacteristic, heightOfHeader);
        [self drawString:nameOfSuperCharacteristic withFont:tableHeaderFont inRect:renderingRect withColor:[UIColor colorOrange] backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
        //vertical lines
        [self drawVerticalLineFromYOrigin:yOrigin withXValue:(renderingRect.origin.x + renderingRect.size.width)];
    }
    //second horizontal line
    [self drawHorizontalLineWithDistanceFromTop:(yOrigin + heightOfHeader)];
    //vertical line to close framework in the right
    if ([[superChars objectAtIndex:0] count] < 8) {
        [self drawVerticalLineFromYOrigin:yOrigin withXValue:(landscapePageSize.width - leftBorderScreen)];
    }
    
}

/*
 draws a vertical line starting from the specified yOrigin to the bottom of the page and
 distance to the page border on the x axis
 */
- (void)drawVerticalLineFromYOrigin:(CGFloat)yOrigin withXValue:(CGFloat)xValue
{
    [self drawLineFrom:CGPointMake(xValue, yOrigin) to:CGPointMake(xValue, (landscapePageSize.height - leftBorderScreen))];
}

/*
 draws a horizontal line through the entire page width with the specified distance to the
 page top
 */
- (void)drawHorizontalLineWithDistanceFromTop:(CGFloat)yValue
{
    [self drawLineFrom:CGPointMake(leftBorderScreen, yValue) to:CGPointMake((landscapePageSize.width - leftBorderScreen), yValue)];
}



- (void)drawOverViewTable
{
    //start new page
    CGContextRef currentContext = [self startNewPageInPortraitMode:NO];
    //title
    CGFloat xOriginOfTitle = ((landscapePageSize.width - 2*leftBorderScreen)/2.0) - (widthOfTitle/2.0);
    CGRect renderingRect = CGRectMake(xOriginOfTitle, leftBorderScreen, widthOfTitle, 30);
    [self drawString:@"Overview" withFont:titleFont inRect:renderingRect withColor:[UIColor colorDarkGray] backGroundColor:[UIColor colorOrange] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
    
    //draw header and table frame
    CGFloat yOriginNextElement = (renderingRect.origin.y + renderingRect.size.height + 10);
    [self drawHeaderAndTableFrameForOverViewTableFromYOrigin:yOriginNextElement inContext:currentContext];
    yOriginNextElement = yOriginNextElement + heightOfHeader;
    
    //put components in there
    //iterate components and add them
    for (NSArray *category in self.resultArray) {
        for (Component *currComponent in category) {
            //get component valeus
            ComponentModel *componentModel = [[ComponentModel alloc] initWithComponentId:currComponent.componentID];
            NSDictionary *componentResults = [componentModel calculateDetailedResults];
            NSArray *valuesForCells = [componentResults objectForKey:@"valuesForCells"];
            //name
            //if component does not fit, start new page
            CGFloat heightOfRow = 50;
            renderingRect = CGRectMake(leftBorderScreen, yOriginNextElement, widthOfComponentName, heightOfRow);
            if ((renderingRect.origin.y + renderingRect.size.height) > (landscapePageSize.height - leftBorderScreen)) {
                //cut of protruding lines from under the last line
                [backGroundColor set];
                CGContextFillRect(currentContext, CGRectMake(0, (yOriginNextElement + tableLineWidth), landscapePageSize.width, (landscapePageSize.height - yOriginNextElement)));
                //start new page
                currentContext = [self startNewPageInPortraitMode:NO];
                //draw header and frame
                [self drawHeaderAndTableFrameForOverViewTableFromYOrigin:leftBorderScreen inContext:currentContext];
                yOriginNextElement = (leftBorderScreen + heightOfHeader + 5);
                renderingRect = CGRectMake(leftBorderScreen, yOriginNextElement, widthOfComponentName, heightOfRow);
                
            }
            [self drawString:currComponent.name withFont:tableContentFont inRect:renderingRect withColor:tableContentFontColor backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
            //rating result
            CGFloat weightedAverage = [[componentResults objectForKey:@"weightedSumOfSupercharacteristics"] floatValue];
            NSString *weightedAverageString = [SmartSourceFunctions getOutIndCoreStringForWeightedAverageValue:weightedAverage];
            weightedAverageString = [NSString stringWithFormat:@"%@\r(%.1f)", weightedAverageString, weightedAverage];
            renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width), yOriginNextElement, widthOfResult, heightOfRow);
            [self drawString:weightedAverageString withFont:tableContentFont inRect:renderingRect withColor:tableContentFontColor backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
            for (int superCharIndex = 0; superCharIndex < [valuesForCells count]; superCharIndex++) {
                //average
                NSString *averageValue = [[valuesForCells objectAtIndex:superCharIndex] objectAtIndex:2];
                CGFloat floatValue = [averageValue floatValue];
                NSString *valueString = [SmartSourceFunctions getHighMediumLowStringForFloatValue:floatValue];
                valueString = [NSString stringWithFormat:@"%@\r(%.1f)", valueString, floatValue];
                renderingRect = CGRectMake((renderingRect.origin.x + renderingRect.size.width), yOriginNextElement, widthOfSuperCharacteristic, heightOfRow);
                [self drawString:valueString withFont:tableContentFont inRect:renderingRect withColor:tableContentFontColor backGroundColor:[UIColor clearColor] andTextAlignment:NSTextAlignmentCenter inContext:currentContext];
                
            }
            //next
            yOriginNextElement = yOriginNextElement + heightOfRow;
            //draw line
            [self drawHorizontalLineWithDistanceFromTop:yOriginNextElement];
        }
    }
    
    //after last component, cut of protruiding lines
    [backGroundColor set];
    CGContextFillRect(currentContext, CGRectMake(0, (yOriginNextElement + tableLineWidth), landscapePageSize.width, (landscapePageSize.height - yOriginNextElement)));
    
}

#pragma mark Low Level Drawing Methods

- (void)drawString:(NSString*)s withFont:(UIFont*)font inRect:(CGRect)contextRect withColor:(UIColor *)color backGroundColor:(UIColor *)backGroundColor andTextAlignment:(NSTextAlignment)textAlignment inContext:(CGContextRef)context{
    
    CGFloat fontHeight = [s sizeWithFont:font constrainedToSize:CGSizeMake(contextRect.size.width, contextRect.size.height) lineBreakMode:UILineBreakModeWordWrap].height;
    CGFloat yOffset = (contextRect.size.height - fontHeight) / 2.0;
    CGRect textRect = CGRectMake(contextRect.origin.x, (contextRect.origin.y + yOffset), contextRect.size.width, fontHeight);
    [backGroundColor set];
    CGContextFillRect(context, contextRect);
    [color set];
    [s drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:textAlignment];
}


- (void) drawBorder
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];
    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
}
- (void)drawLineFrom:(CGPoint)origin to:(CGPoint)destination
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, tableLineWidth);
    [tableLineColor set];
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, origin.x, origin.y);
    CGContextAddLineToPoint(currentContext, destination.x, destination.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
}
- (void) drawText
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum.";
    
    UIFont *font = [UIFont systemFontOfSize:14.0];
    
    CGSize stringSize = [textToDraw sizeWithFont:font
                               constrainedToSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
    
    [textToDraw drawInRect:renderingRect
                  withFont:font
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentLeft];
}
- (void) drawImage
{
    UIImage * demoImage = [UIImage imageNamed:@"Result_Un.png"];
    [demoImage drawInRect:CGRectMake( (pageSize.width - demoImage.size.width/2)/2, 350, demoImage.size.width/2, demoImage.size.height/2)];
}
@end

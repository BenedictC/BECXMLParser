//
//  DemoAppTests.m
//  DemoAppTests
//
//  Created by Benedict Cohen on 20/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BECXMLParser.h"
#import "BECPListElementParserFactory.h"


@interface BECXMLParser_Tests : XCTestCase
@property(nonatomic) NSInputStream *inputStream;
@property(nonatomic) id expectedResult;
@end



@implementation BECXMLParser_Tests

-(void)setUp
{
    [super setUp];

    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"testLibrary.xml" ofType:nil];
    xmlPath = [@"~/Music/iTunes/iTunes Library.xml" stringByExpandingTildeInPath];

    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    self.inputStream = [[NSInputStream alloc] initWithData:xmlData];
    [self.inputStream open];

    self.expectedResult = [NSPropertyListSerialization propertyListWithData:xmlData options:0 format:NULL error:NULL];
}



-(void)tearDown
{
    [super tearDown];
}



-(void)testExample
{
    BECPListElementParserFactory *factory = [BECPListElementParserFactory new];
    BECXMLParser *parser = [[BECXMLParser alloc] initWithInputStream:self.inputStream rootElementParserFactory:factory];

    [parser parse:^(BOOL didSucceed, id actualResult, NSError *error) {

        NSDictionary *expectedTracks = self.expectedResult[@"Tracks"];
        NSDictionary *actualTracks = actualResult[@"Tracks"];
        NSMutableSet *actualKeys = [NSMutableSet setWithArray:[actualTracks allKeys]];

        for (NSString *key in expectedTracks.allKeys) {
            [actualKeys removeObject:key];
            NSMutableDictionary *aSub = [actualTracks[key] mutableCopy];
            NSMutableDictionary *eSub = [expectedTracks[key] mutableCopy];
            BOOL result = [aSub isEqual:eSub];

            NSLog(@"%@: %i", key, result);
         }
        NSLog(@"Remaining keys: %@", actualKeys);

        XCTAssertEqualObjects(self.expectedResult, actualResult, @"Result incorrect");
    }];
}

@end

//
//  AppDelegate.m
//  DemoApp
//
//  Created by Benedict Cohen on 20/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "AppDelegate.h"
#import "BECPListElementParserFactory.h"
#import "BECXMLParser.h"



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"testLibrary.xml" ofType:nil];
    xmlPath = [@"~/Music/iTunes/iTunes Library.xml" stringByExpandingTildeInPath];

    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:xmlData];
    [inputStream open];


    BECPListElementParserFactory *factory = [BECPListElementParserFactory new];
    BECXMLParser *parser = [[BECXMLParser alloc] initWithInputStream:inputStream rootElementParserFactory:factory];

    [parser parse:^(BOOL didSucceed, id actualResult, NSError *error) {
        NSLog(@"Success?: %i", didSucceed);
    }];

}

@end

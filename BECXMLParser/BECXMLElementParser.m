//
//  BECXMLElementParser.m
//  BECXMLParser
//
//  Created by Benedict Cohen on 08/03/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BECXMLElementParser.h"



@implementation BECXMLElementParser

#pragma mark - instance life cycle
-(id)init
{
    return [self initWithParentElementParser:nil elementName:nil namespaceURI:nil attributes:nil];
}



-(instancetype)initWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes
{
    NSAssert(![[self class] isEqual:[BECXMLElementParser class]], @"BECXMLElementParser is an abstract class and should not be initalized directly. Use a subclass of BECXMLElementParser instead.");

    self = [super init];
    if (self == nil) return nil;

    _parentElementParser = parentParser;
    _elementName = [elementName copy];
    _namespaceURI = [namespaceURI copy];
    _attributes = [attributes copy];

    return self;
}



#pragma mark - BECXMLElementParser protocol
-(NSError *)handleCharacters:(NSString *)string
{
    return nil;
}



-(NSError *)handleCDATA:(NSData *)CDATABlock
{
    return nil;
}



-(NSError *)handleIgnorableWhitespace:(NSString *)whitespaceString
{
    return nil;
}



-(NSError *)handleComment:(NSString *)comment
{
    return nil;
}



-(NSError *)addChildObject:(id)object forElementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
{
    return nil;
}



-(id)object:(NSError **)error
{
    return nil;
}

@end

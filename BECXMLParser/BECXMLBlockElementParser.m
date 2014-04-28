//
//  BECXMLBlockElementParser.m
//  BECXMLParser
//
//  Created by Benedict Cohen on 19/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BECXMLBlockElementParser.h"



@interface BECXMLBlockElementParser () <BECXMLElementParserFactory>
@end



@implementation BECXMLBlockElementParser

-(NSError *)handleCharacters:(NSString *)characters
{
    if (self.handleCharactersBlock == NULL) return nil;
    return self.handleCharactersBlock(characters);
}



-(NSError *)handleCDATA:(NSData *)data
{
    if (self.handleCDATABlock == NULL) return nil;
    return self.handleCDATABlock(data);
}



-(NSError *)handleIgnorableWhitespace:(NSString *)whitespace
{
    if (self.handleIgnorableWhiteSpaceBlock == NULL) return nil;
    return self.handleIgnorableWhiteSpaceBlock(whitespace);
}



-(NSError *)handleComment:(NSString *)comment
{
    if (self.handleCommentBlock == NULL) return nil;
    return self.handleCommentBlock(comment);
}



-(NSError *)addChildObject:(id)childObject forElementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
{
    if (self.addChildObjectBlock == NULL) return nil;

    return self.addChildObjectBlock(childObject, elementName, namespaceURI);
}



-(id)object:(NSError **)error
{
    if (self.objectBlock == NULL) return nil;

    return self.objectBlock(error);
}



-(id<BECXMLElementParserFactory>)elementParserFactory
{
    return (self.elementParserFactoryBlock == NULL) ? nil : self;
}



-(id<BECXMLElementParser>)elementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes error:(NSError **)error
{
    //If don't need the NULL check because it has already been done in -elementParserFactory.
    return self.elementParserFactoryBlock(parentParser, elementName, namespaceURI, attributes, error);
}

@end



@implementation BECXMLElementParser (PreConfiguredParsers)

+(id<BECXMLElementParser>)stringElementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentParser elementName:elementName namespaceURI:namespaceURI attributes:attributes];

    NSMutableString *string = [NSMutableString new];
    parser.handleCharactersBlock = ^NSError *(NSString *characters){
        [string appendString:characters];
        return nil;
    };

    parser.objectBlock = ^id(NSError **error){
        return string;
    };

    return parser;
}



+(id<BECXMLElementParser>)dataElementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentParser elementName:elementName namespaceURI:namespaceURI attributes:attributes];

    NSMutableData *data = [NSMutableData new];
    parser.handleCDATABlock = ^NSError *(NSData *CDATA){
        [data appendData:CDATA];
        return nil;
    };

    parser.objectBlock = ^id(NSError **error){
        return data;
    };

    return parser;
}

@end

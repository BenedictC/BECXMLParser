//
//  BECPListElementParserFactory.m
//  BECXMLParser
//
//  Created by Benedict Cohen on 19/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BECPListElementParserFactory.h"
#import "BECXMLBlockElementParser.h"



@implementation BECPListElementParserFactory

-(id<BECXMLElementParser>)elementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes error:(NSError *__autoreleasing *)outError
{
    if ([elementName isEqual:@"plist"]) return [self plistElementParser];

    if ([elementName isEqual:@"string"]) return [self stringElementParserWithParentElement:parentParser elementName:elementName];

    //numbers
    if ([elementName isEqual:@"real"]) return [self numberElementParserWithParentElement:parentParser elementName:elementName];
    if ([elementName isEqual:@"integer"]) return [self numberElementParserWithParentElement:parentParser elementName:elementName];

    //booleans
    if ([elementName isEqual:@"true"]) return [self trueElementParserWithParentElement:parentParser elementName:elementName];
    if ([elementName isEqual:@"false"]) return [self falseElementParserWithParentElement:parentParser elementName:elementName];

    //date
    if ([elementName isEqual:@"date"]) return [self dateElementParserWithParentElement:parentParser elementName:elementName];

    //data
    if ([elementName isEqual:@"data"]) return [self dataElementParserWithParentElement:parentParser elementName:elementName];

    //array
    if ([elementName isEqual:@"array"]) return [self arrayElementParserWithParentElement:parentParser elementName:elementName];

    //dict
    if ([elementName isEqual:@"dict"]) return [self dictionaryElementParserWithParentElement:parentParser elementName:elementName];

    *outError = [NSError errorWithDomain:@"BECPListElementParserFactoryErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Invalid element name."}];
    return nil;
}



-(id<BECXMLElementParser>)plistElementParser
{
    __block id rootObject = nil;
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:nil elementName:@"plist" namespaceURI:nil attributes:nil];;
    [parser setAddChildObjectBlock:^NSError *(id childObject, NSString *elementName, NSString *namespaceURI) {
        rootObject = childObject;
        return nil;
    }];
    [parser setObjectBlock:^id(NSError *__autoreleasing *error) {
        return rootObject;
    }];

    return parser;
}



-(id<BECXMLElementParser>)stringElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    return [BECXMLBlockElementParser stringElementParserWithParentElementParser:parentElement elementName:nil namespaceURI:nil attributes:nil];
}



-(id<BECXMLElementParser>)numberElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];

    NSMutableString *string = [NSMutableString new];
    parser.handleCharactersBlock = ^NSError *(NSString *characters){
        [string appendString:characters];
        return nil;
    };

    parser.objectBlock = ^id(NSError **error){
        return @([string doubleValue]);
    };

    return parser;
}



-(id<BECXMLElementParser>)trueElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];
    parser.objectBlock = ^id(NSError **error){
        return @YES;
    };
    return parser;
}



-(id<BECXMLElementParser>)falseElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];
    parser.objectBlock = ^id(NSError **error){
        return @NO;
    };
    return parser;
}



-(id<BECXMLElementParser>)dateElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
    });

    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];

    NSMutableString *string = [NSMutableString new];
    parser.handleCharactersBlock = ^NSError *(NSString *characters){
        [string appendString:characters];
        return nil;
    };

    parser.objectBlock = ^id(NSError **error){
        return [formatter dateFromString:string];
    };

    return parser;
}



-(id<BECXMLElementParser>)dataElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];

    NSMutableString *string = [NSMutableString new];
    parser.handleCharactersBlock = ^NSError *(NSString *characters){
        [string appendString:characters];
        return nil;
    };

    parser.objectBlock = ^id(NSError **error){
        return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    };

    return parser;
}



-(id<BECXMLElementParser>)arrayElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [BECXMLBlockElementParser new];
    NSMutableArray *array = [NSMutableArray new];
    [parser setAddChildObjectBlock:^NSError *(id object, NSString *elementName, NSString *namespaceURI) {
        [array addObject:object];
        return nil;
    }];
    parser.objectBlock = ^id(NSError **error){
        return array;
    };
    return parser;
}



-(id<BECXMLElementParser>)dictionaryElementParserWithParentElement:(id<BECXMLElementParser>)parentElement elementName:(NSString *)elementName
{
    BECXMLBlockElementParser *parser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parentElement elementName:elementName namespaceURI:nil attributes:nil];
    //We re-use the key parser.
    BECXMLBlockElementParser *keyParser = [[BECXMLBlockElementParser alloc] initWithParentElementParser:parser elementName:@"key" namespaceURI:nil attributes:nil];
    NSMutableString *key = [NSMutableString new];
    [keyParser setHandleCharactersBlock:^NSError *(NSString *characters) {
        [key appendString:characters];
        return nil;
    }];
    [keyParser setObjectBlock:^id(NSError *__autoreleasing *error) {
        return key;
    }];

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [parser setElementParserFactoryBlock:^id<BECXMLElementParser>(id<BECXMLElementParser>parentParser, NSString *elementName, NSString *namespaceURI, NSDictionary *attributes, NSError **outError){
        //We only supply a parser for the key. Returning nil means that the higher context (i.e. BECPListElementParserFactory) will return the parser.
        return ([elementName isEqual:@"key"]) ? keyParser : nil;
    }];
    [parser setAddChildObjectBlock:^NSError *(id childObject, NSString *elementName, NSString *namespaceURI){
        if ([elementName isEqual:@"key"]) return nil;

        dictionary[key] = childObject;
        key.string = @"";

        return nil;
    }];
    [parser setObjectBlock:^id(NSError *__autoreleasing *error) {
        return dictionary;
    }];

    return parser;
}

@end

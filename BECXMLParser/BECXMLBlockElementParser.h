//
//  BECXMLBlockElementParser.h
//  BECXMLParser
//
//  Created by Benedict Cohen on 19/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BECXMLElementParser.h"



@interface BECXMLBlockElementParser : BECXMLElementParser

@property(nonatomic, copy) NSError *(^handleCharactersBlock)(NSString *characters);
@property(nonatomic, copy) NSError *(^handleCDATABlock)(NSData *data);
@property(nonatomic, copy) NSError *(^handleIgnorableWhiteSpaceBlock)(NSString *whitespace);
@property(nonatomic, copy) NSError *(^handleCommentBlock)(NSString *comment);

@property(nonatomic, copy) NSError *(^addChildObjectBlock)(id childObject, NSString *elementName, NSString *namespaceURI);
@property(nonatomic, copy) id(^objectBlock)(NSError **outError);

@property(nonatomic, copy) id<BECXMLElementParser>(^elementParserFactoryBlock)(id<BECXMLElementParser>parentParser, NSString *elementName, NSString *namespaceURI, NSDictionary *attributes, NSError **outError);

@end



@interface BECXMLElementParser (PreConfiguredParsers)
+(id<BECXMLElementParser>)stringElementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes;
+(id<BECXMLElementParser>)dataElementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes;
@end

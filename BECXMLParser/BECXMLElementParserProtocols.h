//
//  BECXMLElementParserProtocols.h
//  BECXMLParser
//
//  Created by Benedict Cohen on 16/04/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol BECXMLElementParserFactory;
@protocol BECXMLElementParser <NSObject>

//Properties
-(id<BECXMLElementParser>)parentElementParser;
-(NSString *)elementName;
-(NSString *)namespaceURI;
-(NSDictionary *)attributes;
//
//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
//// sent when the parser finds an element start tag.
//// In the case of the cvslog tag, the following is what the delegate receives:
////   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
//// In the case of the radar tag, the following is what's passed in:
////    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
//// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
//// sent when an end tag is encountered. The various parameters are supplied as above.



//Receiving parser data
-(NSError *)handleCharacters:(NSString *)characters; // This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
-(NSError *)handleCDATA:(NSData *)data; // this reports a CDATA block to the delegate as an NSData.
-(NSError *)handleIgnorableWhitespace:(NSString *)whitespace; // The parser reports ignorable whitespace in the same way as characters it's found.
-(NSError *)handleComment:(NSString *)comment; // A comment (Text in a <!-- --> block) is reported to the delegate as a single string

//TODO:
//- (void)handleNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
//- (void)handleUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;
//- (void)handleAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;
//- (void)handleElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;
//- (void)handleInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;
//- (void)handleExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
//- (void)handleProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data; // The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
//
//- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;
//// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
//- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;
//// sent when the parser first sees a namespace attribute.
//// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
//// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"
//- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;
//// sent when the namespace prefix in question goes out of scope.



//Fetching and passing the parsed object
-(NSError *)addChildObject:(id)object forElementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI;
-(id)object:(NSError **)error;

@optional //Should this be optional? In must cases we want it to return nil.
-(id<BECXMLElementParserFactory>)elementParserFactory;

@end



@protocol BECXMLElementParserFactory <NSObject>
-(id<BECXMLElementParser>)elementParserWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes error:(NSError **)outError;
@end

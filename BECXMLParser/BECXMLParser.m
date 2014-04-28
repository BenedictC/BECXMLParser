//
//  BECXMLParser.m
//  BECXMLParser
//
//  Created by Benedict Cohen on 07/03/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "BECXMLParser.h"



@interface BECXMLParser () <NSXMLParserDelegate>
//We could get rid of the stack and keep a reference to the top parser and a count.
@property(nonatomic, readonly) NSMutableArray *elementParserStack;

@property(nonatomic, readonly) CFMutableBitVectorRef elementParserStackIndexToFactoryStackMapping;
@property(nonatomic, readonly) NSMutableArray *factoryStack;

@property(nonatomic, readonly) NSXMLParser *parser;
@property(nonatomic) id rootObject;
@property(nonatomic) NSError *error;
@end



@implementation BECXMLParser

#pragma mark - Instance life cycle
-(instancetype)initWithInputStream:(NSInputStream *)inputStream rootElementParserFactory:(id<BECXMLElementParserFactory>)elementParserFactory
{
    NSParameterAssert(inputStream);
    NSParameterAssert(elementParserFactory);

    self = [super init];
    if (self == nil) return nil;

    //Store public properties
    _inputStream = inputStream;
    _rootElementParserFactory = elementParserFactory;

    //create stacks
    _factoryStack = [NSMutableArray arrayWithObject:elementParserFactory];
    _elementParserStackIndexToFactoryStackMapping = CFBitVectorCreateMutable(NULL, 0);
    _elementParserStack = [NSMutableArray new];

    //create parser
    _parser = [[NSXMLParser alloc] initWithStream:self.inputStream];
    _parser.delegate = self;

    return self;
}



-(void)dealloc
{
    CFRelease(_elementParserStackIndexToFactoryStackMapping);
}



#pragma mark - element stack
-(void)pushElementParser:(id<BECXMLElementParser>)elementParser
{
    //Push the element parser
    [self.elementParserStack addObject:elementParser];

    //Attempt to push a factory too
    id factory = ([elementParser respondsToSelector:@selector(elementParserFactory)]) ? [elementParser elementParserFactory] : nil;
    BOOL shouldPushFactory = factory != nil;
    if (shouldPushFactory) {
        [self.factoryStack addObject:factory];
        CFIndex idx = self.elementParserStack.count - 1;
        CFBitVectorSetBitAtIndex(self.elementParserStackIndexToFactoryStackMapping, idx, 1);
    }
}



-(id<BECXMLElementParser>)popElementParser
{
    id<BECXMLElementParser> elementParser = [self.elementParserStack lastObject];
    //Remove the element parser
    [self.elementParserStack removeLastObject];

    //Remove the factory associated with the parser
    BOOL shouldPopFactory = CFBitVectorGetBitAtIndex(self.elementParserStackIndexToFactoryStackMapping, self.elementParserStack.count);
    if (shouldPopFactory) {
        [self.factoryStack removeLastObject];
        CFIndex idx = self.elementParserStack.count;
        CFBitVectorSetBitAtIndex(self.elementParserStackIndexToFactoryStackMapping, idx, 0);
    }

    return elementParser;
}



-(id<BECXMLElementParser>)topElementParser
{
    return [self.elementParserStack lastObject];
}



#pragma mark - Parsing
-(void)parse:(void(^)(BOOL didSucceed, id object, NSError *error))completionHandler
{
    BOOL didFinishParsing = [self.parser parse];
    NSError *rootObject = self.rootObject;
    NSError *error = self.error;
    BOOL didSucceed = didFinishParsing && rootObject != nil && error == nil;

    if (completionHandler != NULL) completionHandler(didSucceed, rootObject, error);
}



-(void)abortParsing
{
    [self.parser abortParsing];
}



#pragma mark - NSXMLParserDelegate
#pragma mark element stack
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // sent when the parser begins parsing of the document.
}



- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // sent when the parser has completed parsing. If this is encountered, the parse was successful.
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // sent when the parser finds an element start tag.
    // In the case of the cvslog tag, the following is what the delegate receives:
    //   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
    // In the case of the radar tag, the following is what's passed in:
    //    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
    // If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

    //Walk the factory stack until we have a elementParser or an error.
    id<BECXMLElementParser> elementParser = nil;
    id<BECXMLElementParser> parentElementParser = [self topElementParser];
    for (id<BECXMLElementParserFactory> factory in [self.factoryStack reverseObjectEnumerator]) {
        NSError *error = nil;
        elementParser = [factory elementParserWithParentElementParser:parentElementParser elementName:elementName namespaceURI:namespaceURI attributes:attributeDict error:&error];
        if (elementParser != nil) break; //Done!
        if (error != nil) {
            //TODO: Abort parsing and report the error.
        }
    }

    NSAssert(elementParser != nil, @"Failed to create element parser for element '%@;", elementName); //Failure to create an elementParser without reporting an error is programmer error.
    [self pushElementParser:elementParser];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    id<BECXMLElementParser> childElementParser = [self popElementParser];

    //Get the object
    NSError *error = nil;
    id object = [childElementParser object:&error];
    if (object == nil) {
        //TODO: Handle error. Is child == nil a programmer error and thus exception?
        return;
    }

    id<BECXMLElementParser> parentElementParser = self.topElementParser;
    //Have we finished parsing?
    BOOL isRootObject = parentElementParser == nil;
    if (isRootObject) {
        self.rootObject = object;
        return;
    }

    //Pass the object to the parent parser
    error = [parentElementParser addChildObject:object forElementName:elementName namespaceURI:namespaceURI];
    if (error != nil) {
        //TODO: Handle error.
    }
}



#pragma mark data handling (pass data onto self.topElementParser)
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)characters
{
    //TODO: Handle error
    [self.topElementParser handleCharacters:characters];
}



-(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    //TODO: Handle error
    [self.topElementParser handleCDATA:CDATABlock];
}



-(void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    //TODO: Handle error
    [self.topElementParser handleIgnorableWhitespace:whitespaceString];
}



-(void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    //TODO: Handle error
    [self.topElementParser handleComment:comment];
}



#pragma mark error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // ...and this reports a fatal error to the delegate. The parser will stop parsing.
}



-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{

}



#pragma mark TODO:
- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
    // this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
    return nil;
}



-(void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
    // The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
}



// DTD handling methods for various declarations.
-(void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
{

}



-(void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{

}



-(void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{

}



-(void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{

}



-(void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{

}



-(void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{

}



-(void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    // sent when the parser first sees a namespace attribute.
    // In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
    // In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"
}



-(void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    // sent when the namespace prefix in question goes out of scope.
}

@end

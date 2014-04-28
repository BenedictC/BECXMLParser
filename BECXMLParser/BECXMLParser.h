//
//  BECXMLParser.h
//  BECXMLParser
//
//  Created by Benedict Cohen on 07/03/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BECXMLElementParserProtocols.h"



@interface BECXMLParser : NSObject

-(instancetype)initWithInputStream:(NSInputStream *)inputStream rootElementParserFactory:(id<BECXMLElementParserFactory>)elementParserFactory;
@property(nonatomic, readonly) NSInputStream *inputStream;
@property(nonatomic, readonly) id<BECXMLElementParserFactory> rootElementParserFactory;



-(void)parse:(void(^)(BOOL didSucceed, id object, NSError *error))completionHandler;
-(void)abortParsing;
@property(nonatomic, readonly) id<BECXMLElementParser> topElementParser;

@end

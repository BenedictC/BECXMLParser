//
//  BECXMLElementParser.h
//  BECXMLParser
//
//  Created by Benedict Cohen on 08/03/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BECXMLElementParserProtocols.h"



@interface BECXMLElementParser : NSObject <BECXMLElementParser>
-(instancetype)initWithParentElementParser:(id<BECXMLElementParser>)parentParser elementName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes;

@property(nonatomic, readonly) id<BECXMLElementParser> parentElementParser;
@property(nonatomic, readonly) NSString *elementName;
@property(nonatomic, readonly) NSString *namespaceURI;
@property(nonatomic, readonly) NSDictionary *attributes;

@end

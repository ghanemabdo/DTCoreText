//
//  JavascriptContent.h
//  DTCoreText
//
//  Created by Abdurrahman Ibrahem Ghanem on 1/23/14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptContent : NSObject
{
	
@private
	NSString * _script ;
	NSString * _scriptType ;
	NSString * _sourceFilePath ;
}

@property (nonatomic , strong , readwrite) NSString * script ;
@property (nonatomic , strong , readwrite) NSString * scriptType ;
@property (nonatomic , strong , readwrite) NSString * sourceFilePath ;

-(id) initWithScript:(NSString*)script scriptType:(NSString*)scriptType ;

@end

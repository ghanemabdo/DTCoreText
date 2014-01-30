//
//  JavascriptContent.m
//  DTCoreText
//
//  Created by Abdurrahman Ibrahem Ghanem on 1/23/14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "ScriptContent.h"

@implementation ScriptContent

@synthesize script = _script ;
@synthesize scriptType = _scriptType ;
@synthesize sourceFilePath = _sourceFilePath ;

-(id) initWithScript:(NSString*)script scriptType:(NSString*)scriptType
{
	if ( self = [super init] )
	{
		_script = script ;
		_scriptType = scriptType ;
	}
	
	return self ;
}

@end

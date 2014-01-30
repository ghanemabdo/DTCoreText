//
//  DTTextAttachmentInteractiveContent.m
//  DTCoreText
//
//  Created by Abdurrahman Ghanem on 22.01.14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "DTCoreText.h"

#define SEPARATOR @"--|--"

static NSMutableDictionary * _scriptFiles = nil ;

@implementation DTScriptTextAttachment

@synthesize scriptContent = _scriptContent ;

- (id)initWithElement:(DTHTMLElement *)element options:(NSDictionary *)options
{
	self = [super initWithElement:element options:options];
	
	if (self)
	{
		if ( _scriptFiles == nil )
			_scriptFiles = [[NSMutableDictionary alloc] initWithCapacity:10] ;
		
		[self setContentWithElement:element options:options] ;
	}
	
	return self;
}

-(void) setContentWithElement:(DTHTMLElement *)element options:(NSDictionary *)options
{
	// get base URL
	NSURL *baseURL = [options objectForKey:NSBaseURLDocumentOption];
	NSString *src = [element.attributes objectForKey:@"src"];
	
	NSString * key = nil ;
	
	// Load script from source file
	if ( src )
	{
		_scriptContent = [[ScriptContent alloc] init] ;
		
		// get script type
		_scriptContent.scriptType = [element.attributes objectForKey:@"type"] ;
		
		_contentURL = [NSURL URLWithString:src relativeToURL:baseURL];
		
		// check if the same file is already loaded, no need to reload it, read loaded data from the stored object
		key = _contentURL.absoluteString ;
		
		DTScriptTextAttachment* obj = [_scriptFiles objectForKey:key] ;
		if ( obj )
		{
			self.scriptContent.script = obj.scriptContent.script ;
			if ( obj.scriptContent.scriptType && self.scriptContent.scriptType == nil )
				self.scriptContent.scriptType = obj.scriptContent.scriptType ;
		}
		else
		{
			// load the content of the javascript file
			[self loadFile] ;
		}
		
		[_scriptFiles setObject:self forKey:key] ;
	}
	//		else
	//		{
	//			// script is within an html file. So, combine all scripts of the same type in an html file in one script store.
	//			NSString * key = [baseURL.absoluteString stringByAppendingFormat:@"%@%@", SEPARATOR ,_scriptContent.scriptType] ;
	//			DTScriptTextAttachment* obj = [_scriptFiles objectForKey:key] ;
	//			if ( obj )
	//			{
	//				_scriptContent.script = [NSString stringWithFormat:@"%@ \n\n %@", obj.scriptContent.script , element.text] ;
	//			}
	//			else
	//			{
	//				// load the script from the script element
	////				NSAttributedString * content = element.ch ;
	//				_scriptContent.script = nil ;
	//				_scriptContent.sourceFilePath = baseURL.path ;
	//			}
	//
	//			_scriptContent.sourceFilePath = baseURL.path ;
	//		}
	
	//		[_scriptFiles setObject:self forKey:key] ;
}

+(NSMutableDictionary*) javascriptFiles
{
	return _scriptFiles ;
}

+(NSArray*) getScriptsForFile:(NSString*)filePath
{
	NSMutableArray * scripts = [NSMutableArray arrayWithCapacity:10] ;
	
	for ( NSString * key in [_scriptFiles allKeys] )
	{
		NSArray *components = [key componentsSeparatedByString:SEPARATOR] ;
		NSString * path = [components objectAtIndex:0] ;
		
		if ( [path isEqualToString:filePath] )
			[scripts addObject:[_scriptFiles objectForKey:path]] ;
	}
	
	return [NSArray arrayWithArray:scripts] ;
}

+(void)cleanAllScripts
{
	[_scriptFiles removeAllObjects] ;
}

-(void) setContentURL:(NSURL *)contentURL
{
	[super setContentURL:contentURL] ;
	
	[self loadFile] ;
}

-(void) loadFile
{
	if ( _contentURL )
	{
		if ( [[NSFileManager defaultManager] fileExistsAtPath:_contentURL.path] )
		{
			NSData * jsFileContent = [NSData dataWithContentsOfFile:_contentURL.path] ;
			_scriptContent.script = [[NSString alloc] initWithData:jsFileContent encoding:NSUTF8StringEncoding] ;
			_scriptContent.sourceFilePath = _contentURL.absoluteString ;
		}
	}
}

#pragma mark - DTTextAttachmentHTMLEncoding

- (NSString *)stringByEncodingAsHTML
{
	if ( _scriptContent.script )
	{
		NSMutableString *retString = [NSMutableString string];
		
		if ( _scriptContent.scriptType )
			[retString appendFormat:@"<script type=\"%@\">\n", _scriptContent.scriptType ];
		else
			[retString appendString:@"<script\">\n"];
		
		[retString appendString:_scriptContent.script] ;
		
		[retString appendString:@"\n</script>"];
		
		return retString;
	}
	
	return nil ;
}

@end

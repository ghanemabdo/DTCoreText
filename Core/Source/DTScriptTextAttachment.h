//
//  DTTextAttachmentJSFile.h
//  DTCoreText
//
//  Created by Abdurrahman Ghanem on 22.01.14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "DTTextAttachment.h"
#import "ScriptContent.h"

/**
 A specialized subclass in the DTTextAttachment class cluster to load a script content
 */

@interface DTScriptTextAttachment : DTTextAttachment <DTTextAttachmentHTMLPersistence>
{
	
@private
	ScriptContent * _scriptContent ;
}

@property ( nonatomic , strong , readwrite ) ScriptContent * scriptContent ;

+(NSMutableDictionary*) javascriptFiles ;
+(NSArray*) getScriptsForFile:(NSString*)filePath ;
+(void)cleanAllScripts ;

@end

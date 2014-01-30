//
//  DTTextAttachmentInteractiveContent.h
//  DTCoreText
//
//  Created by Abdurrahman Ghanem on 22.01.14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "DTTextAttachment.h"

/**
 A specialized subclass in the DTTextAttachment class cluster to represent an embedded canvas with interactive content
 */

@interface DTInteractiveContentTextAttachment : DTTextAttachment <DTTextAttachmentHTMLPersistence , UIWebViewDelegate>
{
	NSString * _interactiveContentHTMLString ;
}

@property ( nonatomic , readonly ) NSString * interactiveContentHTMLString ;

-(void)createInteractiveContentMergedFile ;
-(NSString*)interactiveContentMergedFileAlreadyCreated ;
-(UIWebView*)getAsWebView ;

+(void)cleanHTMLStrings ;

@end
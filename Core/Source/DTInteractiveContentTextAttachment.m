//
//  DTTextAttachmentInteractiveContent.m
//  DTCoreText
//
//  Created by Abdurrahman Ghanem on 22.01.14.
//  Copyright (c) 2014 Drobnik.com. All rights reserved.
//

#import "DTCoreText.h"

static NSMutableDictionary * _interactiveContentHTMLStrings = nil ;

@implementation DTInteractiveContentTextAttachment

@synthesize interactiveContentHTMLString = _interactiveContentHTMLString ;

- (id)initWithElement:(DTHTMLElement *)element options:(NSDictionary *)options
{
	self = [super initWithElement:element options:options];
	
	if (self)
	{
		// get base URL
		_contentURL = [options objectForKey:NSBaseURLDocumentOption];
		
		if ( !_interactiveContentHTMLStrings )
			_interactiveContentHTMLStrings = [[NSMutableDictionary alloc] initWithCapacity:10] ;
	}
	
	return self;
}

-(void)createInteractiveContentMergedFile
{
	NSString * mergedFilePath = [self interactiveContentMergedFileAlreadyCreated] ;
	
	if ( mergedFilePath )
	{
		_interactiveContentHTMLString = [_interactiveContentHTMLStrings objectForKey:mergedFilePath] ;
		
		if ( !_interactiveContentHTMLString )
		{
			_interactiveContentHTMLString = [[NSString alloc] initWithContentsOfFile:mergedFilePath encoding:NSUTF8StringEncoding error:nil] ;
			[_interactiveContentHTMLStrings setObject:_interactiveContentHTMLString forKey:mergedFilePath] ;
		}
		
		return ;
	}
	
	// Now, the html file with all the external scripts embedded inside does not exist, time to create it.
	// Firstly, load the whole file
	NSString *htmlString = [NSString stringWithContentsOfFile:_contentURL.path encoding:NSUTF8StringEncoding error:nil] ;
	NSMutableString *mergedHtmlString = [[NSMutableString alloc] init] ;
	
	NSRange openTagRange = [htmlString rangeOfString:@"<script"] ;
	NSRange closeTagRange = [htmlString rangeOfString:@"</script>"] ;
	
	while ( openTagRange.location != NSNotFound )
	{
		//copy the text before the next script tag
		NSRange prefixRange = NSMakeRange(0 , openTagRange.location - 1);
		[mergedHtmlString appendString:[htmlString substringWithRange:prefixRange]] ;
		
		//extract the script tag content
		NSString * tagContent = [htmlString substringWithRange:NSMakeRange(openTagRange.location , closeTagRange.location + closeTagRange.length - openTagRange.location)] ;
		NSRange typeRange = [tagContent rangeOfString:@"type="] ;
		
		//if the script type exist which means the script is embedded inside the html page not in an external js file
		if ( typeRange.location != NSNotFound )
		{
			[mergedHtmlString appendString:tagContent] ;
		}
		else // script inside an external file
		{
			[self replaceScriptTagForString:mergedHtmlString tagContent:tagContent] ;
		}
		
		int endPoint  = closeTagRange.location + closeTagRange.length ;
		
		// remove the copied segment of the html stringa and adjust ranges.
		htmlString = [htmlString substringWithRange:NSMakeRange( endPoint , htmlString.length - endPoint)] ;
		
		openTagRange = [htmlString rangeOfString:@"<script"] ;
		closeTagRange = [htmlString rangeOfString:@"</script>"] ;
	}
	
	[mergedHtmlString appendString:htmlString] ;
	
	mergedFilePath = [self interactiveContentMergedFilePath] ;
	[mergedHtmlString writeToFile:mergedFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
	_interactiveContentHTMLString = [mergedHtmlString  copy] ;
}

-(void)replaceScriptTagForString:(NSMutableString*)mergedHtmlString tagContent:(NSString*)tagContent
{
	NSRange srcRange = [tagContent rangeOfString:@"src=\""] ;
	int endPoint  = srcRange.location + srcRange.length ;
	NSString * remainingTagContent = [tagContent substringWithRange:NSMakeRange( endPoint , tagContent.length - endPoint)] ;
	NSRange srcEnd = [remainingTagContent rangeOfString:@"\""] ;
	NSString * srcPath = [remainingTagContent substringToIndex:srcEnd.location] ;
	
	NSURL * contentURL = [NSURL URLWithString:srcPath relativeToURL:_contentURL];
	DTScriptTextAttachment * scriptAttachment = [[DTScriptTextAttachment javascriptFiles] objectForKey:contentURL.absoluteString] ;
	[mergedHtmlString appendFormat:@"\n\n<script type=\"text/javascript\"> \n%@\n </script>\n\n", scriptAttachment.scriptContent.script] ;
}

-(NSString*)interactiveContentMergedFilePath
{
	NSString * extension = [_contentURL.path pathExtension] ;
	NSString * icOriginalFile = [[_contentURL.path stringByDeletingPathExtension] mutableCopy] ;
	NSString * mergedFile = [icOriginalFile stringByAppendingFormat:@"-Merged.%@", extension] ;
	
	return mergedFile ;
}

-(NSString*)interactiveContentMergedFileAlreadyCreated
{
	NSString * mergedFilePath = _contentURL.path ; //[self interactiveContentMergedFilePath] ;
	
	if ( [[NSFileManager defaultManager] fileExistsAtPath:mergedFilePath] )
		return mergedFilePath ;
	
	return nil ;
}

-(UIWebView*)getAsWebView
{
	UIWebView * webView = [[UIWebView alloc] init] ;
	
	[webView loadHTMLString:_interactiveContentHTMLString baseURL:_contentURL] ;
	webView.delegate = self ;
	webView.scrollView.scrollEnabled = NO ;
	webView.scrollView.bouncesZoom = NO ;
	webView.scrollView.bounces = NO ;
	
	return webView ;
}

+(void)cleanHTMLStrings
{
	[_interactiveContentHTMLStrings removeAllObjects] ;
}

#pragma mark - DTTextAttachmentHTMLEncoding

- (NSString *)stringByEncodingAsHTML
{
	return _interactiveContentHTMLString;
}

#pragma mark UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSString * js = @"\
					var canvasElements = document.getElementsByTagName('canvas') ;\
					var canvasWidth = 0 ;\
					for ( var i = 0 ; i < canvasElements.length ; i++ )\
					{\
						var canvas = canvasElements[i];\
						var width = parseFloat( canvas.getAttribute('width') ) ;\
						if ( width > canvasWidth ) \
							canvasWidth = width ;\
					}\
					\
					canvasWidth ;" ;
	CGFloat contentWidth = [[webView stringByEvaluatingJavaScriptFromString: js] floatValue] ;
	
	
	js = [NSString stringWithFormat:
					@"var meta = document.createElement('meta'); "
					"meta.setAttribute( 'name', 'viewport' ); "
					"meta.setAttribute( 'content', 'width=device-width; initial-scale=%f;user-scalable=0;' ); "
					"document.getElementsByTagName('head')[0].appendChild(meta)", (webView.frame.size.width / contentWidth)];
	
	[webView stringByEvaluatingJavaScriptFromString: js];
}

@end

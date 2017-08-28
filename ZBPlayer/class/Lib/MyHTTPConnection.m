
#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"
#import "SVProgressHUD.h"
// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/upload.html"])
		{
			return YES;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }

		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"])
	{

		// this method will generate response with links to uploaded file
		NSMutableString* filesStr = [[NSMutableString alloc] init];

		for( NSString* filePath in uploadedFiles ) {
			//generate links
			[filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
		}
		NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"upload.html"];
		NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
		// use dynamic file response to apply our links to response template
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
	}
	if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
		// let download the uploaded files
		return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;

	uploadedFiles = [[NSMutableArray alloc] init];
    
    
    NSLog(@"-------prepareForBodyWithSize:(UInt64)contentLength--------");
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
      NSLog(@"-------processBodyData:(NSData *)postDataChunk--------");
//    NSLog(@"-------完成--------");
    
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename

    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];

    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}    
//	NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];

//	BOOL isDir = YES;
//	if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
//		[[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
//	}
	
    
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
    }
    else {
		HTTPLogVerbose(@"Saving file to %@", filePath);
		if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
			HTTPLogError(@"Could not create directory at path: %@", filePath);
		}
		if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
			HTTPLogError(@"Could not create file at path: %@", filePath);
		}
		storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
		[uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header 
{
	// here we just write the output from parser to the file.
	if( storeFile ) {
		[storeFile writeData:data];
        
        
     
        
        NSLog(@"?????????------%lu",(unsigned long)data.length/1024/1024);
        
        NSLog(@"-------processContent:(NSData*) data WithHeader--------");
    }else{
        
        NSLog(@"-------1111111111111--------");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [SVProgressHUD showSuccessWithStatus:@"下载完成"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ok" object:nil];
        });
        
    }
    
    NSLog(@"-------22222--------");
  
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    
    // attributesOfItemAtPath:只能获取文件尺寸,获取文件夹不对,
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    // 获取文件尺寸
    NSInteger fileSize = [attr fileSize];
    
    
    NSString *contentLength = [[NSUserDefaults standardUserDefaults] objectForKey:@"contentLength"];
    
    NSInteger  tatal = contentLength.integerValue;
//    NSLog(@"%ld",(long)contentLength.integerValue);
    
    
    
//    double cur =  [fileSize double]
    
    NSLog(@"-------fileSize--------%.2f%%",(double)fileSize/(double)tatal*100);
    
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
	// as the file part is over, we close the file.
	[storeFile closeFile];
	storeFile = nil;
     NSLog(@"-------processEndOfPartWithHeader--------");
}

- (void) processPreambleData:(NSData*) data 
{
    // if we are interested in preamble data, we could process it here.
      NSLog(@"-------processPreambleData--------");
}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.
    NSLog(@"-------processEpilogueData--------");

}

@end

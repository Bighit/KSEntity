//
//  KSUrlConnection.m
//  KSEntity
//
//  Created by Hantianyu on 15/7/21.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import "KSConnectionOperation.h"
#import "KSRequestManager.h"
#import <UIKit/UIKit.h>
@interface KSConnectionOperation ()
{
    CFRunLoopRef _currentRunLoop;
}
@end
@implementation KSConnectionOperation
@synthesize expectedDataLength = _expectedDataLength;
@synthesize fileSavePath = _fileSavePath;
@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;
#pragma mark -
#pragma mark implements operation

- (void)main
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    if (_useAsyncRequestMethod) {
        [self sendAsynchronousRequest];
    } else {
        [self sendSynchronousRequest];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)finish
{
    if (_isFinished || !_isExecuting) {
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    _isExecuting = NO;
    _isFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

    if (CFRunLoopIsWaiting(_currentRunLoop)) {
        CFRunLoopStop(_currentRunLoop);
    }
}

- (void)cancel
{
    [super cancel];
    [self cancel:YES];
}

- (void)cancel:(BOOL)force
{
    if (_useAsyncRequestMethod && _urlConnection) {
        [_urlConnection cancel];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        // [self resetReceivedData];
        if ((_tryCounter == _tryCount) || force) {
            [self finish];
        }
    }
}

- (void)reset
{
    if (_isSupportBreakPointContinueTransfer && _tempFileHandle) {
        [_tempFileHandle closeFile];
        _tempFileHandle = nil;
    }

    [self resetReceivedData];
    [self cancel:NO];

    if (_urlConnection) {
        _urlConnection = nil;
    }
}

- (void)resetReceivedData
{
    if (_receivedData) {
        _receivedData = nil;
    }

    _currentDataLength = 0;
    _expectedDataLength = 0;
}

#pragma mark -
#pragma mark public methods

- (id)initWithUrl:(NSString *)urlString
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _fileSavePath = nil;
    _tempFile = nil;
    _tempConfigureFile = nil;
    _tryCount = 0;
    _tryCounter = 0;

    _tag = nil;
    _timeout = 10;
    _currentDataLength = 0;
    _useAsyncRequestMethod = NO;
    _isSupportBreakPointContinueTransfer = NO;
    _isUsePostTimer = NO;
    _requestUrlString = urlString;

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    _urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [_urlRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];

    return self;
}

- (void)sendAsynchronousRequest
{
    [_urlRequest setTimeoutInterval:self.timeout];

    [self configHttpHeader];
    [self configRequestParams];

    _useAsyncRequestMethod = YES;
    _currentRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];

    NSCachedURLResponse *cacheResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:_urlRequest];

    if (cacheResponse.data&&[KSRequestManager manager].userCache) {
        if (self.networkingCompleteBlock) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.networkingCompleteBlock(YES, cacheResponse.data, nil);
        }

        [self finish];
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self reset];

    if (_isSupportBreakPointContinueTransfer) {
        if (![self setParsForBreakPointContinueTransfer]) {
            [self finish];
            return;
        }
    }

    _urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self startImmediately:NO];
    [_urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_urlConnection start];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
    } else {
        CFRunLoopRun();
    }

    if (_isUsePostTimer && [[_urlRequest.HTTPMethod uppercaseString] isEqualToString:@"POST"]) {
        if (_postTimer) {
            [_postTimer invalidate];
            _postTimer = nil;
        }

        _postTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(postTimeOut:) userInfo:nil repeats:NO];
    }
}

- (NSData *)sendSynchronousRequest
{
    _useAsyncRequestMethod = NO;
    [_urlRequest setTimeoutInterval:self.timeout];
    [self configHttpHeader];
    [self configRequestParams];
    NSError *error = nil;
    NSData  *result = [NSURLConnection sendSynchronousRequest:_urlRequest returningResponse:nil error:&error];

    if (error) {
        result = nil;

        if (_tryCounter < _tryCount) {
            _tryCounter++;
            [self sendSynchronousRequest];
        } else {
            _tryCounter = 0;
        }
    }

    return result;
}

- (void)postTimeOut:(NSTimer *)timer
{
    if (_postTimer) {
        [_postTimer invalidate];
        _postTimer = nil;
    }

    [self reset];

    if (_tryCounter < _tryCount) {
        _tryCounter++;

        sleep(1);
        [self sendAsynchronousRequest];
    } else {
        if (self.networkingCompleteBlock) {
            NSError *error = [NSError errorWithDomain:@"JSONModelErrorDomain"
                code    :408
                userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
            self.networkingCompleteBlock(NO, nil, error);
        }

        if (_removeTempFileWhenRequestFailed) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempFile error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:_tempConfigureFile error:nil];
        }

        _tryCounter = 0;
        [self finish];
    }
}

#pragma mark - setter & getter
- (void)setSupportBreakPointContinueTransfer:(BOOL)isSupport
{
    _isSupportBreakPointContinueTransfer = isSupport;
}

- (void)setTryCount:(NSUInteger)count
{
    _tryCount = count - 1;
}

- (void)setFileSavePath:(NSString *)path
{
    if (_fileSavePath && ([_fileSavePath compare:path] == NSOrderedSame)) {
        return;
    }

    if (_fileSavePath) {
        _fileSavePath = nil;
        _tempFile = nil;
        _tempConfigureFile = nil;
    }

    if (path) {
        _fileSavePath = [path copy];
        _tempFile = [[_fileSavePath stringByAppendingString:@".kstmp"] copy];
        _tempConfigureFile = [[_fileSavePath stringByAppendingString:@".kscfg"] copy];
    }
}

- (NSString *)fileSavePath
{
    if (((_fileSavePath == nil) || ([_fileSavePath compare:@""] == NSOrderedSame))
        && _requestUrlString && ([_requestUrlString compare:@""] != NSOrderedSame)) {
        [self setFileSavePath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
        stringByAppendingPathComponent:[_requestUrlString lastPathComponent]]];
    }

    return _fileSavePath;
}

- (NSNumber *)expectedDataLength
{
    return _expectedDataLength;
}

- (BOOL)isFileDownloadFinished
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fileSavePath]];
}

#pragma mark -
#pragma mark private methods
- (void)setHTTPMethod:(NSString *)string
{
    [_urlRequest setHTTPMethod:string];
}

- (BOOL)setParsForBreakPointContinueTransfer
{
    if (_urlRequest == nil) {
        return NO;
    }

    // 如果文件已经存在，则提示已经下载完毕
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self fileSavePath]]) {
        [self connectionDidFinishLoading:_urlConnection];
        return NO;
    }

    // 如果临时文件不存在，则创建临时文件，并打开一个写文件的句柄
    if ([[NSFileManager defaultManager] fileExistsAtPath:_tempFile] == NO) {
        if ([[NSFileManager defaultManager] createFileAtPath:_tempFile contents:[NSData data] attributes:nil]) {
            _tempFileHandle = [NSFileHandle fileHandleForWritingAtPath:_tempFile];
            // 将下载信息保存到配置文件

            NSString *paramsString = @"";

            if (self.requestParams) {
                paramsString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:self.requestParams options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }

            [[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@%@", _requestUrlString, paramsString], @"request_url",
            _fileSavePath, @"save_path",
            [[NSDate date] copy], @"create_time", nil]
            writeToFile:_tempConfigureFile atomically:NO];
        } else {
            return NO;
        }

        _currentDataLength = 0;
    }
    // 如果临时文件存在，说明文件还未下载完毕，打开一个写文件的句柄， 并设置断点续传参数
    else {
        _tempFileHandle = [NSFileHandle fileHandleForWritingAtPath:_tempFile];
        _currentDataLength = [_tempFileHandle seekToEndOfFile];

        if (_currentDataLength > 0) {
            [_urlRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", _currentDataLength] forHTTPHeaderField:@"RANGE"];
        }
    }

    return YES;
}

- (void)configHttpHeader
{
    if (self.requestHeaders) {
        for (NSString *key in [self.requestHeaders allKeys]) {
            [_urlRequest setValue:self.requestHeaders[key] forHTTPHeaderField:key];
        }
    }
}

- (void)configRequestParams
{
    NSMutableString *paramsString = [NSMutableString stringWithString:@""];

    if (self.requestParams) {
        // build a simple url encoded param string

        for (NSString *key in [[self.requestParams allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            [paramsString appendFormat:@"%@=%@&", key, [KSConnectionOperation urlEncode:self.requestParams[key]]];
        }

        if ([paramsString hasSuffix:@"&"]) {
            paramsString = [[NSMutableString alloc] initWithString:[paramsString substringToIndex:paramsString.length - 1]];
        }
    }

    // set the request params
    if ([[_urlRequest.HTTPMethod uppercaseString] isEqualToString:@"GET"] && self.requestParams) {
        // add GET params to the query string
        NSURL *url = _urlRequest.URL;

        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",
            [url absoluteString],
            [url query] ? @"&" : @"?",
            paramsString
            ]];
        _urlRequest.URL = url;
    } else if ([[_urlRequest.HTTPMethod uppercaseString] isEqualToString:@"POST"] && self.requestParams) {
        NSData *data = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
        [_urlRequest setHTTPBody:data];
    }
}

+ (NSString *)urlEncode:(id <NSObject>)value
{
    // make sure param is a string
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)value stringValue];
    }

    NSAssert([value isKindOfClass:[NSString class]], @"request parameters can be only of NSString or NSNumber classes. '%@' is of class %@.", value, [value class]);

    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                   NULL,
                   (__bridge CFStringRef)value,
                   NULL,
                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                   kCFStringEncodingUTF8));
}

#pragma mark -
#pragma mark implements nsurlconnectiondelegate protocol

- (NSCachedURLResponse *)   connection          :(NSURLConnection *)connection
                            willCacheResponse   :(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (_postTimer) {
        [_postTimer invalidate];
        _postTimer = nil;
    }

    if (_urlResponse) {
        _urlResponse = nil;
    }

    _urlResponse = [response copy];

    long long len = [response expectedContentLength];

    if (NSURLResponseUnknownLength == len) {
        _expectedDataLength = [NSNumber numberWithLongLong:(long long)MAXFLOAT];
    } else {
        _expectedDataLength = [NSNumber numberWithLongLong:len];
    }

    len = _expectedDataLength.longLongValue + _currentDataLength;
    NSHTTPURLResponse   *httpResponse = (NSHTTPURLResponse *)response;
    NSUInteger          statusCode = [httpResponse statusCode];

    //	if(_delegate && [(NSObject *)_delegate respondsToSelector:@selector(connection:didReceiveResponse:withExpectedDataLength:)]) {
    //		[_delegate connection:self didReceiveResponse:response withExpectedDataLength:[NSNumber numberWithLongLong:len]];
    //	}

    if (!((statusCode == 200) || (statusCode == 206))) {
        if (statusCode == 416) {
            [self connectionDidFinishLoading:connection];
        } else {
            [self reset];
            [self connection:connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:[NSDictionary dictionaryWithObject:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:@"kLocalErrorDescription"]]];
        }

        return;
    }

    if (!_isSupportBreakPointContinueTransfer) {
        [self resetReceivedData];
        _receivedData = [[NSMutableData alloc] init];
    }

    _expectedDataLength = [NSNumber numberWithLongLong:len];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.netProccessBlock) {
        self.netProccessBlock(YES, [NSNumber numberWithFloat:(totalBytesWritten * 1.0f / totalBytesExpectedToWrite * 1.0f)]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
    if (_isSupportBreakPointContinueTransfer && _tempFileHandle) {
        [_tempFileHandle writeData:newData];
    } else {[_receivedData appendData:newData]; }

    _currentDataLength += newData.length;

    if (self.netProccessBlock) {
        self.netProccessBlock(NO, [NSNumber numberWithFloat:(_currentDataLength * 1.0f / [_expectedDataLength longLongValue] * 1.0f)]);
    }

    _tryCounter = 0;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self reset];

    if (_tryCounter < _tryCount) {
        _tryCounter++;

        //		if(_delegate
        //		   && [(NSObject *)_delegate respondsToSelector:@selector(connection:willTryRequestAgain:forError:)]) {
        //			[_delegate connection:self willTryRequestAgain:_tryCounter forError:error];
        //		}

        sleep(1);
        [self sendAsynchronousRequest];
    } else {
        if (self.networkingCompleteBlock) {
            self.networkingCompleteBlock(NO, nil, error);
        }

        if (_removeTempFileWhenRequestFailed) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempFile error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:_tempConfigureFile error:nil];
        }

        _tryCounter = 0;
        [self finish];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_isSupportBreakPointContinueTransfer) {
        if (_tempFileHandle) {
            [_tempFileHandle closeFile];
            _tempFileHandle = nil;
        }

        NSError *error = nil;

        // 将临时文件更名为正式文件名
        [[NSFileManager defaultManager] moveItemAtPath:_tempFile toPath:[self fileSavePath] error:&error];

        if (error) {
            KSLog(@"rename '%@' to '%@' failed,error info is :%@",
                _tempFile, _fileSavePath, [error localizedDescription]);
        }

        //删除临时配置文件
        [[NSFileManager defaultManager] removeItemAtPath:_tempConfigureFile error:&error];

        if (error) {
            KSLog(@"remove file '%@' failed,error info is :%@",
                _tempConfigureFile, [error localizedDescription]);
        }

        _receivedData = [NSMutableData dataWithContentsOfFile:[self fileSavePath]];
        [[NSFileManager defaultManager] removeItemAtPath:[self fileSavePath] error:&error];
    }

    if (self.networkingCompleteBlock) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.networkingCompleteBlock(YES, _receivedData, nil);
    }

    [self reset];
    [self finish];
}

- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    _challenge = challenge;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"服务器证书"
        message             :@"这个网站有一个服务器证书，点击“接受”，继续访问该网站，如果你不确定，请点击“取消”。"
        delegate            :self
        cancelButtonTitle   :@"接受"
        otherButtonTitles   :@"取消", nil];

    [alertView show];
}

#pragma mark -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Accept=0,Cancel=1;

    if (buttonIndex == 0) {
        NSURLCredential         *credential;
        NSURLProtectionSpace    *protectionSpace;
        SecTrustRef             trust;
        NSString                *host;
        SecCertificateRef       serverCert;
        assert(_challenge != nil);
        protectionSpace = [_challenge protectionSpace];
        assert(protectionSpace != nil);
        trust = [protectionSpace serverTrust];
        assert(trust != NULL);
        credential = [NSURLCredential credentialForTrust:trust];
        assert(credential != nil);
        host = [[_challenge protectionSpace] host];

        if (SecTrustGetCertificateCount(trust) > 0) {
            serverCert = SecTrustGetCertificateAtIndex(trust, 0);
        } else {
            serverCert = NULL;
        }

        [[_challenge sender] useCredential:credential forAuthenticationChallenge:_challenge];
    }
}

@end
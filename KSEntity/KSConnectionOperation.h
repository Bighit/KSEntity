//
//  KSUrlConnection.h
//  KSEntity
//
//  Created by Hantianyu on 15/7/21.
//  Copyright (c) 2015年 HTY. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef debug
  #define KSLog(fmt, ...)   NSLog((@"KSEntityLog:" fmt), ##__VA_ARGS__)
#else
  #define KSLog(fmt, ...)   {}
#endif

typedef void (^ NetWorkingCompleteBlock)(BOOL isSuccess, id jsonData, NSError *err);
typedef void (^ NetProccessBlock)(BOOL isUpload, NSNumber *percent);

@interface KSConnectionOperation : NSOperation {
    NSURLConnection *_urlConnection;
    NSMutableData   *_receivedData;
    NSFileHandle    *_tempFileHandle;
    NSString        *_tempFile;
    NSString        *_tempConfigureFile;
    NSUInteger      _tryCounter;

    NSTimer *_postTimer;

    unsigned long long  _currentDataLength;
    BOOL                _isSupportBreakPointContinueTransfer;
    
    NSURLAuthenticationChallenge *_challenge;
}

@property (nonatomic, assign)   NSInteger   timeout;
@property (nonatomic, assign)   NSUInteger  tryCount;
@property (nonatomic, assign)   BOOL        useAsyncRequestMethod;
@property (nonatomic, assign)   BOOL        removeTempFileWhenRequestFailed;

@property (nonatomic, readonly, strong)   NSNumber              *expectedDataLength;
@property (nonatomic, readonly, strong)   NSMutableURLRequest   *urlRequest;
@property (nonatomic, readonly, strong)   NSURLResponse         *urlResponse;
@property (nonatomic, readonly, assign)   BOOL                  isExecuting;
@property (nonatomic, readonly)   BOOL                          isFinished;

@property (nonatomic, strong)   NSObject            *tag;
@property (nonatomic, copy) NSString                *fileSavePath;
@property (nonatomic, copy) NSString                *requestUrlString;
@property (nonatomic, assign)   BOOL                isUsePostTimer;
@property (nonatomic, copy) NetWorkingCompleteBlock networkingCompleteBlock;
@property (nonatomic, copy) NetProccessBlock        netProccessBlock;
@property (nonatomic, strong) NSDictionary          *requestHeaders;
@property (nonatomic, strong) NSDictionary          *requestParams;
#pragma mark -
#pragma mark public mrethods

- (id)initWithUrl:(NSString *)urlString;
- (NSString *)fileSavePath;
- (void)setFileSavePath:(NSString *)path;
- (void)setSupportBreakPointContinueTransfer:(BOOL)isSupport;
- (BOOL)isFileDownloadFinished;
- (NSData *)sendSynchronousRequest;
- (void)sendAsynchronousRequest;
- (void)setHTTPMethod:(NSString *)string;
- (void)cancel:(BOOL)force;
@end
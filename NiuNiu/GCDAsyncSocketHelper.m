//
//  GCDAyncSocketHelper.m
//  NiuNiu
//
//  Created by childhood on 13-4-11.
//
//

#import "GCDAsyncSocketHelper.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"


#define LOCAL_CONNECT 1
#ifdef LOCAL_CONNECT
#define HOST @"192.168.1.222"
#define PORT 6666
#else
#define GOOGLE_HOST @"www.google.com"
#define GOOGLE_PORT 80
#endif

//packet = 描述cmd和content数据存储量之和的数据  + cmd + content
#define LEN_SIZE 4 //描述命令长度和数据内容长度之和的数据存储量 4个字节
#define CMD_SIZE 4 //命令长度 4个字节

@interface GCDAyncSocketHelper(PrivateMethods)
    -(NSDictionary *)analysisDataToDictionary:(NSData *)data;
    -(NSString *)analysisDataToString:(NSData *)data;
@end

@implementation GCDAyncSocketHelper


- (id)init
{
    if((self = [super init]))
    {
        _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)connect
{
    NSError *error = nil;
    if(![_mySocket connectToHost:HOST onPort:PORT error:&error])
    {
        CCLOG(@"连接出现问题，请检查%@", error);
    }
}

- (NSData *) wrapPacketWithCmd:(NSUInteger)cmd contentDic:(NSDictionary *)contentDic
{
    NSData *data = [[[NSData alloc]init] autorelease];
    uint32_t cmdNetTrans = htonl((uint32_t)cmd);
    
    NSError *error = nil;
    NSData *body = [[CJSONSerializer serializer] serializeDictionary:contentDic error:&error];
       
    NSUInteger length = body.length + CMD_SIZE;
    uint32_t lengthNetTrans = htonl((uint32_t)length);
    
    NSMutableData *header = [[[NSMutableData alloc] initWithBytes:&lengthNetTrans length:4] autorelease];
    [header appendBytes:&cmdNetTrans length:4];
    [header appendData:body];
    
    data = header;
    return data;
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_mySocket writeData:data withTimeout:timeout tag:tag];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_mySocket readDataWithTimeout:timeout tag:tag];
}

#pragma mark - 分析包数据
- (NSDictionary *)analysisDataToDictionary:(NSData *)data
{
    //解析cmd和content数据存储之和
    NSUInteger length;
    [data getBytes:&length length:LEN_SIZE];
    uint32_t len = htonl((uint32_t)length);
//    CCLOG(@"length is : %d", len);

    //解析命令
//    Byte cmdByte[CMD_SIZE];
//    [data getBytes:cmdByte range:NSMakeRange(LEN_SIZE, CMD_SIZE)];
//    NSString *cmdStr = [[[NSString alloc] initWithBytes:cmdByte length:4 encoding:NSUTF8StringEncoding] autorelease];
//    CCLOG(@"cmd is %@", cmdStr);
    
    //解析内容
    NSError *error;
    Byte content[len-CMD_SIZE];
    [data getBytes:content range:NSMakeRange(LEN_SIZE+CMD_SIZE, len-CMD_SIZE)];
    NSData *contentData = [NSData dataWithBytes:content length:len-CMD_SIZE];
//    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
//    CCLOG(@"contentStr :%@", contentStr);
    NSDictionary *contentDic = [[CJSONDeserializer deserializer]deserializeAsDictionary:contentData error:&error];
    CCLOG(@"contentDic :%@", contentDic);
    
    return contentDic;
}

- (NSString *)analysisDataToString:(NSData *)data
{
    //解析cmd和content数据存储之和
    NSUInteger length;
    [data getBytes:&length length:LEN_SIZE];
    uint32_t len = htonl((uint32_t)length);
    CCLOG(@"length is : %d", len);

    //解析内容
    Byte content[len-CMD_SIZE];
    [data getBytes:content range:NSMakeRange(LEN_SIZE+CMD_SIZE, len-CMD_SIZE)];
    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"contentStr :%@", contentStr);
    return contentStr;
}


#pragma mark - socket delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    CCLOG(@"AsyncSocket didConnectToHost: %@, port: %d", host, port);
    CCLOG(@"connect success!");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    CCLOG(@"%@, tag: %ld", NSStringFromSelector(_cmd), tag);
}

//*
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if(tag == 2003)
    {
        NSDictionary *dic = [self analysisDataToDictionary:data];
        CCLOG(@"%@", dic);
    }else if(tag == 1003)
    {
        CCLOG(@"recieved 1003");
    }
}
//*/

- (void)dealloc
{
    [_mySocket release];
    _mySocket = nil;
    [super dealloc];
}
@end

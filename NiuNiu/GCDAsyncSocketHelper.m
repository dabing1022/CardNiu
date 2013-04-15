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
#import "Game.h"
#import "CmdLoginHandler.h"


#define LOCAL_CONNECT 1
#ifdef LOCAL_CONNECT
#define LOGIN_HOST @"192.168.1.222"
#define LOGIN_PORT 7000
#else
#define LOGIN_HOST @"www.google.com"
#define LOGIN_PORT 80
#endif

//packet = 描述cmd和content数据存储量之和的数据  + cmd + content
#define LEN_SIZE 4 //描述命令长度和数据内容长度之和的数据存储量 4个字节
#define CMD_SIZE 4 //命令长度 4个字节

@implementation GCDAsyncSocketHelper
@synthesize loginSocket,familySocket,cardSocket;
static GCDAsyncSocketHelper *_instance = nil;
+ (GCDAsyncSocketHelper *)sharedHelper
{
    if(!_instance)
    {
        _instance = [[self alloc]init];
    }
    return _instance;
}

- (id)init
{
    if((self = [super init]))
    {
        loginSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        familySocket = nil;
        cardSocket = nil;
    }
    return self;
}

#pragma mark - 连接服务器
- (void)connectLoginServer
{
    NSError *error = nil;
    if(![loginSocket connectToHost:LOGIN_HOST onPort:LOGIN_PORT error:&error])
    {
        CCLOG(@"连接登录服务器出现问题，请检查%@", error);
    }
}

- (void)connectFamilyServer
{
    familySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if(![loginSocket connectToHost:FAMILY_IP onPort:FAMILY_PORT error:&error])
    {
        CCLOG(@"连接家产服务器出现问题，请检查%@", error);
    }
}

- (void)connectCardServer
{
    cardSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if(![loginSocket connectToHost:CARD_IP onPort:CARD_PORT error:&error])
    {
        CCLOG(@"连接牌局服务器出现问题，请检查%@", error);
    }
}

#pragma mark - 关闭socket
- (void)disconnectLoginServer
{
    [loginSocket setDelegate:nil delegateQueue:NULL];
    [loginSocket disconnect];
    [loginSocket release];
    loginSocket = nil;
}

- (void)disconnectFamilyServer
{
    [familySocket setDelegate:nil delegateQueue:NULL];
    [familySocket disconnect];
    [familySocket release];
    familySocket = nil;
}

- (void)disconnectCardServer
{
    [cardSocket setDelegate:nil delegateQueue:NULL];
    [cardSocket disconnect];
    [cardSocket release];
    cardSocket = nil;
}

#pragma mark - 读写数据
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

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag socketType:(int)type
{
    if(type == LOGIN_SOCKET)
        [loginSocket writeData:data withTimeout:timeout tag:tag];
    else if(type == FAMILY_SOCKET)
        [familySocket writeData:data withTimeout:timeout tag:tag];
    else if(type == CARD_SOCKET)
        [cardSocket writeData:data withTimeout:timeout tag:tag];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag socketType:(int)type
{
    if(type == LOGIN_SOCKET)
        [loginSocket readDataWithTimeout:timeout tag:tag];
    else if(type == FAMILY_SOCKET)
        [familySocket readDataWithTimeout:timeout tag:tag];
    else if(type == CARD_SOCKET)
        [cardSocket readDataWithTimeout:timeout tag:tag];
}

#pragma mark - 分析包数据
+ (NSDictionary *)analysisDataToDictionary:(NSData *)data
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
    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"contentStr :%@", contentStr);
    NSDictionary *contentDic = [[CJSONDeserializer deserializer]deserializeAsDictionary:contentData error:&error];
    CCLOG(@"contentDic :%@", contentDic);
    
    return contentDic;
}

+ (NSString *)analysisDataToString:(NSData *)data
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

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    CCLOG(@"连接失败！");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    CCLOG(@"%@, tag: %ld", NSStringFromSelector(_cmd), tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag) {
        CCLOG(@"Recieved cmd %ld", tag);
        case CMD_LOGIN:
            [CmdLoginHandler processLoginData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CCLOG(@"dispatch_get_main_queue ui process, cmd: %ld", tag);
                CCScene *currentScene = [[CCDirector sharedDirector]runningScene];
                if([currentScene respondsToSelector:@selector(updateUIByLogin:)])
                {
                    //[currentScene updateUIByLogin:data];
                }

                
            });
            break;
            
        default:
            CCLOG(@"PLEASE CHECK THE CMD!");
            break;
    }
}

#pragma mark - 返回主线程更新UI




#pragma mark - dealloc
- (void)dealloc
{
    [self disconnectLoginServer];
    [self disconnectFamilyServer];
    [self disconnectCardServer];
    [super dealloc];
}
@end

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
#import "CardPlayingHandler.h"
#import "CardPlayingScene.h"
#import "FamilyPropertyScene.h"
#import "PawnShopScene.h"


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
@synthesize CARD_IP,CARD_PORT,FAMILY_IP,FAMILY_PORT,loginSocket,familySocket,cardSocket;
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
    if(![familySocket connectToHost:[GCDAsyncSocketHelper sharedHelper].FAMILY_IP
                             onPort:[GCDAsyncSocketHelper sharedHelper].FAMILY_PORT error:&error])
    {
        CCLOG(@"连接家产服务器出现问题，请检查%@", error);
    }
}

- (void)connectCardServer
{
    cardSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if(![cardSocket connectToHost:[GCDAsyncSocketHelper sharedHelper].CARD_IP
                           onPort:[GCDAsyncSocketHelper sharedHelper].CARD_PORT error:&error])
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
- (uint32_t)analysisDataLen:(NSData *)data
{
    //解析cmd和content数据存储之和
    NSUInteger length;
    [data getBytes:&length length:LEN_SIZE];
    uint32_t len = htonl((uint32_t)length);
    return len;
}

- (uint32_t)analysisDataCMD:(NSData *)data
{
    //解析cmd
    NSUInteger cmd;
    [data getBytes:&cmd range:NSMakeRange(LEN_SIZE, CMD_SIZE)];
    uint32_t cmd32 = htonl((uint32_t)cmd);
    return cmd32;
}

- (NSDictionary *)analysisDataToDictionary:(NSData *)data
{
    uint32_t len = [self analysisDataLen:data];
    
    //解析内容
    NSError *error;
    Byte content[len-CMD_SIZE];
    [data getBytes:content range:NSMakeRange(LEN_SIZE+CMD_SIZE, len-CMD_SIZE)];
    NSData *contentData = [NSData dataWithBytes:content length:len-CMD_SIZE];
    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"contentStr :%@", contentStr);
    NSDictionary *contentDic = [[CJSONDeserializer deserializer]deserializeAsDictionary:contentData error:&error];
    
    return contentDic;
}

- (NSString *)analysisDataToString:(NSData *)data
{
    uint32_t len = [self analysisDataLen:data];

    //解析内容
    Byte content[len-CMD_SIZE];
    [data getBytes:content range:NSMakeRange(LEN_SIZE+CMD_SIZE, len-CMD_SIZE)];
    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"contentStr :%@", contentStr);
    return contentStr;
}

- (NSArray *)analysisDataToArray:(NSData *)data
{
    uint32_t len = [self analysisDataLen:data];
    
    //解析内容
    NSError *error;
    Byte content[len-CMD_SIZE];
    [data getBytes:content range:NSMakeRange(LEN_SIZE+CMD_SIZE, len-CMD_SIZE)];
    NSData *contentData = [NSData dataWithBytes:content length:len-CMD_SIZE];
    NSString *contentStr = [[[NSString alloc] initWithBytes:content length:len-CMD_SIZE encoding:NSUTF8StringEncoding] autorelease];
    CCLOG(@"contentStr :%@", contentStr);
    NSArray *contentArr = [[CJSONDeserializer deserializer]deserializeAsArray:contentData error:&error];
    CCLOG(@"contentArr :%@", contentArr);
    
    return contentArr;
}


#pragma mark - socket delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    CCLOG(@"AsyncSocket didConnectToHost: %@, port: %d", host, port);
    CCLOG(@"connect success!");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    [self disconnectLoginServer];
    [self disconnectFamilyServer];
    [self disconnectCardServer];
    CCLOG(@"连接失败！");
    
    UIView *view = [[CCDirector sharedDirector]view];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"网络连接失败!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [view addSubview:alertView];
    [alertView show];
    [alertView release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        CCLOG(@"点击确定");
    } else {
        CCLOG(@"点击取消");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    CCLOG(@"%@, tag: %ld", NSStringFromSelector(_cmd), tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if(tag != 0)return;
    uint32_t cmd = [self analysisDataCMD:data];
    CCLOG(@"cmd is %d", cmd);
    switch (cmd) {
        case CMD_LOGIN:
        {
            [CmdLoginHandler processLoginData:data];
            break;
        }
        case CMD_INFO:
        {
            NSString *info = [[self analysisDataToString:data]retain];
            if([info isEqualToString:INFO_WAITING_ASSIGN]){
                [self dispatchAsyncWithClass:[CardPlayingScene class] selector:@selector(waitingAssign) withObject:nil];
            }
            [info release];
            break;
        }
        case CMD_ENTER_DESK:{
            CCLOG(@"CMD_ENTER_DESK");
            [CardPlayingHandler processEnterDeskData:data];
            [self dispatchAsyncWithClass:[CardPlayingScene class] selector:@selector(assignInDesk) withObject:nil];
            break;
        }
        case CMD_OTHER_PLAYER_IN:{
            CCLOG(@"CMD_OTHER_PLAYER_IN");
            User *user = [CardPlayingHandler processOtherPlayerIn:data];
            [self dispatchAsyncWithClass:[CardPlayingScene class] selector:@selector(otherPlayerIn:) withObject:user];
            break;
        }
        case CMD_VIEW_PROFILE:{
            User *user = [CardPlayingHandler processViewProfile:data];
            [self dispatchAsyncWithClass:[CardPlayingScene class] selector:@selector(viewProfile:) withObject:user];
            break;
        }
        case CMD_GRAB_Z:{
            CCLOG(@"CMD_GRAB_Z");
            NSString *zUserID = [CardPlayingHandler processGrabZ:data];
            [self dispatchAsyncWithClass:[CardPlayingScene class] selector:@selector(grabZ:) withObject:zUserID];
            break;
        }
        case CMD_ERROR:{
            CCLOG(@"CMD_ERROR");
            break;
        }
        default:
            CCLOG(@"PLEASE CHECK THE CMD!");
            break;
    }
    [self readDataWithTimeout:-1 tag:0 socketType:LOGIN_SOCKET];
    [self readDataWithTimeout:-1 tag:0 socketType:FAMILY_SOCKET];
    [self readDataWithTimeout:-1 tag:0 socketType:CARD_SOCKET];
}

#pragma mark - 返回主线程更新UI
- (void)dispatchAsyncWithClass:(Class)class selector:(SEL)sel withObject:(id)obj
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CCNode *currentScene = [[[CCDirector sharedDirector]runningScene] getChildByTag:0];
        if([currentScene isKindOfClass:class] && [currentScene respondsToSelector:sel])
        {
            if(!obj)
                [currentScene performSelector:sel];
            else
                [currentScene performSelector:sel withObject:obj];
        }
    });
}

#pragma mark - dealloc
- (void)dealloc
{
    [self disconnectLoginServer];
    [self disconnectFamilyServer];
    [self disconnectCardServer];
    [super dealloc];
}
@end

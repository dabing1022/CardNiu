//
//  GCDAyncSocketHelper.h
//  NiuNiu
//
//  Created by childhood on 13-4-11.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCDAsyncSocket.h"

#define LOGIN_SOCKET 1
#define FAMILY_SOCKET 2
#define CARD_SOCKET 3
@interface GCDAsyncSocketHelper : NSObject
{
    //登录、内购
    GCDAsyncSocket *loginSocket;
    //家产、典当行
    GCDAsyncSocket *familySocket;
    //牌局
    GCDAsyncSocket *cardSocket;
}

@property(nonatomic, retain)NSString *CARD_IP;
@property(nonatomic, assign)int CARD_PORT;
@property(nonatomic, retain)NSString *FAMILY_IP;
@property(nonatomic, assign)int FAMILY_PORT;

@property(nonatomic, readonly)GCDAsyncSocket *loginSocket;
@property(nonatomic, readonly)GCDAsyncSocket *familySocket;
@property(nonatomic, readonly)GCDAsyncSocket *cardSocket;

@property(nonatomic, assign)int sceneID;

+ (GCDAsyncSocketHelper *)sharedHelper;
- (void) connectLoginServer;
- (void) connectFamilyServer;
- (void) connectCardServer;

- (void) disconnectLoginServer;
- (void) disconnectFamilyServer;
- (void) disconnectCardServer;

- (NSData *) wrapPacketWithCmd:(NSUInteger)cmd contentDic:(NSDictionary *)contentDic;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag socketType:(int)type;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag socketType:(int)type;
//将NSData数据解析为NSDictionary
- (NSDictionary *)analysisDataToDictionary:(NSData *)data;
//将NSData数据解析位NSString
- (NSString *)analysisDataToString:(NSData *)data;
//将NSData数据解析位NSArray
- (NSArray *)analysisDataToArray:(NSData *)data;
@end

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

@protocol NiuNiuGCDAsyncSocketDelegate <NSObject>

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
+ (NSDictionary *)analysisDataToDictionary:(NSData *)data;
//将NSData数据解析位NSString
+ (NSString *)analysisDataToString:(NSData *)data;
@end


NSString *CARD_IP;
int CARD_PORT;
NSString *FAMILY_IP;
int FAMILY_PORT;

#define LOGIN_SOCKET 1
#define FAMILY_SOCKET 2
#define CARD_SOCKET 3
@interface GCDAsyncSocketHelper : NSObject <NiuNiuGCDAsyncSocketDelegate>
{
    //登录、内购
    GCDAsyncSocket *loginSocket;
    //家产、典当行
    GCDAsyncSocket *familySocket;
    //牌局
    GCDAsyncSocket *cardSocket;
}

+ (GCDAsyncSocketHelper *)sharedHelper;
@property(nonatomic, readonly)GCDAsyncSocket *loginSocket;
@property(nonatomic, readonly)GCDAsyncSocket *familySocket;
@property(nonatomic, readonly)GCDAsyncSocket *cardSocket;
@end

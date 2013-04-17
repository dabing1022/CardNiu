//
//  CmdLoginHandler.m
//  NiuNiu
//
//  Created by childhood on 13-4-12.
//
//

#import "CmdLoginHandler.h"
#import "GCDAsyncSocketHelper.h"
#import "GameData.h"
#import "User.h"

@implementation CmdLoginHandler

+ (void)processLoginData:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    
    User *player = [User userWithUserID:[dic objectForKey:@"userID"]
                               nickName:[dic objectForKey:@"nickName"]
                               userName:[dic objectForKey:@"userName"]
                               avatarID:[dic objectForKey:@"avatarID"]
                                 roleID:[[dic objectForKey:@"userTypeID"]intValue]
                                 coinYL:[[dic objectForKey:@"coinYL"]intValue]
                                 coinTB:[[dic objectForKey:@"coinTB"]intValue]];
    [[GameData sharedGameData] setPlayer:player];
    [[[GameData sharedGameData]userDic]setObject:player forKey:player.userID];
    CCLOG(@"player userID:%@", [[GameData sharedGameData]player].userID);
    CCLOG(@"player userName:%@", [[GameData sharedGameData]player].userName);
    CCLOG(@"player avatarID:%@", [[GameData sharedGameData]player].avatarID);
    CCLOG(@"player userTypeID:%d", [[GameData sharedGameData]player].roleID);
    CCLOG(@"player coinYL:%d", [[GameData sharedGameData]player].coinYL);
    CCLOG(@"player coinTB:%d", [[GameData sharedGameData]player].coinTB);
    
    
    
    [GCDAsyncSocketHelper sharedHelper].CARD_IP = [dic objectForKey:@"CARD_IP"];
    [GCDAsyncSocketHelper sharedHelper].CARD_PORT = [[dic objectForKey:@"CARD_PORT"]intValue];
    [GCDAsyncSocketHelper sharedHelper].FAMILY_IP = [dic objectForKey:@"FAMILY_IP"];
    [GCDAsyncSocketHelper sharedHelper].FAMILY_PORT = [[dic objectForKey:@"FAMILY_PORT"]intValue];
    CCLOG(@"CARD_IP:%@",[GCDAsyncSocketHelper sharedHelper].CARD_IP);
    CCLOG(@"CARD_PORT:%d",[GCDAsyncSocketHelper sharedHelper].CARD_PORT);
    CCLOG(@"FAMILY_IP:%@",[GCDAsyncSocketHelper sharedHelper].FAMILY_IP);
    CCLOG(@"FAMILY_PORT:%d",[GCDAsyncSocketHelper sharedHelper].FAMILY_PORT);
    //连接家产服务器
    [[GCDAsyncSocketHelper sharedHelper]disconnectLoginServer];
    if(![[GCDAsyncSocketHelper sharedHelper]familySocket])
        [[GCDAsyncSocketHelper sharedHelper]connectFamilyServer];
    
}
@end

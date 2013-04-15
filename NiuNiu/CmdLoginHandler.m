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
    NSDictionary *dic = [GCDAsyncSocketHelper analysisDataToDictionary:data];
    
    User *player = [User userWithUserName:[dic objectForKey:@"userName"]
                                 avatarID:[dic objectForKey:@"avatarID"]
                                   roleID:[[dic objectForKey:@"userTypeID"]intValue]
                                   coinYL:[[dic objectForKey:@"coinYL"]intValue]
                                   coinTB:[[dic objectForKey:@"coinTB"]intValue]];
    [[GameData sharedGameData] setPlayer:player];
    CCLOG(@"player userName:%@", [[GameData sharedGameData]player].userName);
    CCLOG(@"player avatarID:%@", [[GameData sharedGameData]player].avatarID);
    CCLOG(@"player userTypeID:%d", [[GameData sharedGameData]player].roleID);
    CCLOG(@"player coinYL:%d", [[GameData sharedGameData]player].coinYL);
    CCLOG(@"player coinTB:%d", [[GameData sharedGameData]player].coinTB);
    
    
    
    CARD_IP = [dic objectForKey:@"CARD_IP"];
    CARD_PORT = [[dic objectForKey:@"CARD_PORT"]intValue];
    FAMILY_IP = [dic objectForKey:@"FAMILY_IP"];
    FAMILY_PORT = [[dic objectForKey:@"FAMILY_PORT"]intValue];
    
    //连接家产服务器
    [[GCDAsyncSocketHelper sharedHelper]disconnectLoginServer];
    if(![[GCDAsyncSocketHelper sharedHelper]familySocket])
        [[GCDAsyncSocketHelper sharedHelper]connectFamilyServer];
}
@end

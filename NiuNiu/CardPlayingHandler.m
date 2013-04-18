//
//  CardPlayingHandler.m
//  NiuNiu
//
//  Created by childhood on 13-4-18.
//
//

#import "CardPlayingHandler.h"
#import "GCDAsyncSocketHelper.h"
#import "GameData.h"
#import "User.h"

@implementation CardPlayingHandler

+ (void)processEnterDeskData:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    
    [[GameData sharedGameData]player].roleTitle = [dic objectForKey:@"userTitle"];
    [[GameData sharedGameData]player].tableID = [[dic objectForKey:@"tableID"]intValue];
    [[GameData sharedGameData]player].chairID = [[dic objectForKey:@"chairID"]intValue];
    [[GameData sharedGameData]player].posID = 2;
    
    NSArray *otherPlayers = (NSArray *)[dic objectForKey:@"otherPlayers"];
    CCLOG(@"otherPlayers.length:%d",[otherPlayers count]);
    if([otherPlayers count] == 0)   return;
    for(NSDictionary *userDic in otherPlayers)
    {
        User *user = [self user:userDic];
        [[[GameData sharedGameData]userDic]setObject:user forKey:user.userID];
    }
}

+ (User *)processOtherPlayerIn:(NSData *)data
{
    NSDictionary *userDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    User *user = [self user:userDic];    
    [[[GameData sharedGameData]userDic]setObject:user forKey:user.userID];
    return user;
}

+ (User *)user:(NSDictionary *)userDic
{
    User *user = [User userWithUserID:[userDic objectForKey:@"userID"]
                             nickName:[userDic objectForKey:@"nickName"]
                             userName:[userDic objectForKey:@"userName"]
                             avatarID:[userDic objectForKey:@"avatarID"]
                               roleID:[[userDic objectForKey:@"userTypeID"]intValue]
                               coinYL:[[userDic objectForKey:@"coinYL"]intValue]
                               coinTB:[[userDic objectForKey:@"coinTB"]intValue]];
    user.roleTitle = [userDic objectForKey:@"userTitle"];
    user.tableID = [[userDic objectForKey:@"tableID"]intValue];
    user.chairID = [[userDic objectForKey:@"chairID"]intValue];
    user.posID = [User chairID2posID:user.chairID];
    return  user;
}


@end

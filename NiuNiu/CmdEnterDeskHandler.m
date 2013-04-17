//
//  CmdEnterDeskHandler.m
//  NiuNiu
//
//  Created by childhood on 13-4-17.
//
//

#import "CmdEnterDeskHandler.h"
#import "GCDAsyncSocketHelper.h"
#import "GameData.h"
#import "User.h"
@implementation CmdEnterDeskHandler

/*
 *DATA:{"userID":"10005","avatarID":"1_1","userName":"","nickName":"王二麻子","userTypeID":1001,"userTitle":"农民","tableID":16,"charID":2,"coinTB":2000,"otherPlayers":[{"userID":"10006","avatarID":"1_1","nickName":"王二麻子","userTypeID":1001,"userTitle":"农民","tableID":16,"charID":1,"coinTB":2000}]}
*/
+ (void)processEnterDeskData:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    
    [[GameData sharedGameData]player].roleTitle = [dic objectForKey:@"userTitle"];
    [[GameData sharedGameData]player].tableID = [[dic objectForKey:@"tableID"]intValue];
    [[GameData sharedGameData]player].chairID = [[dic objectForKey:@"chairID"]intValue];
    
    NSArray *otherPlayers = (NSArray *)[dic objectForKey:@"otherPlayers"];
    CCLOG(@"otherPlayers.length:%d",[otherPlayers count]);
    if([otherPlayers count] == 0)   return;
    for(NSDictionary *userDic in otherPlayers)
    {
        User *user = [User userWithUserID:[userDic objectForKey:@"userID"]
                                 nickName:[userDic objectForKey:@"nickName"]
                                 userName:[userDic objectForKey:@"userName"]
                                 avatarID:[userDic objectForKey:@"avatarID"]
                                   roleID:[[userDic objectForKey:@"userTypeID"]intValue]
                                   coinYL:[[userDic objectForKey:@"coinYL"]intValue]
                                   coinTB:[[userDic objectForKey:@"coinTB"]intValue]];
        user.roleTitle = [userDic objectForKey:@"userTitle"];
        user.tableID = [[dic objectForKey:@"tableID"]intValue];
        user.chairID = [[dic objectForKey:@"chairID"]intValue];
        [[[GameData sharedGameData]userDic]setObject:user forKey:user.userID];
    }
}

@end

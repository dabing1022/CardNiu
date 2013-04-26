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
#import "UserCard.h"
#import "CardsHelper.h"

@implementation CardPlayingHandler
//处理玩家本人进入牌桌
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

//处理有玩家进入
+ (User *)processOtherPlayerIn:(NSData *)data
{
    NSDictionary *userDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    User *user = [self user:userDic];    
    [[[GameData sharedGameData]userDic]setObject:user forKey:user.userID];
    return user;
}

//处理查看玩家头像具体信息
+ (User *)processViewProfile:(NSData *)data
{
    NSDictionary *userDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    User *user = [[[self user:userDic]retain]autorelease];
    user.gamblerTitle = [userDic objectForKey:@"gameTitle"];
    user.familyPropertyTitle = [userDic objectForKey:@"assetTitle"];
    user.cardTitle = [userDic objectForKey:@"cardTitle"];
    user.familyPropertyValue = [[userDic objectForKey:@"jiaChan"]intValue];

    return user;
}

//处理抢庄
+ (NSString *)processGrabZ:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSString *zUserID = [dic objectForKey:@"zUserID"];
    [[GameData sharedGameData]setZUserID:zUserID];
    return zUserID;
}

//抢庄结果
//包括庄家的userID和下注倍率数组
+ (NSString *)processGrabResult:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSString *zUserID = [dic objectForKey:@"zUserID"];
    [[GameData sharedGameData]setZUserID:zUserID];
    return zUserID;
}

//开始下注
+ (NSArray *)processStartBet:(NSData *)data
{
    NSArray *betArr = [[GCDAsyncSocketHelper sharedHelper]analysisDataToArray:data];
    return betArr;
}

//处理其他玩家下注结果
+ (NSDictionary *)processOtherPlayerBetResult:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    return dic;
}

//处理5张牌具体数据,转化为cardData数组
+ (NSMutableArray *)processCardData:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSArray *cardDataDicArr = (NSArray *)[dic objectForKey:@"cards"];
    NSMutableArray *cardsDataArr = [self cardDataDicArr2cardsDataArr:cardDataDicArr];
    [[GameData sharedGameData]player].cardsDataArr = cardsDataArr;
    return cardsDataArr;
}


//[{"color":1,"value":7},{"color":3,"value":10},{"color":2,"value":3},{"color":4,"value":3},{"color":4,"value":7}]
//--->[cardData1,cardData2,cardData3,cardData4,cardData5]
//cardData1.color=1,cardData1.value=7...
+ (NSMutableArray *)cardDataDicArr2cardsDataArr:(NSArray *)cardDataDicArr
{
    NSMutableArray *cardsDataArr = [NSMutableArray arrayWithCapacity:[cardDataDicArr count]];
    for(int i = 0; i < [cardDataDicArr count]; i++){
        NSDictionary *singleCardDataDic = [cardDataDicArr objectAtIndex:i];
        CardData *cardData = [[CardData alloc]init];
        cardData.color = [[singleCardDataDic objectForKey:@"color"]intValue];
        cardData.value = [[singleCardDataDic objectForKey:@"value"]intValue];
        [cardsDataArr addObject:cardData];
        [cardData release];
    }
    return cardsDataArr;
}

//处理亮牌数据(userID/cardSize/cards)
+ (NSDictionary *)processStartShowCards:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    return dic;
}

//处理最后所有玩家的输赢情况
+ (void)processFinalWinLoseResult:(NSData *)data
{
    NSArray *betArr = [[GCDAsyncSocketHelper sharedHelper]analysisDataToArray:data];
    for(int i = 0; i < [betArr count]; i++){
        NSDictionary *singlePlayerFinalResult = [betArr objectAtIndex:i];
        NSString *userID = [singlePlayerFinalResult objectForKey:@"userID"];
        int winCoinTB = [[singlePlayerFinalResult objectForKey:@"winCoinTB"]intValue];
        User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
        [user setWinCoinTB:winCoinTB];
    }
}

+ (void)processUpdateUsersInfo:(NSData *)data
{
    NSArray *betArr = [[GCDAsyncSocketHelper sharedHelper]analysisDataToArray:data];
    for(int i = 0; i < [betArr count]; i++){
        NSDictionary *singlePlayerInfo = [betArr objectAtIndex:i];
        NSString *userID = [singlePlayerInfo objectForKey:@"userID"];
        int coinTB = [[singlePlayerInfo objectForKey:@"coinTB"]intValue];//更新玩家铜币
        User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
        [user setCoinTB:coinTB];
    }
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
    CCLOG(@"user userID:%@, posID:%d",user.userID,user.posID);
    return  user;
}


@end

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
    [[GameData sharedGameData]player].canGrabZ = [[dic objectForKey:@"canGrabZ"]boolValue];
    [[GameData sharedGameData]player].canBet = [[dic objectForKey:@"canBet"]boolValue];
    [[GameData sharedGameData]player].showCardsDataArr = nil;
    [[GameData sharedGameData]player].cardType = [[dic objectForKey:@"cardSize"]intValue];
    
    [[GameData sharedGameData]setZUserID:[dic objectForKey:@"zUserID"]];
    
    [[GameData sharedGameData]player].posID = 2;
    
    NSArray *otherPlayers = (NSArray *)[dic objectForKey:@"otherPlayers"];
    CCLOG(@"otherPlayers.length:%d",[otherPlayers count]);
    if([otherPlayers count] == 0)   return;
    for(NSDictionary *userDic in otherPlayers)
    {
        User *user = [self user:userDic];
        [[GameData sharedGameData]addUserByUser:user];
    }
}

//处理有玩家进入
+ (User *)processOtherPlayerIn:(NSData *)data
{
    NSDictionary *userDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    User *user = [self user:userDic];    
    [[GameData sharedGameData]addUserByUser:user];
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
    [[[GameData sharedGameData]player]setCardsDataArr:cardsDataArr];
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
        if((NSNull *)singleCardDataDic == [NSNull null]){
            CCLOG(@"CardDataDicArr内部为null");
            return nil;
        }
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
    NSArray *usersInfoArr = [[GCDAsyncSocketHelper sharedHelper]analysisDataToArray:data];
    for(int i = 0; i < [usersInfoArr count]; i++){
        NSDictionary *singlePlayerFinalResult = [usersInfoArr objectAtIndex:i];
        NSString *userID = [singlePlayerFinalResult objectForKey:@"userID"];
        int winCoinTB = [[singlePlayerFinalResult objectForKey:@"winCoinTB"]intValue];
        User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
        [user setWinCoinTB:winCoinTB];
    }
}

+ (void)processUpdateUsersInfo:(NSData *)data
{
    NSArray *usersInfoArr = [[GCDAsyncSocketHelper sharedHelper]analysisDataToArray:data];
    for(int i = 0; i < [usersInfoArr count]; i++){
        NSDictionary *singlePlayerInfo = [usersInfoArr objectAtIndex:i];
        NSString *userID = [singlePlayerInfo objectForKey:@"userID"];
        int coinTB = [[singlePlayerInfo objectForKey:@"coinTB"]intValue];
        [[GameData sharedGameData]updateUserCoinTB:userID coinTB:coinTB];
    }
}

+ (User *)processOtherPlayerOut:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSString *userID = [dic objectForKey:@"userID"];
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    [[GameData sharedGameData]removeUserByUserID:userID];
    return user;
}

+ (void)processForcedChangeTable
{
    [[GameData sharedGameData]removeUserFromUserDicExceptMe];
}

+ (User *)processOtherPlayerOffline:(NSData *)data
{
    NSDictionary *offlineUserDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSString *userID = [offlineUserDic objectForKey:@"userID"];
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    [user setOffline:YES];
    return user;
}

+ (User *)processOtherPlayerOnline:(NSData *)data
{
    NSDictionary *onlineUserDic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];
    NSString *userID = [onlineUserDic objectForKey:@"userID"];
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    [user setOffline:NO];
    return user;
}

+ (void)processReconnectCardServer:(NSData *)data
{
    [self processEnterDeskData:data];
}

+ (NSString *)processNextRoundZ:(NSData *)data
{
    NSString *nextZuserID = [[GCDAsyncSocketHelper sharedHelper]analysisDataToString:data];
    return nextZuserID;
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
    user.canGrabZ = [[userDic objectForKey:@"canGrabZ"]boolValue];
    user.canBet = [[userDic objectForKey:@"canBet"]boolValue];
    user.showCardsDataArr = [self cardDataDicArr2cardsDataArr:[userDic objectForKey:@"showCards"]];
    user.cardType = [[userDic objectForKey:@"cardSize"]intValue];
    
    user.posID = [User chairID2posID:user.chairID];
    CCLOG(@"user userID:%@, posID:%d",user.userID,user.posID);
    return  user;
}


@end

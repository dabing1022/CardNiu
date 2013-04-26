//
//  GameData.h
//  NiuNiu
//  游戏数据
//  Created by childhood on 13-4-15.
//
//

#import <Foundation/Foundation.h>
@class User;
@interface GameData : NSObject
{
    //玩家本人
    User *_player;
    //牌桌内玩家字典表，键为userID
    NSMutableDictionary *_userDic;
    NSString *_zUserID;
}

@property(nonatomic, retain)User *player;
@property(nonatomic, retain)NSMutableDictionary *userDic;
@property(nonatomic, retain)NSString *zUserID;

+ (GameData *)sharedGameData;

@end

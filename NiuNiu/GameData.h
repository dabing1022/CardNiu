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
}

@property(nonatomic, retain)User *player;


+ (GameData *)sharedGameData;

@end

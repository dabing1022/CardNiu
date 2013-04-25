//
//  User.h
//  NiuNiu
//  用户数据
//  Created by childhood on 13-4-15.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface User : NSObject
{
    //用户主键
    NSString *_userID;
    //头像
    NSString *_avatarID;
    //角色职业(不可变）
    uint32_t _roleID;//Server:userTypeID
    //板凳序号
    uint32_t _chairID;
    //不同的板凳序号对应的位置序号
    uint32_t _posID;
    //玩家所在牌桌号
    uint32_t _tableID;
    //玩家小名字（改名前的名字)
    NSString *_nickName;
    //玩家大名字（改名后的名字)
    NSString *_userName;
    //玩家银两数目
    uint32_t _coinYL;
    //玩家铜币数目
    uint32_t _coinTB;
    //家产价值
    uint32_t _familyPropertyValue;
    //卡牌头衔
    NSString *_cardTitle;//Server:cardTitle
    //家产头衔
    NSString *_familyPropertyTitle;//Server:assetTitle
    //赌徒头衔
    NSString *_gamblerTitle;//Server:gameTitle
    //角色职业头衔
    NSString *_roleTitle;//Server:userTitle
    //每一局的牌数据数组
    NSMutableArray *_cardsDataArr;
    //每一局中用户选择的牌
    NSMutableArray *_selectedCardsDataArr;
    //每一局中玩家确认发送给服务器的牌
    //如牌数值数组为[2, 3, 4, 8, 10],玩家选择的为[4, 8, 3, 10],则发送给服务端的manualLength == 4, 数组为[4, 8, 3, 10, 2]
    NSMutableArray *_sendToServerArr;
    //每一局玩家的牌型结果
    int _cardType;
}

@property(nonatomic, retain)NSString *userID;
@property(nonatomic, retain)NSString *avatarID;
@property(nonatomic, assign)uint32_t roleID;
@property(nonatomic, assign)uint32_t chairID;
@property(nonatomic, assign)uint32_t posID;
@property(nonatomic, assign)uint32_t tableID;
@property(nonatomic, retain)NSString *nickName;
@property(nonatomic, retain)NSString *userName;
@property(nonatomic, assign)uint32_t coinYL;
@property(nonatomic, assign)uint32_t coinTB;
@property(nonatomic, assign)uint32_t familyPropertyValue;
@property(nonatomic, retain)NSString *cardTitle;
@property(nonatomic, retain)NSString *familyPropertyTitle;
@property(nonatomic, retain)NSString *gamblerTitle;
@property(nonatomic, retain)NSString *roleTitle;
@property(nonatomic, retain)NSMutableArray *cardsDataArr;
@property(nonatomic, retain)NSMutableArray *selectedCardsDataArr;
@property(nonatomic, retain)NSMutableArray *sendToServerArr;
@property(nonatomic, assign)int cardType;


+ (id)userWithUserID:(NSString *)userID nickName:(NSString *)nickName userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
- (id)initWithUserID:(NSString *)userID nickName:(NSString *)nickName userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
+ (int)chairID2posID:(int)chairID;
@end

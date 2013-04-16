//
//  User.h
//  NiuNiu
//  用户数据
//  Created by childhood on 13-4-15.
//
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    //用户主键
    NSString *_userID;
    //头像
    NSString *_avatarID;//Server:avatarID
    //角色
    uint32_t _roleID;//Server:userTypeID
    //玩家名字
    NSString *_userName;
    //玩家银两数目
    uint32_t _coinYL;//Server:coinYL
    //玩家铜币数目
    uint32_t _coinTB;//Server:coinTB
}

@property(nonatomic, retain)NSString *userID;
@property(nonatomic, retain)NSString *avatarID;
@property(nonatomic, assign)uint32_t roleID;
@property(nonatomic, retain)NSString *userName;
@property(nonatomic, assign)uint32_t coinYL;
@property(nonatomic, assign)uint32_t coinTB;

+ (id)userWithUserID:(NSString *)userID userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
- (id)initWithUserID:(NSString *)userID userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
@end

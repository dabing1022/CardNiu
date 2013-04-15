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

@property(nonatomic, retain)NSString *avatarID;
@property(nonatomic, assign)uint roleID;
@property(nonatomic, retain)NSString *userName;
@property(nonatomic, assign)uint coinYL;
@property(nonatomic, assign)uint coinTB;

+ (id)userWithUserName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
- (id)initWithUserName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB;
@end

//
//  User.m
//  NiuNiu
//  用户数据
//  Created by childhood on 13-4-15.
//
//

#import "User.h"
//((y+6-x)+2)%6
@implementation User
@synthesize userID=_userID,avatarID=_avatarID,roleID=_roleID,userName=_userName,coinYL=_coinYL,coinTB=_coinTB;

+ (id)userWithUserID:(NSString *)userID userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    return [[[self alloc]initWithUserID:(NSString *)userID userName:(NSString *)userName avatarID:avatarID roleID:roleID coinYL:coinYL coinTB:coinTB]autorelease];
}

- (id)initWithUserID:(NSString *)userID userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    self = [super init];
    if(self)
    {
        self.userID = userID;
        self.userName = userName;
        self.avatarID = avatarID;
        self.roleID = roleID;
        self.coinYL = coinYL;
        self.coinTB = coinTB;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
@end

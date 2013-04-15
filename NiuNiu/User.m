//
//  User.m
//  NiuNiu
//  用户数据
//  Created by childhood on 13-4-15.
//
//

#import "User.h"

@implementation User
@synthesize avatarID=_avatarID,roleID=_roleID,userName=_userName,coinYL=_coinYL,coinTB=_coinTB;







+ (id)userWithUserName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    return [[[self alloc]initWithUserName:userName avatarID:avatarID roleID:roleID coinYL:coinYL coinTB:coinTB]autorelease];
}

- (id)initWithUserName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    self = [super init];
    if(self)
    {
        _userName = userName;
        _avatarID = avatarID;
        _roleID = roleID;
        _coinYL = coinYL;
        _coinTB = coinTB;
    }
    return self;
}

- (void)dealloc
{
    [_avatarID release];
    [_userName release];
    [super dealloc];
}
@end

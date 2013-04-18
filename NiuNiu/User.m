//
//  User.m
//  NiuNiu
//  用户数据
//  Created by childhood on 13-4-15.
//
//

#import "User.h"
#import "GameData.h"

//((y+6-x)+2)%6
@implementation User
@synthesize userID=_userID,avatarID=_avatarID,roleID=_roleID,chairID=_chairID,posID=_posID,tableID=_tableID;
@synthesize nickName=_nickName,userName=_userName;
@synthesize coinYL=_coinYL,coinTB=_coinTB,familyPropertyValue=_familyPropertyValue;
@synthesize cardTitle=_cardTitle,familyPropertyTitle=_familyPropertyTitle,gamblerTitle=_gamblerTitle,roleTitle=_roleTitle;

#pragma mark - init
+ (id)userWithUserID:(NSString *)userID nickName:(NSString *)nickName userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    return [[[self alloc]initWithUserID:(NSString *)userID nickName:(NSString *)nickName userName:(NSString *)userName avatarID:avatarID roleID:roleID coinYL:coinYL coinTB:coinTB]autorelease];
}

- (id)initWithUserID:(NSString *)userID nickName:(NSString *)nickName userName:(NSString *)userName avatarID:(NSString *)avatarID roleID:(uint32_t)roleID coinYL:(uint32_t)coinYL coinTB:(uint32_t)coinTB
{
    self = [super init];
    if(self)
    {
        self.userID = userID;
        self.nickName = nickName;
        self.userName = userName;
        self.avatarID = avatarID;
        self.roleID = roleID;
        self.coinYL = coinYL;
        self.coinTB = coinTB;
    }
    return self;
}

+ (int)chairID2posID:(int)chairID
{
    CCLOG(@"User.h--->player.chairID: %d", [[GameData sharedGameData]player].chairID);
    return ((chairID+6-[[GameData sharedGameData]player].chairID)+2)%6;
}

- (void)dealloc
{
    [super dealloc];
}
@end

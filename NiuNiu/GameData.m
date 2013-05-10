//
//  GameData.m
//  NiuNiu
//
//  Created by childhood on 13-4-15.
//
//

#import "GameData.h"
#import "User.h"

@implementation GameData
@synthesize player=_player,userDic=_userDic,zUserID=_zUserID;
static GameData *_instance = nil;


+ (GameData *)sharedGameData
{
    if(!_instance)
    {
        _instance = [[self alloc]init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.player = nil;
        self.userDic = [[NSMutableDictionary alloc]init];
        self.zUserID = nil;
    }
    return self;
}

- (void)addUserByUser:(User *)user
{
    [self.userDic setObject:user forKey:user.userID];
}

- (void)removeUserByUserID:(NSString *)userID
{
    [self.userDic removeObjectForKey:userID];
}

- (void)removeUserFromUserDicExceptMe
{
    for(NSString *key in _userDic){
        if([key isEqualToString:[[[GameData sharedGameData]player]userID]])
            continue;
        [self removeUserByUserID:key];
    }
}

- (void)updateUserCoinTB:(NSString *)userID coinTB:(uint32_t)coinTB
{
    User *user = [_userDic objectForKey:userID];
    [user setCoinTB:coinTB];
}

- (void)dealloc
{
    [_player release];
    [_userDic release];
    [_zUserID release];
    _instance = nil;
    [super dealloc];
}
@end

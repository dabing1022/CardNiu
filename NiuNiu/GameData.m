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
@synthesize player=_player,userDic=_userDic;
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
    }
    return self;
}

- (void)dealloc
{
    [_userDic release];
    _instance = nil;
    [super dealloc];
}
@end
